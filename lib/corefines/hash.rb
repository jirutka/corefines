module Corefines
  module Hash
    ##
    # @!method map_send(method_name, *args, &block)
    #   (see Array::MapSend#map_send)
    #
    module MapSend
      refine ::Hash do
        def map_send(method_name, *args, &block)
          map { |e| e.send(method_name, *args, &block) }
        end
      end
    end

    ##
    # @!method +(other_hash)
    #   Alias for +#merge+.
    #
    #   @example
    #     {a: 1, b: 2} + {b: 3, c: 4}
    #      => {a: 1, b: 3, c: 4}
    #
    #   @param other_hash [Hash]
    #   @return [Hash] a new hash containing the contents of +other_hash+ and
    #     this hash. The value for entries with duplicate keys will be that of
    #     +other_hash+.
    #
    module OpPlus
      refine ::Hash do
        def +(other_hash)
          merge other_hash
        end
      end
    end

    include Support::AliasSubmodules
  end
end
