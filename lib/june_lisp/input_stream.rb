module JuneLisp
  class InputStream
    def initialize(code)
      @delimiters = {}
      @position = 0
      @code = code
    end

    def next
      @position +=1 if !end_of_string?
      nil
    end

    def peek(position = nil)
      @code[position || @position]
    end

    def peek_previous
      @code[@position - 1]
    end

    def read_until(char)
      output = ""
      until end_of_string? || (peek == char && peek_previous != "\\") do
        output << peek
        self.next
      end
      output
    end

    def end_of_string?(position = nil)
      (position || @position) >= @code.length
    end

    def open_delimiter(delimiter)
      @delimiters[delimiter] = (@delimiters[delimiter] || 0) + 1
    end

    def close_delimiter(delimiter)
      if !@delimiters[delimiter] || @delimiters[delimiter] == 0
        raise "Missmatched delimiter at position: #{position}"
      end
      @delimiters[delimiter] = @delimiters[delimiter] - 1
    end

    attr_reader :delimiters
    attr_reader :position
  end
end
