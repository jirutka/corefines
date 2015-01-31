require 'corefines/support/alias_submodules'

module Corefines
  module String

    ##
    # @!method concat!(obj, separator = nil)
    #   Appends (concatenates) the given object to +str+. If the +separator+ is
    #   set and this +str+ is not empty, then it appends the +separator+ before
    #   the +obj+.
    #
    #   @example
    #     "".concat!("Greetings", ", ") # => "Greetings"
    #     "Greetings".concat!("programs!", ", ") #=> "Greetings, programs!"
    #
    #   @param obj [String, Integer] the string, or codepoint to append.
    #   @param separator [String, nil] the separator to append when this +str+ is
    #          not empty.
    #   @return [String] self
    #
    module Concat
      refine ::String do
        def concat!(obj, separator = nil)
          if separator && !self.empty?
            self << separator << obj
          else
            self << obj
          end
        end
      end
    end

    ##
    # @!method unindent
    #   Remove excessive indentation. Useful for multi-line strings embeded in
    #   already indented code.
    #
    #   @example
    #     <<-EOF.unindent
    #       Greetings,
    #         programs!
    #     EOF
    #     => "Greetings\n  programs"
    #
    #   Technically, it looks for the least indented line in the whole
    #   string (blank lines are ignored) and removes that amount of leading
    #   whitespace.
    #
    #   @return [String] a new unindented string.
    #
    #
    # @!method strip_heredoc
    #   Alias for {#unindent}.
    #
    #   @return [String] a new unindented string.
    #
    module Unindent
      refine ::String do
        def unindent
          leading_space = scan(/^[ \t]*(?=\S)/).min
          indent = leading_space ? leading_space.size : 0
          gsub /^[ \t]{#{indent}}/, ''
        end

        alias_method :strip_heredoc, :unindent
      end
    end

    include Support::AliasSubmodules

    class << self
      alias_method :concat!, :concat
    end
  end
end
