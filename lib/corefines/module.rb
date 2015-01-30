require 'corefines/support/alias_submodules'

module Corefines
  module Module
    ##
    # @!method alias_class_method(new_name, old_name)
    #   Makes +new_name+ a new copy of the class method +old_name+.
    #
    #   @param new_name [Symbol] name of the new class method to create.
    #   @param old_name [Symbol] name of the existing class method to alias.
    #   @return [self]
    #
    module AliasClassMethod
      refine ::Module do
        def alias_class_method(new_name, old_name)
          singleton_class.send(:alias_method, new_name, old_name)
          self
        end
      end
    end

    include Support::AliasSubmodules
  end
end
