require 'corefines/support/alias_submodules'

module Corefines
  module Module
    ##
    # @!method alias_class_method(new_name, old_name)
    #   Makes _new_name_ a new copy of the class method _old_name_.
    #
    #   @param new_name [Symbol] name of the new class method to create.
    #   @param old_name [Symbol] name of the existing class method to alias.
    #   @return [self]
    #
    module AliasClassMethod
      refine ::Module do
        def alias_class_method(new_name, old_name)
          singleton_class.__send__(:alias_method, new_name, old_name)
          self
        end
      end
    end

    ##
    # @!method alias_method_chain(target, feature)
    #   Encapsulates the common pattern of:
    #
    #     alias_method :meth_without_feature, :meth
    #     alias_method :meth, :meth_with_feature
    #
    #   With this, you simply do:
    #
    #     alias_method_chain :meth, :feature
    #
    #   for example:
    #
    #     class ChainExample
    #       def say
    #         "hello"
    #       end
    #       def say_with_accent
    #         "helloo!"
    #       end
    #       alias_method_chain :say, :accent
    #     end
    #
    #   and both aliases are set up for you:
    #
    #     example = ChainExample.new
    #     example.say #=> "helloo!"
    #     example.say_without_accent #=> "hello"
    #
    #   Query and bang methods (+foo?+, +foo!+) keep the same punctuation:
    #
    #     alias_method_chain :say!, :accent
    #
    #   is equivalent to:
    #
    #     alias_method :say_without_accent!, :say!
    #     alias_method :say!, :say_with_accent!
    #
    #   so you can safely chain +foo+, +foo?+, and +foo!+ with the same
    #   feature.
    #
    #   @param target [Symbol] name of the method to alias.
    #   @param feature [Symbol] suffix for the aliases.
    #   @return [self]
    #
    module AliasMethodChain
      refine ::Module do
        def alias_method_chain(target, feature)
          # Strip out punctuation on predicates, bang or writer methods since
          # e.g. target?_without_feature is not a valid method name.
          aliased_target, punctuation = target.to_s.sub(/([?!=])$/, ''), $1

          with_method = "#{aliased_target}_with_#{feature}#{punctuation}"
          without_method = "#{aliased_target}_without_#{feature}#{punctuation}"

          alias_method without_method, target
          alias_method target, with_method

          if public_method_defined? without_method
            public target
          elsif protected_method_defined? without_method
            protected target
          elsif private_method_defined? without_method
            private target
          end

          self
        end
      end
    end

    ##
    # @!method autocurry(*meth_names)
    #   Makes the specified methods auto-currying.
    #   If used with no parameters, subsequently defined methods become
    #   auto-currying.
    #
    #   @example Autocurry specified methods:
    #     class Foo
    #       def add(x, y, z)
    #         x + y + z
    #       end
    #       autocurry :add
    #     end
    #
    #   @example Autocurry all subsequently defined methods:
    #     class Foo
    #       autocurry
    #       def add(x, y, z)
    #         x + y + z
    #       end
    #     end
    #
    #   @example
    #     obj = Foo.new
    #
    #     obj.add(1, 2, 3)   # => 6
    #     obj.add(1)         # => #<Proc:0x123 (lambda)>
    #     obj.add(1).(2).(3) # => 6
    #     obj.add(1, 2).(3)  # => 6
    #     obj.add(1).(2, 3)  # => 6
    #
    #   @param *meth_names [Symbol] names of the methods to be autocurried.
    #   @return [self]
    #
    module Autocurry
      refine ::Module do
        def autocurry(*method_names)
          if method_names.empty?
            autocurry_subsequent
          else
            method_names.each { |name| autocurry_method(name) }
          end
          self
        end

        private

        def autocurry_method(name)
          orig_meth = instance_method(name)

          define_method(name) do |*args|
            orig_meth.bind(self).to_proc.curry.call(*args)
          end
        end

        # XXX is this thread safe?
        def autocurry_subsequent
          in_use = nil

          if singleton_class.respond_to?(:method_added, true)
            orig_method_added = method(:method_added)
          end

          define_singleton_method(:method_added) do |meth_name|
            return if in_use
            in_use = true
            autocurry_method(meth_name)
            in_use = false
            orig_method_added.call(meth_name) if orig_method_added
          end
        end
      end
    end

    include Support::AliasSubmodules
  end
end
