const generateCompareLinks = (input) => {
  // DeepSeek-R1 generated
  const regex =
    /(?:'github:(?<repo1>[^/]+\/[^/]+)\/(?<oldCommit1>[0-9a-fA-F]{40})[^']*'|'git\+https:\/\/github\.com\/(?<repo2>[^/]+\/[^/]+)\?[^']*rev=(?<oldCommit2>[0-9a-fA-F]{40})[^']*')[\s\S]*?→[\s\S]*?(?:'github:[^/]+\/[^/]+\/(?<newCommit1>[0-9a-fA-F]{40})[^']*'|'git\+https:\/\/github\.com\/[^/]+\/[^/]+\?[^']*rev=(?<newCommit2>[0-9a-fA-F]{40})[^']*')/g;

  const links = [];
  let match;

  while ((match = regex.exec(input)) !== null) {
    const groups = match.groups;
    const repo = groups.repo1 || groups.repo2;
    const oldCommit = groups.oldCommit1 || groups.oldCommit2;
    const newCommit = groups.newCommit1 || groups.newCommit2;

    if (repo && oldCommit && newCommit) {
      const compareUrl = `https://github.com/${repo}/compare/${oldCommit}...${newCommit}`;
      links.push(compareUrl);
    }
  }

  return links;
};

module.exports = async ({ github, context, core }) => {
  const { GIT_COMMIT_MESSAGE } = process.env;
  if (!GIT_COMMIT_MESSAGE) {
    core.warning("unable to determine latest commit message");
    return;
  }

  const compareLinks = generateCompareLinks(GIT_COMMIT_MESSAGE);
  if (!compareLinks.length) {
    core.warning("no compare links found");
    return;
  }

  return compareLinks;
};
