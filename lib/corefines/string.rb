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
