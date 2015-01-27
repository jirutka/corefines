module Corefines
  module Array
    ##
    # @!method map_send(method_name, *args, &block)
    #   Sends a message to each element and collects the result.
    #
    #   @example
    #     [1, 2, 3].map_send(:+, 3) #=> [4, 5, 6]
    #
    #   @param method_name [Symbol] name of the method to call.
    #   @param args arguments to pass to the method.
    #   @param block [Proc] block to pass to the method.
    #   @return [Enumerable]
    #
    module MapSend
      refine ::Array do
        def map_send(method_name, *args, &block)
          map { |e| e.send(method_name, *args, &block) }
        end
      end
    end

    include Support::AliasSubmodules
  end
end
