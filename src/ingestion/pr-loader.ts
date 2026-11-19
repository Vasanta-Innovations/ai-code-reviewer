import * as github from '@actions/github';
import { parseUnifiedDiff, ParsedDiff } from './diff-parser';

export interface PullRequestMetadata {
  owner: string;
  repo: string;
  pullNumber: number;
  title: string;
  author: string;
  baseSha: string;
  headSha: string;
  htmlUrl: string;
  parsedDiff: ParsedDiff;
}

export async function loadPullRequest(octokit: ReturnType<typeof github.getOctokit>): Promise<PullRequestMetadata> {
  const context = github.context;

  if (!context.payload.pull_request) {
    throw new Error('This action can only run on pull_request events.');
  }

  const { owner, repo } = context.repo;
  const pullNumber = context.payload.pull_request.number;
  const title = context.payload.pull_request.title || '';
  const author = context.payload.pull_request.user?.login || 'unknown';
  const baseSha = context.payload.pull_request.base?.sha || '';
  const headSha = context.payload.pull_request.head?.sha || '';
  const htmlUrl = context.payload.pull_request.html_url || '';

  // Fetch the unified diff from GitHub API
  const response = await octokit.rest.pulls.get({
    owner,
    repo,
    pull_number: pullNumber,
    mediaType: {
      format: 'diff',
    },
  });

  const rawDiff = response.data as unknown as string;
  const parsedDiff = parseUnifiedDiff(rawDiff);

  return {
    owner,
    repo,
    pullNumber,
    title,
    author,
    baseSha,
    headSha,
    htmlUrl,
    parsedDiff,
  };
}
