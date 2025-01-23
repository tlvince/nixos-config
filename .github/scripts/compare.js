const generateCompareLinks = (flakeUpdateOutput) => {
  const regex =
    /'(?<repo>[^']+)':\s*'[^']*?(?:rev=|\/)(?<oldCommit>[a-f0-9]+)[^']*'\s*\(.*?\)\s*→\s*'[^']*?(?:rev=|\/)(?<newCommit>[a-f0-9]+)[^']*'/gm;

  let match;
  const links = [];

  while ((match = regex.exec(flakeUpdateOutput)) !== null) {
    const { repo, oldCommit, newCommit } = match.groups;
    const compareUrl = `https://github.com/${repo}/compare/${oldCommit}...${newCommit}`;
    links.push(compareUrl);
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
