require 'corefines/support/alias_submodules'

module Corefines
  module String
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
  end
end
