require 'codeclimate-test-reporter'

formatters = [SimpleCov::Formatter::HTMLFormatter]
formatters << CodeClimate::TestReporter::Formatter if ENV['CODECLIMATE_REPO_TOKEN']

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(*formatters)
SimpleCov.start do
  add_filter '/spec/'
end
