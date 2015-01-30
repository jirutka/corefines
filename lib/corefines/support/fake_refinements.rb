module Corefines
  module Support
    ##
    # @private
    # Faked Refinements somehow mimics refinements on Ruby engines that doesn't
    # support them yet. It provides the same interface, but actually does just
    # plain monkey-patching; the changes are _not_ scoped like when using real
    # refinements.
    #
    # It's useful when you want to use refinements, but also need to support
    # older versions of Ruby, at least limited.
    #
    module FakeRefinements

      def self.define_refine(target)
        target.send(:define_method, :refine) do |klass, &block|
          fail TypeError, "wrong argument type #{klass.class} (expected Class)" unless klass.is_a? ::Class
          fail ArgumentError, "no block given" unless block

          (@__pending_refinements ||= []) << [klass, block]
          __refine__(klass) { module_eval &block } if respond_to?(:__refine__, true)

          self
        end
        target.send(:private, :refine)
      end

      def self.define_using(target)
        target.send(:define_method, :using) do |mod|
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
        target.send(:private, :using)
      end
    end
  end
end


unless Module.private_method_defined?(:using)

  # Refinements in MRI 2.0 allows calling 'using' only on top-level.
  if self.respond_to?(:using, true) && Module.private_method_defined?(:refine)
    warn "corefines: Your Ruby allows activiting refinements at top-level only, so 'using' at \
class/module/method level will fallback to plain monkey-patching (not scoped!)."

    Corefines::Support::FakeRefinements.define_using(Module)

    unless Module.private_method_defined?(:__refine__)
      Module.send(:alias_method, :__refine__, :refine)
    end
  else
    warn "corefines: Your Ruby doesn't support refinements, so I'll fake them using plain \
monkey-patching (not scoped!)."
    Corefines::Support::FakeRefinements.define_using(Object)
  end

  Corefines::Support::FakeRefinements.define_refine(Module)
end
