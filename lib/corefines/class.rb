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
      begin
        # Just try whether it raises exception...
        ::ObjectSpace.each_object(::Class.new) {}

        refine ::Class do
          def descendants
            descendants = []
            ::ObjectSpace.each_object(singleton_class) do |klass|
              descendants.unshift(klass) unless klass == self
            end
            descendants
          end
        end

      # Compatibility mode for JRuby when running without option -X+O.
      rescue StandardError

        refine ::Class do
          def descendants
            descendants = []
            ::ObjectSpace.each_object(::Class) do |klass|
              descendants.unshift(klass) if klass < self
            end
            descendants.uniq
          end
        end
      end
    end

    include Support::AliasSubmodules
  end
end
