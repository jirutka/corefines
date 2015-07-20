module Corefines
  module Support
    ##
    # @private
    # Reusable utility methods used in refinements.
    module Utils

      ##
      # @param receiver [Module]
      # @param meth_name [Symbol]
      # @return [Symbol, nil] visibility of the method defined in the receiver:
      #   +:public+, +:protected+, +:private+, or +nil+ if the method is not
      #   defined.
      #
      def self.method_visibility(receiver, meth_name)
        if receiver.public_method_defined? meth_name
          :public
        elsif receiver.protected_method_defined? meth_name
          :protected
        elsif receiver.private_method_defined? meth_name
          :private
        end
      end
    end
  end
end
