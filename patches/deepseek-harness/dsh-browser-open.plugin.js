/**
 * browser-open: serve one host file to the client's browser over the GET
 * /api/file route, the headless-host counterpart of the native path opener.
 *
 * This is the plain-JS function body for `cordis_define` → `code.host`.
 * It registers an exact webServer route (exact beats the apiproxy's /api
 * prefix, so no product source change is needed), confines paths to $HOME
 * (derived from the settings document location), streams text files through
 * an escaped HTML viewer with inline highlight.js from /etc/dsh-browser-open,
 * and falls back to a raw MIME response.
 *
 * Runtime assets (optional; the viewer degrades to plain <pre> without them):
 *   /etc/dsh-browser-open/hljs.min.js
 *   /etc/dsh-browser-open/hljs.min.css
 */

/** highlight.js asset paths, read once at first viewer request. */
const HLJS_JS_PATH = '/etc/dsh-browser-open/hljs.min.js'
const HLJS_CSS_PATH = '/etc/dsh-browser-open/hljs.min.css'

/** Extension → MIME for the browser-open file route. */
const FILE_CONTENT_TYPES = {
  '.html': 'text/html', '.htm': 'text/html', '.xhtml': 'application/xhtml+xml',
  '.svg': 'image/svg+xml', '.md': 'text/markdown', '.markdown': 'text/markdown',
  '.txt': 'text/plain', '.log': 'text/plain', '.json': 'application/json',
  '.yaml': 'text/yaml', '.yml': 'text/yaml', '.toml': 'text/plain',
  '.js': 'text/javascript', '.mjs': 'text/javascript', '.cjs': 'text/javascript',
  '.ts': 'text/plain', '.tsx': 'text/plain', '.jsx': 'text/plain',
  '.css': 'text/css', '.xml': 'text/xml', '.csv': 'text/csv',
  // Common source/config extensions default to text so the browser views them
  // inline instead of downloading (the viewer path also handles them).
  '.nix': 'text/plain', '.sh': 'text/plain', '.bash': 'text/plain', '.zsh': 'text/plain',
  '.py': 'text/plain', '.rb': 'text/plain', '.go': 'text/plain', '.rs': 'text/plain',
  '.c': 'text/plain', '.h': 'text/plain', '.cpp': 'text/plain', '.cc': 'text/plain', '.hpp': 'text/plain',
  '.java': 'text/plain', '.sql': 'text/plain', '.ini': 'text/plain', '.conf': 'text/plain',
  '.cfg': 'text/plain', '.env': 'text/plain', '.lock': 'text/plain',
  '.gitignore': 'text/plain', '.gitattributes': 'text/plain', '.editorconfig': 'text/plain',
  '.vue': 'text/plain', '.svelte': 'text/plain', '.php': 'text/plain', '.lua': 'text/plain',
  '.swift': 'text/plain', '.kt': 'text/plain', '.scala': 'text/plain', '.dart': 'text/plain',
  '.hcl': 'text/plain', '.tf': 'text/plain', '.proto': 'text/plain', '.graphql': 'text/plain',
  '.cs': 'text/plain', '.fs': 'text/plain', '.ex': 'text/plain', '.exs': 'text/plain',
  '.png': 'image/png', '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg',
  '.gif': 'image/gif', '.webp': 'image/webp', '.pdf': 'application/pdf',
}

/** Content types the browser renders inline; everything else is an attachment download. */
const FILE_INLINE_TYPES = new Set([
  'text/html', 'text/plain', 'text/markdown', 'text/yaml', 'text/javascript', 'text/css', 'text/xml', 'text/csv',
  'application/json', 'application/xhtml+xml', 'image/svg+xml',
  'image/png', 'image/jpeg', 'image/gif', 'image/webp', 'application/pdf',
])

/** Extension → highlight.js language token for the viewer. */
const FILE_HIGHLIGHT_LANGUAGES = {
  '.js': 'javascript', '.mjs': 'javascript', '.cjs': 'javascript',
  '.ts': 'typescript', '.tsx': 'tsx', '.jsx': 'jsx',
  '.html': 'xml', '.htm': 'xml', '.svg': 'xml', '.xml': 'xml', '.css': 'css',
  '.md': 'markdown', '.markdown': 'markdown', '.json': 'json',
  '.yaml': 'yaml', '.yml': 'yaml', '.toml': 'ini', '.ini': 'ini', '.conf': 'ini',
  '.py': 'python', '.rb': 'ruby', '.go': 'go', '.rs': 'rust', '.c': 'c', '.h': 'c',
  '.cpp': 'cpp', '.cc': 'cpp', '.hpp': 'cpp', '.java': 'java', '.sql': 'sql',
  '.sh': 'bash', '.bash': 'bash', '.zsh': 'bash', '.nix': 'nix',
  '.lua': 'lua', '.php': 'php', '.swift': 'swift', '.kt': 'kotlin', '.scala': 'scala',
  '.dart': 'dart', '.hcl': 'hcl', '.tf': 'hcl', '.proto': 'protobuf', '.graphql': 'graphql',
  '.cs': 'csharp', '.fs': 'fsharp', '.ex': 'elixir', '.exs': 'elixir',
}

