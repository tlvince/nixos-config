const parseLockUpdates = (message) => {
  const updates = [];
  const entryPattern =
    /• Updated input '(?<input>[^']+)':(?<details>[\s\S]*?)(?=• Updated input '|$)/g;

  let entry;
  while ((entry = entryPattern.exec(message)) !== null) {
    const { input, details } = entry.groups;
    const hashPattern =
      /(?:'github:[^/]+\/[^/]+\/(?<hash1>[0-9a-fA-F]{40})[^']*'|git\+https:\/\/github\.com\/[^/]+\/[^/]+\?[^']*rev=(?<hash2>[0-9a-fA-F]{40})[^']*)/g;
    const repoPattern =
      /(?:'github:(?<repo1>[^/]+\/[^/]+)\/|git\+https:\/\/github\.com\/(?<repo2>[^/]+\/[^/]+)\?)/;

    const hashes = [];
    let hashMatch;
    while ((hashMatch = hashPattern.exec(details)) !== null) {
      hashes.push(hashMatch.groups.hash1 || hashMatch.groups.hash2);
    }

    const repoMatch = repoPattern.exec(details);
    const repo = repoMatch
      ? repoMatch.groups.repo1 || repoMatch.groups.repo2
      : undefined;

    updates.push({
      input,
      repo,
      oldCommit: hashes[0],
      newCommit: hashes[1],
      raw: details.trim(),
    });
  }

  return updates;
};

const compareUrl = ({ repo, oldCommit, newCommit }) => {
  if (!repo || !oldCommit || !newCommit) {
    return null;
  }
  return `https://github.com/${repo}/compare/${oldCommit}...${newCommit}`;
};

const formatPrBody = (message) => {
  const updates = parseLockUpdates(message);
  if (!updates.length) {
    return null;
  }

  const lines = ["Flake lock file updates:", ""];
  const leftovers = [];

  for (const update of updates) {
    const url = compareUrl(update);
    if (url) {
      lines.push(`- Updated input '${update.input}': ${url}`);
    } else {
      leftovers.push(update);
    }
  }

  if (leftovers.length) {
    lines.push("", "```");
    for (const update of leftovers) {
      lines.push(`• Updated input '${update.input}':`, update.raw);
    }
    lines.push("```");
  }

  return lines.join("\n");
};

module.exports = async ({ github, context, core }) => {
  const { GIT_COMMIT_MESSAGE } = process.env;
  if (!GIT_COMMIT_MESSAGE) {
    core.warning("unable to determine latest commit message");
    return;
  }

  const body = formatPrBody(GIT_COMMIT_MESSAGE);
  if (!body) {
    core.warning("no lock updates found");
    return;
  }

  return body;
};
