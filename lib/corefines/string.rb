# coding: utf-8
require 'corefines/support/alias_submodules'

module Corefines
  module String

    ESCAPE_SEQUENCE = /\033\[([0-9]+);([0-9]+);([0-9]+)m(.+?)\033\[0m|([^\033]+)/m
    private_constant :ESCAPE_SEQUENCE

    ##
    # @!method color
    #   @example
    #     "Roses are red".color(:red) # => "\e[0;31;49mRoses are red\e[0m"
    #     "Roses are red".color(text: :red, mode: :bold) # => "\e[1;31;49mRoses are red\e[0m"
    #     "Violets are blue".color(background: 'blue') # => "\e[0;39;44mViolets are blue\e[0m"
    #     "Sugar is sweet".color(text: 7) # => "\e[0;37;49mSugar is sweet\e[0m"
    #
    #   @overload color(text_color)
    #     @param text_color [#to_sym, Fixnum] text (foreground) color (see
    #            {COLOR_CODES}).
    #
    #   @overload color(opts)
    #     @option opts [#to_sym, Fixnum] :mode text attributes (see
    #             {MODE_CODES}).
    #     @option opts [#to_sym, Fixnum] :text,:fg text (foreground) color (see
    #             {COLOR_CODES}).
    #     @option opts [#to_sym, Fixnum] :background,:bg background color (see
    #             {COLOR_CODES}).
    #
    #   @return [String] a copy of this string colored for command line output
    #           using ANSI escape codes.
    #   @see Decolor#decolor
    #
    module Color

      COLOR_CODES = {
        black:   0, light_black:   60,
        red:     1, light_red:     61,
        green:   2, light_green:   62,
        yellow:  3, light_yellow:  63,
        blue:    4, light_blue:    64,
        magenta: 5, light_magenta: 65,
        cyan:    6, light_cyan:    66,
        white:   7, light_white:   67,
        default: 9
      }

      MODE_CODES = {
        default:   0,  # Turn off all attributes.
        bold:      1,  # Set bold mode.
        underline: 4,  # Set underline mode.
        blink:     5,  # Set blink mode.
        swap:      7,  # Exchange foreground and background colors.
        hide:      8   # Hide text (foreground color would be the same as background).
      }

      refine ::String do
        def color(opts)
          opts = {text: opts} unless opts.is_a? ::Hash
          opts[:fg] ||= opts[:text] || opts[:color]
          opts[:bg] ||= opts[:background]

          scan(ESCAPE_SEQUENCE).reduce('') do |str, match|
            mode     = Color.mode_code(opts[:mode])    || match[0] || 0
            fg_color = Color.color_code(opts[:fg], 30) || match[1] || 39
            bg_color = Color.color_code(opts[:bg], 40) || match[2] || 49
            text     = match[3] || match[4]

            str << "\033[#{mode};#{fg_color};#{bg_color}m#{text}\033[0m"
          end
        end
      end

      private

      def self.color_code(color, offset)
        return color + offset if color.is_a? ::Fixnum
        COLOR_CODES[color.to_sym] + offset if color && COLOR_CODES[color.to_sym]
      end

      def self.mode_code(mode)
        return mode if mode.is_a? ::Fixnum
        MODE_CODES[mode.to_sym] if mode
      end
    end

    ##
    # @!method concat!(obj, separator = nil)
    #   Appends (concatenates) the given object to _str_. If the _separator_ is
    #   set and this _str_ is not empty, then it appends the _separator_ before
    #   the _obj_.
    #
    #   @example
    #     "".concat!("Greetings", ", ") # => "Greetings"
    #     "Greetings".concat!("programs!", ", ") #=> "Greetings, programs!"
    #
    #   @param obj [String, Integer] the string, or codepoint to append.
    #   @param separator [String, nil] the separator to append when this _str_ is
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
    # @!method decolor
    #   @return [String] a copy of this string without ANSI escape codes
    #     (e.g. colors).
    #   @see Color#color
    #
    module Decolor
      refine ::String do
        def decolor
          scan(ESCAPE_SEQUENCE).reduce('') do |str, match|
            str << (match[3] || match[4])
          end
        end
      end
    end

    ##
    # @!method indent(amount, indent_str = nil, indent_empty_lines = false)
    #   Returns an indented copy of this string.
    #
    #   @example
    #     "foo".indent(2)           # => "  foo"
    #     "  foo".indent(2)         # => "    foo"
    #     "foo\n\t\tbar".indent(2)  # => "\t\tfoo\n\t\t\t\tbar"
    #     "foo".indent(2, '.')      # => "..foo"
    #     "foo\n\nbar".indent(2)    # => "  foo\n\n  bar"
    #     "foo\n\nbar".indent(2, nil, true)  # => "  foo\n  \n  bar"
    #
    #   @param amount [Fixnum] the indent size.
    #   @param indent_str [String, nil] the indent character to use.
    #          The default is +nil+, which tells the method to make a guess by
    #          peeking at the first indented line, and fallback to a space if
    #          there is none.
    #   @param indent_empty_lines [Boolean] whether empty lines should be indented.
    #   @return [String] a new string.
    #
    # @!method indent!(amount, indent_str = nil, indent_empty_lines = false)
    #   Returns the indented string, or +nil+ if there was nothing to indent.
    #   This is same as {#indent}, except it indents the receiver in-place.
    #
    #   @see #indent
    #   @param amount (see #indent)
    #   @param indent_str (see #indent)
    #   @param indent_empty_lines (see #indent)
    #   @return [String] self
    #
    module Indent
      refine ::String do
        def indent(amount, indent_str = nil, indent_empty_lines = false)
          dup.tap { |str| str.indent! amount, indent_str, indent_empty_lines }
        end

        def indent!(amount, indent_str = nil, indent_empty_lines = false)
          indent_str = indent_str || self[/^[ \t]/] || ' '
          re = indent_empty_lines ? /^/ : /^(?!$)/
          gsub! re, indent_str * amount
        end
      end
    end

    ##
    # @!method remove(*patterns)
    #   Returns a copy of this string with *all* occurrences of the _patterns_
    #   removed.
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
    #   Removes all the occurrences of the _patterns_ in place.
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
    # @!method to_b
    #   Interprets common affirmative string meanings as +true+, otherwise
    #   +false+. White spaces and case are ignored.
    #
    #   The following strings are interpreted as +true+:
    #   <tt>'true', 'yes', 'on', 't', 'y', '1'</tt>.
    #
    #   @example
    #     'yes'.to_b   #=> true
    #     'Yes '.to_b  #=> true
    #     ' t '.to_b   #=> true
    #     'no'.to_b    #=> false
    #     'xyz'.to_b   #=> false
    #     ''.to_b      #=> false
    #
    #   @return [Boolean] +true+ if this string represents truthy,
    #     +false+ otherwise.
    #
    module ToB
      refine ::String do
        def to_b
          %w[true yes on t y 1].include? self.downcase.strip
        end
      end
    end

    ##
    # @!method to_regexp(opts = {})
    #   Returns a regular expression represented by this string.
    #
    #   @example
    #     '/^foo/'.to_regexp                  # => /^foo/
    #     '/foo/i'.to_regexp                  # => /foo/i
    #     'foo'.to_regexp                     # => nil
    #
    #     'foo'.to_regexp(literal: true)      # => /foo/
    #     '^foo*'.to_regexp(literal: true)    # => /\^foo\*/
    #
    #     '/foo/'.to_regexp(detect: true)     # => /foo/
    #     '$foo/'.to_regexp(detect: true)     # => /\$foo\//
    #     ''.to_regexp(detect: true)          # => nil
    #
    #     '/foo/'.to_regexp(multiline: true)  # => /foo/m
    #
    #   @param opts [Hash] options
    #   @option opts :literal [Boolean] treat meta characters and other regexp
    #           codes as just a text. Never returns +nil+. (default: false)
    #   @option opts :detect [Boolean] if string starts and ends with a slash,
    #           treat it as a regexp, otherwise interpret it literally.
    #           (default: false)
    #   @option opts :ignore_case [Boolean] same as +/foo/i+. (default: false)
    #   @option opts :multiline [Boolean] same as +/foo/m+. (default: false)
    #   @option opts :extended [Boolean] same as +/foo/x+. (default: false)
    #
    #   @return [Regexp, nil] a regexp, or +nil+ if +:literal+ is not set or
    #     +false+ and this string doesn't represent a valid regexp or is empty.
    #
    module ToRegexp
      refine ::String do
        def to_regexp(opts = {})

          if opts[:literal]
            content = ::Regexp.escape(self)

          elsif self =~ %r{\A/(.*)/([imxnesu]*)\z}
            content, inline_opts = $1, $2
            content.gsub! '\\/', '/'

            { ignore_case: 'i', multiline: 'm', extended: 'x' }.each do |k, v|
              opts[k] ||= inline_opts.include? v
            end if inline_opts

          elsif opts[:detect] && !self.empty?
            content = ::Regexp.escape(self)
          else
            return
          end

          options = 0
          options |= ::Regexp::IGNORECASE if opts[:ignore_case]
          options |= ::Regexp::MULTILINE if opts[:multiline]
          options |= ::Regexp::EXTENDED if opts[:extended]

          ::Regexp.new(content, options)
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
      alias_method :indent!, :indent
      alias_method :remove!, :remove
    end
  end
end
