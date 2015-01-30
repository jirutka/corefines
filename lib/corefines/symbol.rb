require 'corefines/support/alias_submodules'

module Corefines
  module Symbol
    ##
    # @!method ~
    #   Alias for +#to_proc+.
    #
    #   @example
    #     case num
    #     when ~:zero?
    #       ...
    #     when ~:odd?
    #       ...
    #     when ~:even?
    #       ...
    #     end
    #
    #  @return [Proc] a Proc object which respond to the given method by +sym+.
    #
    module OpTilde
      refine ::Symbol do
        alias_method :~, :to_proc
      end
    end

    include Support::AliasSubmodules
  end
end
