# Stress Test Script

This node script dispatches multiple runs of each workflow with each supported browser for the list of test plans defined at the top of [./stress-test.mts](./stress-test.mts).

It works sequentially through the list of test plans, completing the runs for one before beginning the next.

## Setup

1. Install dependencies with `npm i`
2. set an environment variable `GITHUB_TOKEN` with an access token. To generate a new token:

* https://github.com/settings/personal-access-tokens/new
* Generate a new token, make sure it has access to the repo you'll be running the stress actions on, and give it Read & Write "Actions" permissions (everything else can stay default).
* For more information see [these docs](https://docs.github.com/en/rest/actions/workflows?apiVersion=2022-11-28#create-a-workflow-dispatch-event) for which token needs which auth scopes and how to generate them.

## Running

1. Create a personal fork of this repo to avoid creating bottlenecks in the regular job queue for users of the ARIA-AT app. Keep the fork public to avoid running into GH Action limits. 
2. Run it with the following command (replacing `myUser` and `myRepo` with the owner and name of your repository. Note that the `--repo` option defaults to 'aria-at-gh-actions-helper'):
```
      $ npm run stress-test -- --owner myUser --repo myRepo --md-output some-output-file.md
```
3. Running the script can take a while, as it is constrained by GitHub Actions availability and speed.

Set an environment variable `DEBUG` to `1` or `true` to get extra logging
