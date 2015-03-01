module Corefines
  module Support

    @classes_including_module = {}

    ##
    # @private
    # Finds all classes that includes the specified module.
    # Results are cached to speed-up repeated calls.
    #
    # @param mod [Module] the module.
    # @yield [Class] gives each class that includes the +mod+.
    #
    def self.classes_including_module(mod)
      @classes_including_module[mod] ||=
        ::ObjectSpace.each_object(::Class).select do |klass|
          begin
            klass.included_modules.include?(mod)
          rescue
            # ignore errors
          end
        end

      @classes_including_module[mod].each { |e| yield e }
    end
  end
end
