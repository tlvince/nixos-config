#!/usr/bin/env bash
set -euo pipefail

# Echoes "repo pr" for a pick URL, resolving frozen commits to their upstream
# PR via the associated-pull-requests API. Fails when unresolvable (kept).
patch_pr() {
  local url=$1 repo ref pr_json
  if [[ $url =~ ^https://github.com/([^/]+/[^/]+)/pull/([0-9]+)$ ]]; then
    echo "${BASH_REMATCH[1]} ${BASH_REMATCH[2]}"
  elif [[ $url =~ ^https://github.com/([^/]+/[^/]+)/commit/([0-9a-f]{40})$ ]]; then
    repo=${BASH_REMATCH[1]}
    ref=${BASH_REMATCH[2]}
    if ! pr_json=$(curl -sSf "https://api.github.com/repos/$repo/commits/$ref/pulls"); then
      return 1
    fi
    jq -r -e '[.[] | select(.base.repo.full_name=="NixOS/nixpkgs")][0] | "\(.base.repo.full_name) \(.number)"' <<<"$pr_json"
  else
    return 1
  fi
}

# True when the patch's PR is merged AND its merge commit is already contained
# in $nixpkgs_rev (channels lag master by days; "merged" alone is not
# enough). Unknown/unresolvable patches are kept.
patch_landed() {
  local url=$1 repo pr pr_json merge_sha status
  if ! read -r repo pr < <(patch_pr "$url"); then
    return 1
  fi
  # Unresolvable associated PR surfaces as literal nulls; keep.
  [[ "$repo" != null && "$repo" != "" && "$pr" != null ]] || return 1
  if ! pr_json=$(curl -sSf "https://api.github.com/repos/$repo/pulls/$pr"); then
    return 1
  fi
  [[ -n "$(jq -r '.merged_at // empty' <<<"$pr_json")" ]] || return 1
  merge_sha="$(jq -r '.merge_commit_sha' <<<"$pr_json")"
  status="$(curl -sSf "https://api.github.com/repos/NixOS/nixpkgs/compare/${merge_sha}...${nixpkgs_rev}" | jq -r '.status')"
  [[ "$status" == ahead || "$status" == identical ]]
}

PicksFile=.github/scripts/nixpkgs-patches.sh

# Removes a landed pick's block (4 comment lines + URL line) from the picks
# file. Echoes its tracking issue number. Aborts rather than mangling.
drop_patch() {
  local url=$1 lineno start issue
  lineno=$(grep -nF "  $url" "$PicksFile" | cut -d: -f1 | head -n 1)
  start=$((lineno - 4))
  if ! sed -n "${start},$((lineno - 1))p" "$PicksFile" | grep -qv '^  #'; then
    :
  else
    echo "Refusing to delete $url: expected 4 comment lines above it" >&2
    return 1
  fi
  issue=$(sed -n "${start},${lineno}p" "$PicksFile" | grep -oE '/issues/[0-9]+' | head -n 1 | tr -dc '0-9')
  sed -i "${start},${lineno}d" "$PicksFile"
  echo "$issue"
}

nixpkgs_rev="$(jq -er '.nodes."nixpkgs-upstream".locked.rev' flake.lock)"

source "${BASH_SOURCE[0]%/*}/nixpkgs-patches.sh"

dropped=()
for url in "${patches[@]}"; do
  if patch_landed "$url"; then
    issue="$(drop_patch "$url")"
    msg="Dropped $url (landed in $nixpkgs_rev, closes #${issue:-?})"
    echo "::notice::$msg"
    dropped+=("$msg")
  fi
done

if ((${#dropped[@]} == 0)); then
  echo "No nixpkgs patches have landed."
  exit 0
fi

rev_url="https://github.com/NixOS/nixpkgs/commit/$nixpkgs_rev"
linked=("${dropped[@]/"$nixpkgs_rev"/"[$nixpkgs_rev]($rev_url)"}")

if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  {
    echo "### Dropped landed nixpkgs patches"
    printf -- '- [ ] %s\n' "${linked[@]}"
  } >>"$GITHUB_STEP_SUMMARY"
fi

branch=chore/drop-landed-nixpkgs-patches
git checkout -B "$branch"
git add "$PicksFile"
git -c user.name="github-actions[bot]" \
  -c user.email="41898282+github-actions[bot]@users.noreply.github.com" \
  commit -m "chore(nixpkgs-patches): drop landed picks" -m "$(printf '%s\n' "${dropped[@]}")"
git push --force -u origin "$branch"

existing=$(gh pr list --head "$branch" --json number --jq '.[0].number // empty')
if [[ -n "$existing" ]]; then
  echo "Updated existing PR #$existing"
else
  gh pr create --title "chore(nixpkgs-patches): drop landed picks" \
    --body "$(printf '%s\n' "${linked[@]}")"
fi
