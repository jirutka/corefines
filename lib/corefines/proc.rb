require 'corefines/support/alias_submodules'

module Corefines
  module Proc

    ##
    # @!method >>(#call)
    #   Creates a left-to-right function composition of this Proc with the
    #   given _callable_.
    #
    #   Function composition is the act of pipelining the result of one
    #   function, to the input of another, creating an entirely new function.
    #   This method similar to the dot operator in Haskell, but reversed; it's
    #   called a pipe operator in some languages.
    #
    #   For example <tt>(f >> g >> e).(x)</tt> is equivalent to +e(g(f(x)))+.
    #
    #   @param callable [#call] the right side of composition. It may be
    #          a +Proc+ or any object that responds to +#call+.
    #   @return [Proc] a lambda that is a left-to-right composition of this
    #           Proc with the given _callable_.
    #
    module OpRshift
      refine ::Proc do
        def >>(callable)
          ->(*args) { callable.call(self.call(*args)) }
        end
      end
    end

    include Support::AliasSubmodules
  end
end
