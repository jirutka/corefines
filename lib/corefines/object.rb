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
    # @!method else
    #   Returns +self+ if +self+ evaluates to +true+, otherwise returns the
    #   evaluation of the block.
    #
    #   @yield [self] gives +self+ to the block.
    #   @return [Object] +self+ if +self+ evaluates to +true+, otherwise
    #     returns the evaluation of the block.
    #
    module Else
      refine ::Object do
        def else
          self ? self : yield(self)
        end
      end
    end

    ##
    # @!method in?(other)
    #   @example Array
    #     characters = ["Konata", "Kagami", "Tsukasa"]
    #     "Konata".in?(characters) # => true
    #
    #   @example String
    #     "f".in?("flynn") # => true
    #     "x".in?("flynn") # => false
    #
    #   @param other [#include?]
    #   @return [Boolean] +true+ if this object is included in the +other+
    #     object, +false+ otherwise.
    #   @raise ArgumentError if the +other+ doesn't respond to +#include?+.
    #
    module In
      refine ::Object do
        def in?(other)
          other.include? self
        rescue NoMethodError
          fail ArgumentError, "The parameter passed to #in? must respond to #include?"
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
          ary = instance_variables.map do |name|
            [ name[1..-1].to_sym, instance_variable_get(name) ]
          end
          ::Hash[ary]
        end
      end
    end

    ##
    # @!method then
    #   Returns +self+ if +self+ evaluate to +false+, otherwise returns
    #   evaluation of the block.
    #
    #   This simplifies something like:
    #
    #     if m = "Flynn <flynn@encom.com>".match(/<([^>]+)>/)
    #       m[1]
    #     end
    #
    #   to:
    #
    #     "Flynn <flynn@encom.com>".match(/<([^>]+)>/).then { |m| m[1] }
    #
    #
    #   Since +then+ passes +self+ to the block, it can be also used for
    #   chaining, so something like:
    #
    #     html = parse_html(input)
    #     html = find_nodes(html, "//section")
    #     html = remove_nodes(html, "//p")
    #
    #   can be rewritten to:
    #
    #     parse_html(input)
    #       .then { |h| find_nodes(h, "//section") }
    #       .then { |h| remove_nodes(h, "//p") }
    #
    #   @yield [self] gives +self+ to the block.
    #   @return [Object] evaluation of the block, or +self+ if no block given
    #     or +self+ evaluates to false.
    #
    module Then
      refine ::Object do
        def then
          if block_given? && self
            yield self
          else
            self
          end
        end
      end
    end

    ##
    # @!method then_if(*conditions)
    #   Returns +self+ if +self+ or any of the +conditions+ evaluates to
    #   +false+, otherwise returns the evaluation of the block.
    #
    #   @example
    #     "foo".then_if(:empty?) { "N/A" } # => "foo"
    #        "".then_if(:empty?) { "N/A" } # => "N/A"
    #
    #   Each condition may be of the type:
    #   * +Symbol+ - name of the method to be invoked using +public_send+.
    #   * +Array+  - name of the method followed by arguments to be invoked
    #     using +public_send+.
    #   * +Proc+   - proc to be called with +self+ as the argument.
    #   * Any other object to be evaluated as +true+, or +false+.
    #
    #   @param *conditions conditions to evaluate.
    #   @yield [self] gives +self+ to the block.
    #   @return [Object] evaluation of the block, or +self+ if any condition
    #     evaluates to +false+, or no condition given and +self+ evaluates to
    #     +false+.
    #
    module ThenIf
      refine ::Object do
        def then_if(*conditions)
          return self if conditions.empty? && !self
          return self unless conditions.all? do |arg|
            case arg
            when ::Symbol then public_send(arg)
            when ::Array then public_send(*arg)
            when ::Proc then arg.call(self)
            else arg
            end
          end
          yield self
        end
      end
    end

    ##
    # @!method try(method, *args, &block)
    #   Invokes the public method identified by the symbol +method+, passing it
    #   any arguments and/or the block specified, just like the regular Ruby
    #   +public_send+ does.
    #
    #   *Unlike* that method however, a +NoMethodError+ exception will *not* be
    #   be raised and +nil+ will be returned instead, if the receiving object
    #   doesn't respond to the +method+.
    #
    #   This method is defined to be able to write:
    #
    #     @person.try(:name)
    #
    #   instead of:
    #
    #     @person.name if @person
    #
    #   +try+ calls can be chained:
    #
    #     @person.try(:spouse).try(:name)
    #
    #   instead of:
    #
    #     @person.spouse.name if @person && @person.spouse
    #
    #   +try+ will also return +nil+ if the receiver does not respond to the
    #   method:
    #
    #     @person.try(:unknown_method) # => nil
    #
    #   instead of:
    #
    #     @person.unknown_method if @person.respond_to?(:unknown_method) # => nil
    #
    #   +try+ returns +nil+ when called on +nil+ regardless of whether it
    #   responds to the method:
    #
    #     nil.try(:to_i) # => nil, rather than 0
    #
    #   Arguments and blocks are forwarded to the method if invoked:
    #
    #     @posts.try(:each_slice, 2) do |a, b|
    #       ...
    #     end
    #
    #   The number of arguments in the signature must match. If the object
    #   responds to the method, the call is attempted and +ArgumentError+ is
    #   still raised in case of argument mismatch.
    #
    #   Please also note that +try+ is defined on +Object+. Therefore, it won't
    #   work with instances of classes that do not have +Object+ among their
    #   ancestors, like direct subclasses of +BasicObject+. For example, using
    #   +try+ with +SimpleDelegator+ will delegate +try+ to the target instead
    #   of calling it on the delegator itself.
    #
    #   @param method [Symbol] name of the method to invoke.
    #   @param args arguments to pass to the +method+.
    #   @return [Object, nil] result of calling the +method+, or +nil+ if
    #     doesn't respond to it.
    #
    # @!method try!(method, *args, &block)
    #   Same as {#try}, but raises a +NoMethodError+ exception if the receiver
    #   is not +nil+ and does not implement the tried method.
    #
    #   @example
    #     "a".try!(:upcase) # => "A"
    #     nil.try!(:upcase) # => nil
    #     123.try!(:upcase) # => NoMethodError: undefined method `upcase' for 123:Fixnum
    #
    #   @param method (see #try)
    #   @param args (see #try)
    #   @return (see #try)
    #
    module Try
      refine ::Object do
        def try(method = nil, *args, &block)
          try!(method, *args, &block) if respond_to? method
        end

        def try!(method = nil, *args, &block)
          public_send method, *args, &block
        end
      end

      refine ::NilClass do
        def try(*args)
          nil
        end

        def try!(*args)
          nil
        end
      end
    end

    include Support::AliasSubmodules

    class << self
      alias_method :blank?, :blank
      alias_method :in?, :in
      alias_method :presence, :blank
      alias_method :try!, :try
    end
  end
end
