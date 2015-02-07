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
      alias_method :symbolize_keys!, :symbolize_keys
    end
  end
end
