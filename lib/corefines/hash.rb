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
    # @!method except(*keys)
    #   @example
    #     hash = { a: 1, b: 2, c: 3, d: 4 }
    #     hash.except(:a, :d)  # => { b: 2, c: 3 }
    #     hash  # => { a: 1, b: 2, c: 3, d: 4 }
    #
    #   @param *keys the keys to exclude from the hash.
    #   @return [Hash] a new hash without the specified key/value pairs.
    #
    # @!method except!(*keys)
    #   Removes the specified keys/value pairs in-place.
    #
    #   @example
    #     hash = { a: 1, b: 2, c: 3, d: 4 }
    #     hash.except(:a, :d)  # => { b: 2, c: 3 }
    #     hash  # => { b: 2, c: 3 }
    #
    #   @see #except
    #   @param *keys (see #except)
    #   @return [Hash] a hash containing the removed key/value pairs.
    #
    module Except
      refine ::Hash do
        def except(*keys)
          keys.each_with_object(dup) do |k, hash|
            hash.delete(k)
          end
        end

        def except!(*keys)
          keys.each_with_object(dup.clear) do |k, deleted|
            deleted[k] = delete(k) if has_key? k
          end
        end
      end
    end

    ##
    # @!method flat_map(&block)
    #   Returns a new hash with the merged results of running the _block_ once
    #   for every entry in +self+.
    #
    #   @example
    #     hash = { a: 1, b: 2, c: 3 }
    #     hash.flat_map { |k, v| {k => v * 2, k.upcase => v} if v % 2 == 1 }
    #     # => { a: 2, A: 1, c: 6, C: 3 }
    #     hash.flat_map { |k, v| [[k, v * 2], [k.upcase => v]] if v % 2 == 1 }
    #     # => { a: 2, A: 1, c: 6, C: 3 }
    #
    #   @yield [key, value] gives every key-value pair to the block.
    #   @yieldreturn [#to_h, Array, nil] an object that will be interpreted as
    #     a Hash and merged into the result, or nil to omit this key-value.
    #   @return [Hash] a new hash.
    module FlatMap
      refine ::Hash do
        def flat_map
          each_with_object({}) do |(key, value), hash|
            yielded = yield(key, value)

            if yielded.is_a? ::Hash
              hash.merge!(yielded)
            elsif yielded.is_a? ::Array
              # Array#to_h exists since Ruby 2.1.
              yielded.each do |pair|
                hash.store(*pair)
              end
            elsif yielded
              hash.merge!(yielded.to_h)
            end
          end
        end
      end
    end

    ##
    # @!method only(*keys)
    #   @example
    #     hash = { a: 1, b: 2, c: 3, d: 4 }
    #     hash.only(:a, :d)  # => { a: 1, d: 4 }
    #     hash  # => { a: 1, b: 2, c: 3, d: 4 }
    #
    #   @param *keys the keys to include in the hash.
    #   @return [Hash] a new hash with only the specified key/value pairs.
    #
    # @!method only!(*keys)
    #   Removes all key/value pairs except the ones specified by _keys_.
    #
    #   @example
    #     hash = { a: 1, b: 2, c: 3, d: 4 }
    #     hash.only(:a, :d)  # => { a: 1, d: 4 }
    #     hash  # => { a: 1, d: 4 }
    #
    #   @see #only
    #   @param *keys (see #only)
    #   @return [Hash] a hash containing the removed key/value pairs.
    #
    module Only
      refine ::Hash do
        def only(*keys)
          # Note: self.dup is used to preserve the default_proc.
          keys.each_with_object(dup.clear) do |k, hash|
            hash[k] = self[k] if has_key? k
          end
        end

        def only!(*keys)
          deleted = keys.each_with_object(dup) do |k, hash|
            hash.delete(k)
          end
          replace only(*keys)

          deleted
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
    module OpAdd
      refine ::Hash do
        def +(other_hash)
          merge other_hash
        end
      end
    end

    ##
    # @!method recurse(&block)
    #   Transforms this hash and each of its sub-hashes recursively using the
    #   given _block_.
    #
    #   It does not mutate the hash if the given _block_ is pure (i.e. does not
    #   modify given hashes, but returns new ones).
    #
    #   @example
    #     hash = {"a" => 1, "b" => {"c" => {"e" => 5}, "d" => 4}}
    #
    #     hash.recurse { |h| h.symbolize_keys }  # => {a: 1, b: {c: {e: 5}, d: 4}}
    #     hash  # => {"a" => 1, "b" => {"c" => {"e" => 5}, "d" => 4}}
    #
    #     hash.recurse { |h| h.symbolize_keys! }  # => {a: 1, b: {c: {e: 5}, d: 4}}
    #     hash  # => {a: 1, b: {c: {e: 5}, d: 4}}
    #
    #   @yield [Hash] gives this hash and every sub-hash (recursively).
    #     The return value replaces the old value.
    #   @return [Hash] a result of applying _block_ to this hash and each of
    #     its sub-hashes (recursively).
    #
    module Recurse
      refine ::Hash do
        def recurse(&block)
          h = yield(self)
          h.each do |key, value|
            h[key] = value.recurse(&block) if value.is_a? ::Hash
          end
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

          # Note: self.dup is used to preserve the default_proc.
          if key_map
            key_map.each_with_object(dup) do |(from, to), hash|
              hash[to] = hash.delete(from) if hash.key? from
            end
          else
            transform_key = if !block
              ->(k, _) { k.to_sym rescue k }
            elsif block.arity.abs == 1 || block.lambda? && block.arity != 2
              # This is needed for "symbol procs" (e.g. &:to_s). It behaves
              # differently since Ruby 3.0!
              # Ruby <3.0: block.arity => -1, block.lambda? => false
              # Ruby 3.0: block.arity => -2, block.lambda? => true
              ->(k, _) { block[k] }
            else
              block
            end

            each_with_object(dup.clear) do |(key, value), hash|
              hash[ transform_key[key, value] ] = value
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
      alias_method :except!, :except
      alias_method :only!, :only
      alias_method :rekey!, :rekey
      alias_method :symbolize_keys!, :symbolize_keys
    end
  end
end
