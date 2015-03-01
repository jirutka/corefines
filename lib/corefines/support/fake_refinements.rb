module Corefines
  module Support
    ##
    # @private
    # Faked Refinements somehow mimics refinements on Ruby engines that doesn't
    # support them yet. It provides the same interface, but actually does just
    # plain monkey-patching; the changes are *not* scoped like when using real
    # refinements.
    #
    # It's useful when you want to use refinements, but also need to support
    # older versions of Ruby, at least limited.
    #
    module FakeRefinements

      MUTEX = Mutex.new
      private_constant :MUTEX

      def self.define_refine(target)
        target.send(:define_method, :refine) do |klass, &block|
          fail TypeError, "wrong argument type #{klass.class} (expected Class)" unless klass.is_a? ::Class
          fail ArgumentError, "no block given" unless block

          MUTEX.synchronize do
            (@__pending_refinements ||= []) << [klass, block]
          end
          __refine__(klass) { module_eval &block } if respond_to?(:__refine__, true)

          self
        end
        target.send(:private, :refine)
      end

      def self.define_using(target)
        target.send(:define_method, :using) do |mod|
          refinements = mod.instance_variable_get(:@__pending_refinements)

          if refinements && !refinements.empty?
            MUTEX.synchronize do
              refinements.delete_if do |klass, block|
                klass.class_eval &block
                true
              end
            end
          end

          # Evaluate refinements from submodules recursively.
          mod.included_modules.each do |submodule|
            using submodule
          end

          self
        end
        target.send(:private, :using)
      end

      def self.alias_private_method(klass, new_name, old_name)
        return if !klass.private_method_defined?(old_name) ||
          klass.private_method_defined?(new_name)

        klass.send(:alias_method, new_name, old_name)
      end
    end
  end
end


# If Module doesn't define method +using+, then refinements are apparently not
# supported on this platform, or running on MRI 2.0 that allows +using+ only on
# top-level. Since refinements in MRI 2.0 are experimental and behaves
# differently than in later versions, we use "faked refinements" even so.
unless Module.private_method_defined? :using

  warn "corefines: Your Ruby doesn't support refinements, so I'll fake them \
using plain monkey-patching (not scoped!)."

  m = Corefines::Support::FakeRefinements

  # Define using on Module and the main object.
  [Module, self.singleton_class].each do |klass|
    m.alias_private_method(klass, :__using__, :using)
    m.define_using(klass)
  end

  m.alias_private_method(Module, :__refine__, :refine)
  m.define_refine(Module)
end
