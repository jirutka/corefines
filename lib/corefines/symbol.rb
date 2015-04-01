require 'corefines/support/alias_submodules'

module Corefines
  module Symbol

    ##
    # @!method call(*args, &block)
    #   An useful extension for +&:symbol+ which makes it possible to pass
    #   arguments for method in a block
    #
    #   @example
    #     [1, 2, 3].map(&:to_s.(2)) #=> ['1', '10', '11']
    #     %w[Chloe Drew Uma].map(&:gsub.('e', 'E')) #=> %w[ChloE DrEw Uma]
    #
    #   @param *args arguments being passed to the method.
    #   @param block a block being passed to the method.
    #   @return [Proc] a proc that invokes the method, identified by this
    #     symbol and passing it the given arguments, on an object passed to it.
    #
    module Call
      refine ::Symbol do
        def call(*args, &block)
          proc do |recv|
            recv.__send__(self, *args, &block)
          end
        end
      end
    end

    include Support::AliasSubmodules
  end
end
