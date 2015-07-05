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
    # @!method many?
    #   Returns +true+ if the enumerable has more than one element.
    #
    #   This method is functionally equivalent to <tt>enum.to_a.size > 1</tt>,
    #   or <tt>enum.select { ... }.length > 1</tt> when the block is given.
    #
    #   @example
    #     [1].many?             # => false
    #     [1, 2].many?          # => true
    #     [1, 2, 3].many?       # => true
    #     [1, nil].many?        # => true
    #     [1, 2, 3].many? { |n| n > 2 }  # => false
    #
    #   @overload many?
    #     @return [Boolean] +true+ if the enumerable has more than one element.
    #
    #   @overload many?(&block)
    #     @yield [obj] gives each element to the block.
    #     @return [Boolean] +true+ if the block returns a truthy value (i.e.
    #       other than +nil+ and +false+) more than once.
    #
    module Many
      Support.classes_including_module(::Enumerable) do |klass|

        refine klass do
          def many?
            cnt = 0
            if block_given?
              any? do |element|
                cnt += 1 if yield element
                cnt > 1
              end
            else
              any? { (cnt += 1) > 1 }
            end
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

    ##
    # @!method map_to(klass)
    #   Maps each element of this _enum_ into the _klass_ via constructor.
    #
    #   @example
    #     ['/tmp', '/var/tmp'].map_to(Pathname) # => [#<Pathname:/tmp>, #<Pathname:/var/tmp>]
    #
    #   @param klass [#new] the klass to map each element to.
    #   @return [Enumerable] a new array with instances of the _klass_ for
    #     every element in _enum_.
    #
    module MapTo
      Support.classes_including_module(::Enumerable) do |klass|

        refine klass do
          def map_to(klass)
            map { |e| klass.new(e) }
          end
        end
      end
    end

    include Support::AliasSubmodules

    class << self
      alias_method :many?, :many
    end
  end
end
