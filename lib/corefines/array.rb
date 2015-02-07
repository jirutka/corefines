require 'corefines/support/alias_submodules'

module Corefines
  module Array

    ##
    # @!method second
    #   @return the second element, or +nil+ if doesn't exist.
    module Second
      refine ::Array do
        def second
          self[1]
        end
      end
    end

    ##
    # @!method third
    #   @return the third element, or +nil+ if doesn't exist.
    module Third
      refine ::Array do
        def third
          self[2]
        end
      end
    end

    include Support::AliasSubmodules
  end
end