/** Cap for files wrapped in the HTML viewer (memory-bounded embed). */
const VIEWER_MAX_BYTES = 2 * 1024 * 1024

/** Cap for raw responses (bounded read instead of a stream in this sandbox). */
const RAW_MAX_BYTES = 64 * 1024 * 1024

/** Viewer CSP: opaque origin, scripts allowed for hljs only, no DSH API reach. */
const VIEWER_CSP = "sandbox allow-scripts; default-src 'none'; script-src 'unsafe-inline'; style-src 'unsafe-inline'; img-src data:; base-uri 'none'"

/** Raw CSP: sandboxed document, no scripts. */
const RAW_CSP = "sandbox; default-src 'none'; img-src 'self' data:"

/** Escape text for safe embedding inside an HTML code element. */
function escapeHtmlText(value) {
  return value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;')
}

/** Node-style extension of a canonical absolute path ('' when none). */
function extensionOf(path) {
  const name = basenameOf(path)
  const at = name.lastIndexOf('.')
  return at > 0 ? name.slice(at).toLowerCase() : ''
}

/** Last path component of a '/' separated path. */
function basenameOf(path) {
  const at = path.lastIndexOf('/')
  return at === -1 ? path : path.slice(at + 1)
}

/**
 * Build a syntax-highlighted HTML viewer for one text file. The file content
 * is embedded HTML-escaped (never executed), highlighted client-side by
 * highlight.js loaded inline (no external request), and served under a
 * `sandbox allow-scripts` CSP whose opaque origin cannot reach the DSH API
 * even if the page were compromised. Without the /etc assets the viewer
 * degrades to an escaped plain <pre>.
 */
function viewerHtml(filename, fullPath, language, content, assets) {
  const langClass = language === undefined ? '' : ` class="language-${escapeHtmlText(language)}"`
  const rawUrl = `/api/file?path=${encodeURIComponent(fullPath)}`
  const styleBlock = assets === null ? '' : `<style>\n${assets.css}\n</style>\n`
  const scripts = assets === null
    ? ''
    : `<script>${assets.js}</script>\n<script>document.addEventListener('DOMContentLoaded',function(){var e=document.querySelector('code');if(window.hljs){var l=e.className.match(/language-(\\S+)/);if(l&&!hljs.getLanguage(l[1]))e.className='hljs';hljs.highlightElement(e)}})</script>\n`
  return `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${escapeHtmlText(filename)}</title>
<style>
  body { margin: 0; font-family: system-ui, sans-serif; }
  .bar { display: flex; align-items: center; gap: 1rem; padding: 0.4rem 0.8rem; background: #f6f8fa; border-bottom: 1px solid #d0d7de; }
  .bar .name { font-weight: 600; }
  .bar a { color: #0969da; text-decoration: none; }
  pre { margin: 0; padding: 0.8rem; overflow: auto; }
  code.hljs { padding: 0; background: transparent; }
${styleBlock}</style>
</head>
<body>
<div class="bar"><span class="name">${escapeHtmlText(filename)}</span><a href="${rawUrl}">raw</a></div>
<pre><code${langClass}>${escapeHtmlText(content)}</code></pre>
${scripts}</body>
</html>`
}

