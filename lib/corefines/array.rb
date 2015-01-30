require 'corefines/support/alias_submodules'

module Corefines
  module Array
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
      refine ::Array do
        def map_send(method_name, *args, &block)
          map { |e| e.send(method_name, *args, &block) }
        end
      end
    end

    ##
    # @!method self.wrap(object)
    #   Wraps its argument in an array unless it is already an array (or
    #   array-like).
    #
    #   Specifically:
    #
    #   * If the argument is +nil+ an empty list is returned.
    #   * Otherwise, if the argument responds to +to_ary+ it is invoked, and
    #     its result returned.
    #   * Otherwise, returns an array with the argument as its single element.
    #
    #   @example
    #     Array.wrap(nil) # => []
    #     Array.wrap([1, 2, 3]) # => [1, 2, 3]
    #     Array.wrap(0) # => [0]
    #
    #   This method is similar in purpose to <tt>Kernel#Array</tt>, but there
    #   are some differences:
    #
    #   * If the argument responds to +to_ary+ the method is invoked.
    #     <tt>Kernel#Array</tt> moves on to try +to_a+ if the returned value is
    #     +nil+, but <tt>Array.wrap</tt> returns +nil+ right away.
    #   * If the returned value from +to_ary+ is neither +nil+ nor an +Array+
    #     object, <tt>Kernel#Array</tt> raises an exception, while
    #     <tt>Array.wrap</tt> does not, it just returns the value.
    #   * It does not call +to_a+ on the argument, but returns an empty array
    #     if argument is +nil+.
    #
    #   The second point is easily explained with some enumerables:
    #
    #     Array(foo: :bar) # => [[:foo, :bar]]
    #     Array.wrap(foo: :bar) # => [{:foo=>:bar}]
    #
    #   There's also a related idiom that uses the splat operator:
    #
    #     [*object]
    #
    #   which returns <tt>[]</tt> for +nil+, but calls to
    #   <tt>Array(object)</tt> otherwise.
    #
    #   The differences with <tt>Kernel#Array</tt> explained above apply to the
    #   rest of <tt>object</tt>s.
    #
    #   @return [Array]
    #
    module Wrap
      refine ::Array.singleton_class do
        def wrap(object)
          if object.nil?
            []
          elsif object.respond_to? :to_ary
            object.to_ary || [object]
          else
            [object]
          end
        end
      end
    end

    include Support::AliasSubmodules
  end
end
