Test Pull Requests
==================

[![TravisCI](https://travis-ci.org/openshift/test-pull-requests.svg?branch=master)](https://travis-ci.org/openshift/test-pull-requests)

Utility for serially testing and merging pull requests in conjunction with Jenkins.

## Typical User Workflow
 * Write some code, fix bugs locally, submit your pull requests
 * Get your changes reviewed
 * If you aren't sure of your changes, perhaps because of a complicated merge, you'll want to force your changes through verification tests before attempting to merge and perhaps before they get reviewed.  You may also want to do this to show the results to the reviewer.
   * You (or anyone in an authorized GitHub team) can do this by adding the case insensitive string `[test]` to a comment or the title of your pull request.
   * If you have prereq/coreq pull requests, you can add their urls (Ex: ​https://github.com/openshift/origin-server/pull/1) to the comments (one per repo supported), and they will be automatically included in the testing.
   * The results of the test will be put in the pull request. If they don't pass, you'll need to fix the issues before continuing
 * Similar to the `[test]` flag above, you must add the `[merge]` flag to the title or a comment of the pull request.  This is the only way you should be getting your changes into the master or stage branches.  The merge flag (handles prereqs the same as `[test]`) builds and installs your changes with the exact source on the target branch that passed the previous tests. This is done serially so your changes are the only changes since the last successful build. After the tests pass your pull request(s) (including prereqs in comments) are merged into master. Note: if you make changes to your pull request(s) after tests start, your merge will fail and the tests will be retried.

### Permissions
 * `[merge]` and `[test]` flags are only listened to for trusted users (in comments or titles) and are only supported for the configured branches.
 * Retries will automatically occur if a pull request is updated after a failure as long as the owner of the pull request is trusted.  So for example, if you tag a pull request with `[merge]` for a non trusted user, then they add code to the commit. It will fail on merge because they updated after the tests were started and will not retry until another `[merge]` tag is added/updated by a trusted user.  Trusted users are determined per test group and you can have multiple GitHub teams assigned to the same repo.


## Setup
 * Add `test_pull_requests` to your Jenkins system and make sure it's executable
 * Add `.test_pull_requests.json` to `$JENKINS_HOME`
 * Configure `.test_pull_requests.json` according to your system.  You can decide whether to support `[test]` and/or `[merge]` as well as potentially add other flags for your use cases.
 * For each test group you'll then need to configure your Jenkins to have a corresponding set of jobs.  The general requirements are:
   * A downstream job (typically kicked off after the test job completes) that indicates whether there is a larger problem in your system and merges and/or tests can't take place currently
   * A `[test]` job should:
     * Setup an environment based on the current state of master + the pull request(s).  To perform the merge of the pull request you can use:
      ```
      test_pull_requests --local_merge_pull_request $PULL_ID --repo $REPO
      ```

     * Run any desired tests to prove the build and tests will pass if merged
   * A `[merge]` job should:
     * Setup an environment based on the current state of master + the pull request(s).  To perform the merge of the pull request you can use:
      ```
      test_pull_requests --local_merge_pull_request $PULL_ID --repo $REPO
      ```

     * Run any desired tests to prove the build and tests will pass if merged
     * Verify each tested pull request is still mergeable with:
      ```
      test_pull_requests --test_merge_pull_request $PULL_ID --repo $REPO
      ```

     * Merge each tested pull request with:
      ```
      test_pull_requests --merge_pull_request $PULL_ID --repo $REPO
      ```

 * Run `test_pull_requests` as a Jenkins or `cron` job.  Note that GitHub is rate limited but typical projects can still run this script every few mins without running out of requests.

Copyright
----------------------

OpenShift Origin, except where otherwise noted, is released under the
[Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).
