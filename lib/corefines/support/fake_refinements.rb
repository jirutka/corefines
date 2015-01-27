module Corefines
  module Support
    ##
    # @private
    # This module somehow mimics refinements on Ruby engines that doesn't
    # support them yet. It provides the same interface, but actually does just
    # plain monkey-patching.
    #
    # It's useful when you want to use refinements, but also need to support
    # older versions of Ruby, at least limited.
    #
    module FakeRefinements

      ##
      # Defines a faked "refinement".
      #
      # @param klass [Class] the class to refine.
      # @yield a block to be evaluated in the context of +klass+ when this module
      #   is passed into {#using}.
      # @return [self]
      #
      def refine(klass, &block)
        fail TypeError, "wrong argument type #{klass.class} (expected Class)" unless klass.is_a? ::Class
        fail ArgumentError, "no block given" unless block_given?

        (@__pending_refinements ||= []) << [klass, block]
        self
      end

      ##
      # Import class refinements from the module into the **global context.**
      #
      # This is just plain monkey-patching, so the changes are _not_ scoped
      # like when using real refinements! Therefore these "refinements" are
      # evaluated only once.
      #
      # @param mod [Module] the module that contains (faked) refinements.
      # @return [self]
      # @raise ArgumentError if the given module doesn't define any refinement.
      #
      def using(mod)
        # TODO make it thread-safe

        if mod.instance_variable_defined? :@__pending_refinements
          refinements = mod.instance_variable_get(:@__pending_refinements)

          return self if refinements.empty?

          refinements.each do |klass, block|
            klass.class_eval &block
          end

          mod.instance_variable_set(:@__pending_refinements, [])

        elsif mod.include? ::Corefines::Support::AliasSubmodules
          # Evaluate refinements from submodules recursively.
          mod.constants.each do |const|
            submodule = mod.const_get(const)
            using submodule if submodule.instance_of? ::Module
          end

        else
          fail ArgumentError, "#{mod} doesn't define any refinements"
        end

        self
      end
    end
  end
end

Module.send(:include, Corefines::Support::FakeRefinements)