return {
  name: 'browser-open-file-route',
  apply(ctx) {
    const webServer = ctx.get('webServer')
    const fsys = ctx.get('fs')
    if (webServer === undefined || fsys === undefined) {
      console.warn('browser-open: webServer or fs service absent; route not registered')
      return
    }

    // Served root: $HOME, derived from the settings document location
    // ($HOME/.dsh/settings.yaml) because the sandbox has no os.homedir.
    // undefined = not resolved yet; null = unavailable (deny everything).
    let homeCache
    async function resolveHome() {
      if (homeCache !== undefined) return homeCache
      let result = null
      try {
        const settings = ctx.get('settings')
        const doc = settings === undefined ? undefined : await settings.prepareDocument()
        if (typeof doc === 'string' && doc.startsWith('/') && doc.length > 0) {
          const parts = doc.split('/').filter(Boolean)
          parts.pop() // settings file name
          parts.pop() // settings directory ($HOME/.dsh)
          if (parts.length > 0) result = '/' + parts.join('/')
        }
      } catch {
        result = null
      }
      homeCache = result
      return result
    }

    // External highlight.js files, read once and cached; null when absent.
    let hljsCache
    async function hljsAssets() {
      if (hljsCache !== undefined) return hljsCache
      let assets = null
      try {
        const jsTarget = await fsys.resolve(HLJS_JS_PATH)
        const cssTarget = await fsys.resolve(HLJS_CSS_PATH)
        assets = {
          js: await fsys.readText(jsTarget),
          css: await fsys.readText(cssTarget),
        }
      } catch {
        assets = null
      }
      hljsCache = assets
      return assets
    }

    async function handler(req, res) {
      try {
        let params
        try {
          const raw = req.url ?? '/'
          const at = raw.indexOf('?')
          params = new Map()
          if (at !== -1) {
            for (const pair of raw.slice(at + 1).split('&')) {
              if (pair.length === 0) continue
              const eq = pair.indexOf('=')
              const key = eq === -1 ? pair : pair.slice(0, eq)
              const value = eq === -1 ? '' : pair.slice(eq + 1)
              params.set(key, decodeURIComponent(value))
            }
          }
        } catch {
          return respond(res, 400, 'missing or invalid path query parameter')
        }
        const path = params.get('path')
        if (path === undefined || path.length === 0) {
          return respond(res, 400, 'missing or invalid path query parameter')
        }
        if (!path.startsWith('/')) {
          return respond(res, 403, 'path is outside the served roots')
        }
        const view = params.get('view') === '1'

        const home = await resolveHome()
        if (home === null) {
          return respond(res, 403, 'served roots are unavailable')
        }

        let target
        let info
        try {
          target = await fsys.resolve(path)
          info = await fsys.stat(target)
        } catch {
          return respond(res, 404, 'file not found')
        }
        if (info === undefined) return respond(res, 404, 'file not found')
        if (info.type !== 'file') return respond(res, 400, 'target is not a file')

        // Canonical path after symlink resolution: confinement checks the
        // real location, so a link inside $HOME cannot escape it.
        const canonical = fsys.processPath(target)
        if (canonical !== home && !canonical.startsWith(`${home}/`)) {
          return respond(res, 403, 'path is outside the served roots')
        }

        const ext = extensionOf(canonical)
        const contentType = FILE_CONTENT_TYPES[ext] ?? 'application/octet-stream'
        const inline = FILE_INLINE_TYPES.has(contentType)
        const filename = basenameOf(canonical)

        // Viewer mode: wrap text-ish files in a syntax-highlighted HTML page.
        if (view && inline && (info.size ?? 0) <= VIEWER_MAX_BYTES) {
          try {
            const assets = await hljsAssets()
            const lang = FILE_HIGHLIGHT_LANGUAGES[ext]
            const content = await fsys.readText(target)
            const html = viewerHtml(filename, canonical, lang, content, assets)
            return respond(res, 200, html, {
              'content-type': 'text/html; charset=utf-8',
              'content-disposition': 'inline',
              'content-security-policy': VIEWER_CSP,
              'x-content-type-options': 'nosniff',
              'cache-control': 'no-store',
              'x-accel-buffering': 'no',
            })
          } catch {
            // Viewer read failed → fall through to the raw path.
          }
        }

        // Raw: bounded read with MIME, disposition, and a sandbox CSP.
        let bytes
        try {
          bytes = await fsys.readBytes(target, undefined, RAW_MAX_BYTES)
        } catch (error) {
          const message = error instanceof Error ? error.message : String(error)
          if (message.includes('FS_TOO_LARGE')) {
            return respond(res, 413, 'file too large')
          }
          throw error
        }
        return respond(res, 200, bytes, {
          'content-type': contentType,
          'content-disposition': inline ? 'inline' : `attachment; filename="${filename}"`,
          'content-security-policy': RAW_CSP,
          'x-content-type-options': 'nosniff',
          'cache-control': 'no-store',
          'x-accel-buffering': 'no',
        })
      } catch (error) {
        console.warn('browser-open: request failed', error instanceof Error ? error.message : String(error))
        if (!res.headersSent) {
          respond(res, 500, 'internal error')
        } else {
          res.end()
        }
      }
    }

    function respond(res, status, body, headers = {}) {
      res.writeHead(status, {
        'content-type': 'text/plain; charset=utf-8',
        'cache-control': 'no-store',
        ...headers,
      })
      res.end(body)
    }

    // Exact route: webserver matches exact before prefix, so this shadows the
    // apiproxy's /api prefix handler (which answers 404 for GET /api/file).
    ctx.effect(() => webServer.register({ kind: 'exact', path: '/api/file', handler }))
  },
}
