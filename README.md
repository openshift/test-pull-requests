Test Pull Requests
==================

[![TravisCI](https://travis-ci.org/openshift/test-pull-requests.svg?branch=master)](https://travis-ci.org/openshift/test-pull-requests)

Utility for serially testing and merging pull requests in conjunction with Jenkins.

## Requirements
 * At least Ruby 2.1.x
 * A Github account

## Typical User Workflow
 * Write some code, fix bugs locally, submit your pull requests
 * Get your changes reviewed
 * If you aren't sure of your changes, perhaps because of a complicated merge, you'll want to force your changes through verification tests before attempting to merge and perhaps before they get reviewed.  You may also want to do this to show the results to the reviewer.
   * You (or anyone in an authorized GitHub team) can do this by adding the case insensitive string `[test]` to a comment or the title of your pull request.
   * If you have prereq/coreq pull requests, you can add their urls (Ex: ​https://github.com/openshift/origin-server/pull/1) to the comments (one per repo supported), and they will be automatically included in the testing.
   * The results of the test will be put in the pull request. If they don't pass, you'll need to fix the issues before continuing
 * Similar to the `[test]` flag above, you must add the `[merge]` flag to the title or a comment of the pull request.  This is the only way you should be getting your changes into the master or stage branches.  The merge flag (handles prereqs the same as `[test]`) builds and installs your changes with the exact source on the target branch that passed the previous tests. This is done serially so your changes are the only changes since the last successful build. After the tests pass your pull request(s) (including prereqs in comments) are merged into master. Note: if you make changes to your pull request(s) after tests start, your merge will fail and the tests will be retried.
 * If flake identification is enabled for a flag, failed jobs will require explanation from users. If a pull request has a failed job and no new code has been pushed, someone will have to link to a valid GitHub issue that explains a test flake causing that job to fail. Administrators can over-ride this system by re-triggering the job.

### Permissions
 * `[merge]` and `[test]` flags are only listened to for trusted users (in comments or titles) and are only supported for the configured branches.
 * Retries will automatically occur if a pull request is updated after a failure as long as the owner of the pull request is trusted.  So for example, if you tag a pull request with `[merge]` for a non trusted user, then they add code to the commit. It will fail on merge because they updated after the tests were started and will not retry until another `[merge]` tag is added/updated by a trusted user.  Trusted users are determined per test group and you can have multiple GitHub teams assigned to the same repo.
 * Only administrators are allowed to override the flake identification feature. Adminstrators are not guaranteed to be trusted users, or vice versa.


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

### Additional considerations for RHEL
 * Your version of RHEL might not have a recent Ruby by default. To work around this, you can:
   * enable the Software Collections (SCL) repos and install `scl-utils`, and the Ruby version of your choice, e.g. `rh-ruby23` and `rh-ruby23-rubygems`
   * run `test_pull_requests` like:
   ```
   echo "test_pull_requests --SOME_OPTIONS" | scl enable rh-ruby23 -
   ```

### Setup for merge_queue_overview
 * Add `merge_queue_overview` to your Jenkins system and make sure it's executable
 * Add `.merge_queue_overview.json` to `$JENKINS_HOME`
 * Create the `merge_queue_records` directory under `$JENKINS_HOME` and make sure the `jenkins` user can write to it.
 * Create the `templates` directory - e.g. under `$JENKINS_HOME` - and make sure the `jenkins` user can read it.
   * Copy the content of the `templates` repo directory here
 * Create the output directory for the generated HTML - e.g. `/var/www/html/merge_queue/` - and make sure the `jenkins` user can write to it.
   * Create the `assets` directory under the output directory and copy the contents of the `assets` directory in the repo to it.
 * Configure `.merge_queue_overview.json` for your system. You need to speciffy:
   * `merge_queue_properties_location`: The location of the corresponding `test_pull_requests.json`
   * `merge_queue_name`: A friendly name for the merge queue, to be displayed in the page title and elsewhere
   * `logo_url`: The URL where the appropriate logo can be loaded
   * `output_directory`: The directory for the generated HTML
   * `template_directory`: The directory you copied the ERB templates into
 * Run `merge_queue_overview` in your Jenkins or `cron` job after a successful `test_pull_requests` run, like:
```
  merge_queue_overview --config ~/.merge_queue_overview.json > \
    /var/www/html/merge_queue/test_pull_requests.html
```

Copyright
----------------------

OpenShift Origin, except where otherwise noted, is released under the
[Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).
