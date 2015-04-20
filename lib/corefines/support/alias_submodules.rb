module Corefines
  module Support
    ##
    # @private
    # When this module is included, then it:
    #
    # 1. Defines an "alias" for each submodule, i.e. singleton method that
    #    returns the submodule and it's named after the submodule, but the name
    #    is converted to underscore_separated or an operator. For example,
    #    instead of <tt>using Corefines::String::ToHtml</tt> one can write
    #    <tt>using Corefines::String::to_html</tt>.
    #
    # 2. Includes all the submodules into the module. This allows to use all
    #    refinements inside the submodules just by _using_ their parent module.
    #
    # 3. Defines method {[]}.
    #
    # @!method self.[](*names)
    #   @example
    #     Corefines::Object[:blank?, :then]
    #
    #   @param names [Array<Symbol>] names of submodules aliases to include
    #     into the returned module.
    #   @return [Module] a new module that includes the named submodules.
    #
    module AliasSubmodules

      OPERATORS_MAP = {
        :op_add    => :+,
        :op_sub    => :-,
        :op_pow    => :**,
        :op_mul    => :*,
        :op_div    => :/,
        :op_mod    => :%,
        :op_tilde  => :~,
        :op_cmp    => :<=>,
        :op_lshift => :<<,
        :op_rshift => :>>,
        :op_lt     => :<,
        :op_gt     => :>,
        :op_case   => :===,
        :op_equal  => :==,
        :op_apply  => :=~,
        :op_lt_eq  => :<=,
        :op_gt_eq  => :>=,
        :op_or     => :|,
        :op_and    => :&,
        :op_xor    => :^,
        :op_store  => :[]=,
        :op_fetch  => :[]
      }

      private

      def self.included(target)
        target.constants.each do |const|
          submodule = target.const_get(const)
          next unless submodule.instance_of? ::Module

          # Defines method-named "alias" for the submodule. (1)
          target.define_singleton_method(method_name(const)) { submodule }

          # Includes the submodule of the target into target. (2)
          target.send(:include, submodule)
        end

        target.extend ClassMethods
      end

      def self.method_name(module_name)
        name = underscore(module_name)
        OPERATORS_MAP[name.to_sym] || name
      end

      def self.underscore(camel_cased_word)
        return camel_cased_word unless camel_cased_word =~ /[A-Z]/

        camel_cased_word.to_s.dup.tap do |s|
          s.gsub! /([A-Z\d]+)([A-Z][a-z])/, '\1_\2'
          s.gsub! /([a-z\d])([A-Z])/, '\1_\2'
          s.downcase!
        end
      end


      module ClassMethods

        def [](*names)
          ::Module.new.tap do |mod|
            names.each do |mth|
              unless respond_to? mth
                fail ArgumentError, "no such refinements submodule with alias '#{mth}'"
              end
              mod.send(:include, public_send(mth))
            end
          end
        end
      end

      private_constant :ClassMethods, :OPERATORS_MAP
    end
  end
end
