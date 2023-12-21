const generateCompareLinks = (flakeUpdateOutput) => {
  const regex =
    /'github:(?<repo>[^/]+\/[^/]+)\/(?<oldCommit>[0-9a-f]+)'\s*\((\d{4}-\d{2}-\d{2})\)\s*→\s*'github:\1\/(?<newCommit>[0-9a-f]+)'/g;

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
