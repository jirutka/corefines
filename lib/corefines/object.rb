require 'corefines/support/alias_submodules'

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
    # @!method presence
    #   Returns object if it's not {#blank?}, otherwise returns +nil+.
    #   +obj.presence+ is equivalent to <tt>obj.blank? ? nil : obj</tt>.
    #
    #   This is handy for any representation of objects where blank is the same
    #   as not present at all. For example, this simplifies a common check for
    #   HTTP POST/query parameters:
    #
    #     state = params[:state] if params[:state].present?
    #     country = params[:country] if params[:country].present?
    #     region = state || country || 'CZ'
    #
    #   becomes...
    #
    #     region = params[:state].presence || params[:country].presence || 'CZ'
    #
    #   @return [Object, nil] object if it's not {#blank?}, otherwise +nil+.
    #
    module Blank
      refine ::Object do
        def blank?
          respond_to?(:empty?) ? !!empty? : !self
        end

        def presence
          self unless blank?
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
    # @!method instance_values
    #   @example
    #     class C
    #       def initialize(x, y)
    #         @x, @y = x, y
    #       end
    #     end
    #
    #     C.new(0, 1).instance_values
    #     => {x: 0, y: 1}
    #
    #   @return [Hash] a hash with symbol keys that maps instance variable
    #     names without "@" to their corresponding values.
    #
    module InstanceValues
      refine ::Object do
        def instance_values
          instance_variables.map { |name|
            [ name[1..-1].to_sym, instance_variable_get(name) ]
          }.to_h
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
      alias_method :presence, :blank
    end
  end
end
