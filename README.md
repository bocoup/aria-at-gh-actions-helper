# ARIA AT GitHub Actions Helper

This repo holds:

- workflow definitions for GitHub Actions
- pipeline defintions for Azure Pipelines (not currently maintained, was experimental)
- scripts to run these jobs many times to test for inconsistent results ([stressor](https://github.com/bocoup/aria-at-gh-actions-helper/blob/main/stressor/README.md))

This repo's GitHub Actions queue is also where automated test runs from the [ARIA AT app](https://github.com/w3c/aria-at-app) are run.

## General Workflow Properties

All of the workflows setup the environments to be able to run [aria-at-automation-harness](https://github.com/w3c/aria-at-automation-harness/) against a set of tests from [aria-at](https://github.com/w3c/aria-at).
The general structure of each workflow is very similar, setup the environment with needed software, launch the tests, report status via HTTP.

They all support a generic set of parameters:

- `work_dir`: The --plan-workingdir passed to the aria-at-automation harness. Based from the aria-at repo build folder. Uses a default of tests/alert if not provided.
- `callback_url`: The harness will send POST requests to this url using callback_header header with test results. This is how the action communicates progress to the app.
- `callback_header`: The harness will send POST requests to callback_url using this header with status updates.
- `browser`: The workflows are split up for various ATs, but each is capable of running several browsers.

Each workflow also has other parameters that can be configured for specific versions of the AT, etc.

## Staging environment

This repo is also automatically merged into a [-dev fork](https://github.com/bocoup/aria-at-gh-actions-helper-dev).
The dev repo is used for staging and local development so that the main repo's action queue can be separate.

## AT Specific Information

### NVDA

NVDA uses [Prime-Access-Consulting/nvda-at-automation](https://github.com/Prime-Access-Consulting/nvda-at-automation) as its at-driver server, and the NVDA plugin in the same repository is installed in the NVDA.
NVDA uses portable installs that are stored in [bocoup/aria-at-automation-nvda-builds](https://github.com/bocoup/aria-at-automation-nvda-builds). Documentation to build these portable installs is on the README.
NVDA then uses the windows version of the `run-tester.ps1`

### JAWS

JAWS has at-driver support built in and downloads and uses the builds from JAWS directly.
This install process happens in JAWS/InstallJawsUnattended.ps1.
The license file for registration is encoded with gpg using a passphrase. To create the license file:

```sh
gpg --quiet --batch --yes --symmetric --passphrase="(the secret)" --output JAWS/secret_JAWS.lic.gpg /path/to/unencrypted/JAWS.lic
```

### VoiceOver for MacOS

Due to troubles with the hosted mac os solutions on github, we are currently using the self-hosted-macos-15 workflow and running virtual machines on MacStadium.

## Documentation References

- [aria-at-app automation documentation](https://github.com/w3c/aria-at-app/blob/development/docs/automation.md)
- [aria-at-automation-harness](https://github.com/w3c/aria-at-automation-harness/blob/main/README.md)
