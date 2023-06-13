require 'june_lisp/input_stream'
require 'utils/sequence_utils'

module JuneLisp
  class Reader
    MACROS = {
      # We treat parentheses and string quotes as macro characters
      '(' => lambda { |input| read_list(input) },
      ')' => lambda { |input| },
      '"' => lambda { |input|
        input.next
        token = input.read_until('"')
        input.next
        '"' << token << '"'
      },
      # Example reader macros that can extend the parser :point_down:
      "'" => lambda { |input| input.next; ["quote", read(input)] },
      # This allows naive Clojure-like #() functions: https://cljs.github.io/api/syntax/function
      "#" => lambda { |input|
        input.next;
        args = []
        tokens = read(input)
        body = SequenceUtils.recursive_map(-> (token) do
          if token.is_a?(String) && token.start_with?("%")
            arg = "arg#{token[1..]}"
            args << arg unless args.include?(arg)
            arg
          else
            token
          end
        end, tokens)
        ["lambda", args, body]
      }
    }

    TERMINATING_MACROS = ['(', ')']

    def self.read_string(code)
      input = JuneLisp::InputStream.new(code.strip)
      result = self.read(input)
      if !input.end_of_string?(input.position)
        raise "Unexpected character '#{input.peek()}' at position: #{input.position}"
      else
        result
      end
    end

    def self.read(input)
      while !input.end_of_string?
        char = input.peek
        case char
        when -> (c) { is_whitespace?(c) }
          input.next
        when -> (c) { is_macro?(c) }
          return MACROS[char].call(input)
        when -> (c) { is_constituent?(c) }
          token = ""
          while !is_token_termination?(input)
            token += input.peek
            input.next
          end
          return Integer(token, exception: false) || Float(token, exception: false) || token
        else
          raise "Unexpected character '#{char}' at position: #{input.position}"
        end
      end
    end

    # This method will *recursively* read lists
    def self.read_list(input)
      initial_open_lists = input.delimiters['('] || 0
      tokens = []

      # Read tokens until we reach the end of the list or the end of the string
      while !(input.delimiters['('] === initial_open_lists && input.peek === ')') &&
            !input.end_of_string?

        if input.peek == '('
          input.open_delimiter('(')
          input.next
        end

        token = self.read(input)
        tokens = token ? tokens << token : tokens

        if input.peek == ')'
          input.close_delimiter('(')
        end
      end

      if input.delimiters['('] != initial_open_lists then
        raise "Unbalanced parentheses"
      end

      input.next
      tokens
    end

    def self.is_token_termination?(input)
      is_whitespace?(input.peek) || TERMINATING_MACROS.include?(input.peek) || input.end_of_string?
    end

    def self.is_whitespace?(char)
      char == ' ' || char == '\t'
    end

    def self.is_macro?(char)
      MACROS.include?(char)
    end

    def self.is_constituent?(char)
      !is_macro?(char)
    end
  end
end
