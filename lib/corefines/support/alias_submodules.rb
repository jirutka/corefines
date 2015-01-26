module Corefines
  module Support
    ##
    # @private
    # When this module is included, then it:
    #
    # 1. Defines an "alias" for each submodule, i.e. singleton method that
    #    returns the submodule and its named after the submodule, but the name
    #    is converted to underscore_separated. For example,
    #    instead of <tt>using Corefines::String::ToHtml</tt> one can write
    #    <tt>using Corefines::String::to_html</tt>.
    #
    # 2. Includes all the submodules into the module. This allows to use all
    #    refinements inside the submodules just by _using_ their parent module.
    #
    # 3. Defines method +*+ that returns itself. This is just a syntactic sugar
    #    to allow <tt>using Corefines::A::*</tt>, which is the same as
    #    +using Corefines::A+, but communicates the intention better.
    #
    module AliasSubmodules

      private

      def self.included(target)
        target.constants.each do |const|
          submodule = target.const_get(const)
          next unless submodule.instance_of? ::Module

          # Defines method-named "alias" for the submodule. (1)
          target.define_singleton_method(underscore(const)) { submodule }

          # Includes the submodule of the target into target. (2)
          target.send(:include, submodule)
        end

        # Defines method * that returns itself. (3)
        target.define_singleton_method(:*) { target }
      end

      def self.underscore(camel_cased_word)
        return camel_cased_word unless camel_cased_word =~ /[A-Z]/

        camel_cased_word.to_s.dup.tap do |s|
          s.gsub! /([A-Z\d]+)([A-Z][a-z])/, '\1_\2'
          s.gsub! /([a-z\d])([A-Z])/, '\1_\2'
          s.downcase!
        end
      end
    end
  end
end
