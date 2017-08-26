RSpec.configure do |config|

  # rspec-expectations config
  config.expect_with :rspec do |expects|

    # This option disables deprecated 'should' syntax.
    expects.syntax = :expect

    # This option makes the +description+ and +failure_message+ of custom
    # matchers include text for helper methods defined using +chain+, e.g.:
    # be_bigger_than(2).and_smaller_than(4).description
    #   # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #   # => "be bigger than 2"
    expects.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config
  config.mock_with :rspec do |mocks|

    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object.
    mocks.verify_partial_doubles = true
  end

  config.color = true
end

unless RUBY_ENGINE == 'jruby'
  require 'simplecov'

  SimpleCov.start do
    add_filter '/spec/'
  end
end

require 'corefines'
