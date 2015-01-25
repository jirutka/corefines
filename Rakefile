require 'bundler/gem_tasks'

begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  task :test => :spec
  task :default => :spec

rescue LoadError => e
  warn "#{e.path} is not available"
end

begin
  require 'yard'

  # options are defined in .yardopts
  YARD::Rake::YardocTask.new(:yard)

rescue LoadError => e
  warn "#{e.path} is not available"
end
