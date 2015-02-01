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
    # @!method remove(*patterns)
    #   Returns a copy of this string with the _all_ occurrences of the
    #   +patterns+ removed.
    #
    #   The pattern is typically a +Regexp+; if given as a +String+, any
    #   regular expression metacharacters it contains will be interpreted
    #   literally, e.g. +'\\d'+ will match a backlash followed by 'd', instead
    #   of a digit.
    #
    #   @example
    #     str = "This is a good day to die"
    #     str.remove(" to die") # => "This is a good day"
    #     str.remove(/\s*to.*$/) # => "This is a good day"
    #     str.remove("to die", /\s*$/) # => "This is a good day"
    #
    #   @param *patterns [Regexp, String] patterns to remove from the string.
    #   @return [String] a new string.
    #
    # @!method remove!(*patterns)
    #   Removes all the occurrences of the +patterns+ in place.
    #
    #   @see #remove
    #   @param *patterns (see #remove)
    #   @return [String] self
    #
    module Remove
      refine ::String do
        def remove(*patterns)
          dup.remove!(*patterns)
        end

        def remove!(*patterns)
          patterns.each { |pattern| gsub!(pattern, '') }
          self
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
      alias_method :remove!, :remove
    end
  end
end
