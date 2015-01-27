module Corefines
  module Set
    ##
    # @!method map_send(method_name, *args, &block)
    #   (see Array::MapSend#map_send)
    #
    module MapSend
      refine ::Set do
        def map_send(method_name, *args, &block)
          map { |e| e.send(method_name, *args, &block) }
        end
      end
    end

    include Support::AliasSubmodules
  end
end
