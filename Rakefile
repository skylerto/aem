require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yaml'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :deploy do
  task :nexus do
    nexus = YAML.load_file('secrets.yaml')['nexus']
    name = 'aem-0.1.0.gem'
    file = 'pkg/aem-0.1.0.gem'
    url = "#{nexus['url']}#{name}"
    cmd = `curl -v -u #{nexus['username']}:#{nexus['password']} --upload-file #{file} #{url}`
    exit_status = $?.exitstatus
    if exit_status != 0
      puts 'Could not deploy!'
    end
    puts cmd
  end
end
