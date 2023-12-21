const generateCompareLinks = (flakeUpdateOutput) => {
  const regex =
    /'github:(?<repo>[^/]+\/[^/]+)\/(?<oldCommit>[0-9a-f]+)'.*→ 'github:\1\/(?<newCommit>[0-9a-f]+)'/g;

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
  const commits = await github.rest.repos.listCommits({
    owner: context.repo.owner,
    repo: context.repo.repo,
    per_page: 1,
    page: 1,
  });

  const commit = commits?.data?.[0]?.commit?.message;
  if (!commit) {
    core.warning("unable to determine latest commit message");
    return;
  }

  const compareLinks = generateCompareLinks(commit);
  if (!compareLinks.length) {
    core.warning("no compare links found");
    return;
  }

  return compareLinks;
};
