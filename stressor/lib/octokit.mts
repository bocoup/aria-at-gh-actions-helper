import { Octokit } from '@octokit/rest';
import { throttling } from '@octokit/plugin-throttling';

const WithThrottle = Octokit.plugin(throttling);

export const githubClient = new WithThrottle({
  auth: process.env.GITHUB_TOKEN,
  throttle: {
    // param types just guessing to make TS allow it
    onRateLimit: (
      retryAfter: any,
      options: { method: any; url: any },
      octokit: {
        log: { warn: (arg0: string) => void; info: (arg0: string) => void };
      },
      retryCount: number
    ) => {
      octokit.log.warn(
        `Request quota exhausted for request ${options.method} ${options.url}`
      );

      if (retryCount < 1) {
        // only retries once
        octokit.log.info(`Retrying after ${retryAfter} seconds!`);
        return true;
      }
    },
    onSecondaryRateLimit: (
      retryAfter: any,
      options: { method: any; url: any },
      octokit: { log: { warn: (arg0: string) => void } }
    ) => {
      // does not retry, only logs a warning
      octokit.log.warn(
        `SecondaryRateLimit detected for request ${options.method} ${options.url}`
      );
    }
  }
});
