require 'corefines/support/alias_submodules'

module Corefines
  module Hash

    ##
    # @!method compact
    #   @example
    #     hash = { a: true, b: false, c: nil }
    #     hash.compact # => { a: true, b: false }
    #     hash # => { a: true, b: false, c: nil }
    #     { c: nil }.compact # => {}
    #
    #   @return [Hash] a new hash with no key-value pairs which value is +nil+.
    #
    # @!method compact!
    #   Removes all key-value pairs from the hash which value is +nil+.
    #   Same as {#compact}, but modifies +self+.
    #
    #   @return [Hash] self
    #
    module Compact
      refine ::Hash do
        def compact
          reject { |_, value| value.nil? }
        end

        def compact!
          delete_if { |_, value| value.nil? }
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
    #   @return [Hash] a new hash containing the contents of _other_hash_ and
    #     this hash. The value for entries with duplicate keys will be that of
    #     _other_hash_.
    #
    module OpPlus
      refine ::Hash do
        def +(other_hash)
          merge other_hash
        end
      end
    end

    ##
    # @!method rekey(key_map = nil, &block)
    #   Returns a new hash with keys transformed according to the given
    #   _key_map_ or the _block_.
    #
    #   If no _key_map_ or _block_ is given, then all keys are converted
    #   to +Symbols+, as long as they respond to +to_sym+.
    #
    #   @example
    #     hash = { :a => 1, 'b' => 2 }
    #     hash.rekey(:a => :x, :c => :y) # => { :x => 1, 'b' => 2 }
    #     hash.rekey(&:to_s) # => { 'a' => 1, 'b' => 2 }
    #     hash.rekey { |k| k.to_s.upcase } # => { 'A' => 1, 'B' => 2 }
    #     hash.rekey # => { :a => 1, :b => 2 }
    #
    #   @overload rekey(key_map)
    #     @param key_map [Hash] a translation map from the old keys to the new
    #       keys; <tt>{from_key => to_key, ...}</tt>.
    #
    #   @overload rekey
    #     @yield [key, value] gives every key-value pair to the block.
    #       The return value becomes a new key.
    #
    #   @return [Hash] a new hash.
    #   @raise ArgumentError if both _key_map_ and the _block_ are given.
    #
    # @!method rekey!(key_map = nil, &block)
    #   Transforms keys according to the given _key_map_ or the _block_.
    #   Same as {#rekey}, but modifies +self+.
    #
    #   @overload rekey!(key_map)
    #     @param key_map [Hash] a translation map from the old keys to the new
    #       keys; <tt>{from_key => to_key, ...}</tt>.
    #
    #   @overload rekey!
    #     @yield [key, value] gives every key-value pair to the block.
    #       The return value becomes a new key.
    #
    #   @return [Hash] self
    #   @raise (see #rekey)
    #
    module Rekey
      refine ::Hash do
        def rekey(key_map = nil, &block)
          fail ArgumentError, "provide key_map, or block, not both" if key_map && block
          block = ->(k, _) { k.to_sym rescue k } if !key_map && !block

          # Note: self.dup is used to preserve the default_proc.
          if block
            # This is needed for "symbol procs" (e.g. &:to_s).
            transform_key = block.arity.abs == 1 ? ->(k, _) { block[k] } : block

            each_with_object(dup.clear) do |(key, value), hash|
              hash[ transform_key[key, value] ] = value
            end
          else
            key_map.each_with_object(dup) do |(from, to), hash|
              hash[to] = hash.delete(from) if hash.key? from
            end
          end
        end

        def rekey!(key_map = nil, &block)
          replace rekey(key_map, &block)
        end
      end
    end

    ##
    # @!method symbolize_keys
    #   @example
    #     hash = { 'name' => 'Lindsey', :born => 1986 }
    #     hash.symbolize_keys # => { :name => 'Lindsey', :born => 1986 }
    #     hash # => { 'name' => 'Lindsey', :born => 1986 }
    #
    #   @return [Hash] a new hash with all keys converted to symbols, as long
    #     as they respond to +to_sym+.
    #
    # @!method symbolize_keys!
    #   Converts all keys to symbols, as long as they respond to +to_sym+.
    #   Same as {#symbolize_keys}, but modifies +self+.
    #
    #   @return [Hash] self
    #
    module SymbolizeKeys
      refine ::Hash do
        def symbolize_keys
          each_with_object(dup.clear) do |(key, value), hash|
            hash[(key.to_sym rescue key)] = value
          end
        end

        def symbolize_keys!
          keys.each do |key|
            self[(key.to_sym rescue key)] = delete(key)
          end
          self
        end
      end
    end

    include Support::AliasSubmodules

    class << self
      alias_method :compact!, :compact
      alias_method :rekey!, :rekey
      alias_method :symbolize_keys!, :symbolize_keys
    end
  end
end
