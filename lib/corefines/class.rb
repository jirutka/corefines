require 'corefines/support/alias_submodules'

module Corefines
  module Class
    ##
    # @!method descendants
    #   @example
    #     Integer.descendants  # => [Fixnum, Bignum]
    #     Numeric.descendants  # => [Integer, Fixnum, Float, Bignum, Rational, Complex]
    #
    #   @return [Array<Class>] all descendants of this class.
    #
    module Descendants
      refine ::Class do
        def descendants
          descendants = []
          ::ObjectSpace.each_object(singleton_class) do |klass|
            descendants.unshift(klass) unless klass == self
          end
          descendants
        end
      end
    end

    include Support::AliasSubmodules
  end
end
