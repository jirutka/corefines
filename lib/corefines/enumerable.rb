require 'corefines/support/alias_submodules'
require 'corefines/support/classes_including_module'

module Corefines
  module Enumerable

    ##
    # @!method index_by
    #   Convert enumerable into a Hash, iterating over each element where the
    #   provided block must return the key to be used to map to the value.
    #
    #   It's similar to {::Enumerable#group_by}, but when two elements
    #   corresponds to the same key, then only the last one is preserved in the
    #   resulting Hash.
    #
    #   @example
    #     people.index_by(&:login)
    #     => { "flynn" => <Person @login="flynn">, "bradley" => <Person @login="bradley">, ...}
    #
    #   @example
    #     people.index_by.each(&:login)
    #     => { "flynn" => <Person @login="flynn">, "bradley" => <Person @login="bradley">, ...}
    #
    #   @yield [obj] gives each element to the block.
    #   @yieldreturn the key to be used to map to the value.
    #   @return [Hash]
    #
    module IndexBy
      Support.classes_including_module(::Enumerable) do |klass|

        refine klass do
          def index_by
            ::Hash[map { |elem| [ yield(elem), elem ] }]
          end
        end
      end
    end

    ##
    # @!method map_send(method_name, *args, &block)
    #   Sends a message to each element and collects the result.
    #
    #   @example
    #     [1, 2, 3].map_send(:+, 3) #=> [4, 5, 6]
    #
    #   @param method_name [Symbol] name of the method to call.
    #   @param args arguments to pass to the method.
    #   @param block [Proc] block to pass to the method.
    #   @return [Enumerable]
    #
    module MapSend
      Support.classes_including_module(::Enumerable) do |klass|

        refine klass do
          def map_send(method_name, *args, &block)
            map { |e| e.__send__(method_name, *args, &block) }
          end
        end
      end
    end

    include Support::AliasSubmodules
  end
end
