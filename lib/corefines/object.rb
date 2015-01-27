module Corefines
  module Object
    ##
    # @!method blank?
    #   An object is blank if it's +false+, empty, or a whitespace string.
    #   For example, <tt>'', '   ', "\t\n\r", "\u00a0", +nil+, [], {}</tt> are
    #   all blank.
    #
    #   This simplifies
    #
    #     address.nil? || address.empty?
    #
    #   to
    #
    #     address.blank?
    #
    #   @return [Boolean]
    #
    module Blank
      refine ::Object do
        def blank?
          respond_to?(:empty?) ? !!empty? : !self
        end
      end

      refine ::NilClass do
        def blank?
          true
        end
      end

      refine ::FalseClass do
        def blank?
          true
        end
      end

      refine ::TrueClass do
        def blank?
          false
        end
      end

      refine ::Array do
        alias_method :blank?, :empty?
      end

      refine ::Hash do
        alias_method :blank?, :empty?
      end

      refine ::Numeric do
        def blank?
          false
        end
      end

      refine ::String do
        BLANK_RE = /\A[[:space:]]*\z/

        def blank?
          BLANK_RE === self
        end
      end
    end

    ##
    # @!method then
    #   Passes +self+ to the block and returns its result.
    #
    #   @yield [self] Passes +self+ to the block.
    #   @return [Object] evaluation of the block, or +self+ if no block given
    #     or +self+ is +nil+.
    #
    module Then
      refine ::Object do
        def then
          if block_given? && !self.nil?
            yield self
          else
            self
          end
        end
      end
    end

    include Support::AliasSubmodules

    class << self
      alias_method :blank?, :blank
    end
  end
end
