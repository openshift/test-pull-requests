require 'rubygems'

$stdout.sync = true
$stderr.sync = true

namespace :test_pull_requests do

  desc "Check syntax"
  task :check_syntax do

    syntax_check_cmd = %{
set -e
ruby -c test_pull_requests >/dev/null;
}
    `#{syntax_check_cmd}`
    if $?.exitstatus != 0
      exit 1
    end
  end
end

task :default => "test_pull_requests:check_syntax"
