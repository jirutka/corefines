# coding: utf-8
require 'corefines/support/alias_submodules'

module Corefines
  module String

    ESCAPE_SEQUENCE = /\033\[([0-9]+);([0-9]+);([0-9]+)m(.+?)\033\[0m|([^\033]+)/m
    private_constant :ESCAPE_SEQUENCE

    ##
    # @!method camelcase
    #   Returns a copy of the _str_ converted to camelcase. When no +:upper+ or
    #   +:lower+ is specified, then it leaves the first character of a word
    #   (after camelization) unchanged.
    #
    #   @example
    #     "camel case".camelcase          # => "camelCase"
    #     "Camel case".camelcase          # => "CamelCase"
    #     "camel_case__4you!".camelcase   # => "camelCase4you!"
    #     "camel_case__4_you!".camelcase  # => "camelCase4You!"
    #
    #   @overload camelcase(*separators)
    #     @example
    #       "camel-case yay!".camelcase('-')          # => "camelCase yay!"
    #       "camel::ca-se-y".camelcase(':', '-')      # => "camelCaSeY"
    #       "camel42case".camelcase(/[0-9]+/)         # => "camelCase"
    #
    #     @param *separators [String, Regexp] the patterns used to determine
    #            where capitalization should occur. Defaults to <tt>/_+/</tt> and
    #            <tt>\s+</tt>.
    #
    #   @overload camelcase(first_letter, *separators)
    #     @example
    #       "camel case".camelcase(:upper)            # => "CamelCase"
    #       "camel-case yay!".camelcase(:upper, '-')  # => "CamelCase Yay!"
    #
    #     @param first_letter [:upper, :lower] desired case of the first
    #            character of a word - +:upper+ to be upcased, or +:lower+ to
    #            be downcased.
    #     @param *separators [String, Regexp] the patterns used to determine
    #            where capitalization should occur. Defaults to <tt>/_+/</tt> and
    #            <tt>\s+</tt>.
    #
    #   @return [String] a copy of the _str_ converted to camelcase.
    #
    module Camelcase
      refine ::String do
        def camelcase(*separators)
          first_letter = separators.shift if ::Symbol === separators.first
          separators = [/_+/, /\s+/] if separators.empty?

          self.dup.tap do |str|
            separators.compact.each do |s|
              s = "(?:#{::Regexp.escape(s)})+" unless s.is_a? ::Regexp
              str.gsub!(/#{s}([a-z\d])/i) { $1.upcase }
            end

            case first_letter
            when :upper
              str.gsub!(/(\A|\s)([a-z])/) { $1 + $2.upcase }
            when :lower
              str.gsub!(/(\A|\s)([A-Z])/) { $1 + $2.downcase }
            end
          end
        end
      end
    end

    ##
    # @!method color
    #   @example
    #     "Roses are red".color(:red) # => "\e[0;31;49mRoses are red\e[0m"
    #     "Roses are red".color(text: :red, mode: :bold) # => "\e[1;31;49mRoses are red\e[0m"
    #     "Violets are blue".color(background: 'blue') # => "\e[0;39;44mViolets are blue\e[0m"
    #     "Sugar is sweet".color(text: 7) # => "\e[0;37;49mSugar is sweet\e[0m"
    #
    #   @overload color(text_color)
    #     @param text_color [#to_sym, Integer] text (foreground) color (see
    #            {COLOR_CODES}).
    #
    #   @overload color(opts)
    #     @option opts [#to_sym, Integer] :mode text attributes (see
    #             {MODE_CODES}).
    #     @option opts [#to_sym, Integer] :text,:fg text (foreground) color (see
    #             {COLOR_CODES}).
    #     @option opts [#to_sym, Integer] :background,:bg background color (see
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
        return color + offset if color.is_a? ::Integer
        COLOR_CODES[color.to_sym] + offset if color && COLOR_CODES[color.to_sym]
      end

      def self.mode_code(mode)
        return mode if mode.is_a? ::Integer
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
    # @!method force_utf8
    #   Returns a copy of _str_ with encoding changed to UTF-8 and all invalid
    #   byte sequences replaced with the Unicode Replacement Character (U+FFFD).
    #
    #   If _str_ responds to +#scrub!+ (Ruby >=2.1), then it's used for
    #   replacing invalid bytes. Otherwise a simple custom implementation is
    #   used (may not return the same result as +#scrub!+).
    #
    #   @return [String] a valid UTF-8 string.
    #
    # @!method force_utf8!
    #   Changes the encoding to UTF-8, replaces all invalid byte sequences with
    #   the Unicode Replacement Character (U+FFFD) and returns self.
    #   This is same as {#force_utf8}, except it indents the receiver in-place.
    #
    #   @return (see #force_utf8)
    #
    module ForceUTF8
      refine ::String do
        def force_utf8
          dup.force_utf8!
        end

        def force_utf8!
          str = force_encoding(Encoding::UTF_8)

          if str.respond_to? :scrub!
            str.scrub!

          else
            result = ''.force_encoding('BINARY')
            invalid = false

            str.chars.each do |c|
              if c.valid_encoding?
                result << c
                invalid = false
              elsif !invalid
                result << "\uFFFD"
                invalid = true
              end
            end

            replace result.force_encoding(Encoding::UTF_8)
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
    #   @param amount [Integer] the indent size.
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
    # @!method relative_path_from(base_dir)
    #   Returns a relative path from the given _base_dir_ to the path
    #   represented by this _str_. This method doesn't access the filesystem
    #   and assumes no symlinks.
    #
    #   If _str_ is absolute, then _base_dir_ must be absolute too.
    #   If _str_ is relative, then _base_dir_ must be relative too.
    #
    #   @example
    #     '/home/flynn/tron'.relative_path_from('/home')  # => flynn/tron
    #     '/home'.relative_path_from('/home/flynn/tron')  # => ../..
    #
    #   @param base_dir [String, Pathname] the base directory to calculate
    #          relative path from.
    #   @return [String] a relative path from _base_dir_ to this _str_.
    #   @raise ArgumentError if it cannot find a relative path.
    #
    module RelativePathFrom
      refine ::String do
        def relative_path_from(base_dir)
          ::Pathname.new(self).relative_path_from(::Pathname.new(base_dir)).to_s
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
    # @!method snake_case
    #   @example
    #     "snakeCase".snake_case       # => "snake_case"
    #     "SNAkeCASe".snake_case       # => "sn_ake_ca_se"
    #     "Snake2Case".snake_case      # => "snake2_case"
    #     "snake2case".snake_case      # => "snake2case"
    #     "snake-Ca-se".snake_case     # => "snake_ca_se"
    #     "snake  ca se".snake_case    # => "snake__ca_se"
    #     "__snake-case__".snake_case  # => "__snake_case__"
    #
    #   @return [String] a copy of the _str_ converted to snake_case.
    #
    # @!method snakecase
    #   Alias for {#snake_case}.
    #
    #   @return (see #snake_case)
    #
    module SnakeCase
      refine ::String do
        def snake_case
          self.dup.tap do |s|
            s.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
            s.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
            s.tr!('-', '_')
            s.gsub!(/\s/, '_')
            s.downcase!
          end
        end

        alias_method :snakecase, :snake_case
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
    # @!method to_re(opts = {})
    #   Returns a regular expression represented by this string.
    #
    #   @example
    #     '/^foo/'.to_re                  # => /^foo/
    #     '/foo/i'.to_re                  # => /foo/i
    #     'foo'.to_re                     # => nil
    #
    #     'foo'.to_re(literal: true)      # => /foo/
    #     '^foo*'.to_re(literal: true)    # => /\^foo\*/
    #
    #     '/foo/'.to_re(detect: true)     # => /foo/
    #     '$foo/'.to_re(detect: true)     # => /\$foo\//
    #     ''.to_re(detect: true)          # => nil
    #
    #     '/foo/'.to_re(multiline: true)  # => /foo/m
    #
    #   @note This method was renamed from +to_regexp+ to +to_re+ due to bug
    #     in MRI, see {#11117}[https://bugs.ruby-lang.org/issues/11117].
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
    module ToRe
      refine ::String do
        def to_re(opts = {})

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
      alias_method :force_utf8!, :force_utf8
      alias_method :indent!, :indent
      alias_method :remove!, :remove
      alias_method :snakecase, :snake_case
    end
  end
end
