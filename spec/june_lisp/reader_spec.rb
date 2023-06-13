require 'rspec'
require 'june_lisp/reader'

RSpec.describe JuneLisp do
  describe '#read_string' do

    it 'Parses atoms' do
      expect(JuneLisp::Reader.read_string('278')).to eq(278)
    end

    it 'Parses a simple expression' do
      expect(JuneLisp::Reader.read_string('(add 1 2)')).to eq(["add", 1, 2])
    end

    it 'Parses symbols' do
      expect(JuneLisp::Reader.read_string('(+ 1 2)')).to eq(["+", 1, 2])
    end

    it 'Parses strings' do
      expect(JuneLisp::Reader.read_string('(concat "1" "2")')).to eq(["concat", "\"1\"", "\"2\""])
    end

    it 'Parses escaped strings' do
      input = '(concat "a\"\"b" "b")'
      expected = ["concat", "\"a\\\"\\\"b\"", "\"b\""]
      expect(JuneLisp::Reader.read_string(input)).to eq(expected)
    end

    it 'Ignores whitespace' do
      expect(JuneLisp::Reader.read_string('(  +    1 2   )')).to eq(["+", 1, 2])
    end

    it 'Parses nested expressions' do
      input = "(first (list 1 (+ 2 3) 9.8))"
      expected = ["first", ["list", 1, ["+", 2, 3], 9.8]]
      expect(JuneLisp::Reader.read_string(input)).to eq(expected)
    end

    it 'Parses quote reader macro' do
      input = "'(1 2 3)"
      expected = ["quote", [1, 2, 3]]
      expect(JuneLisp::Reader.read_string(input)).to eq(expected)
    end

    it 'Parses #() reader macro' do
      input = "#(+ %1 (+ 10 %2))"
      expected = ["lambda", [ "arg1", "arg2"], ["+", "arg1", ["+", 10, "arg2"]]]
      expect(JuneLisp::Reader.read_string(input)).to eq(expected)
    end

    it 'Raises exception on unbalanced parentheses' do
      input = "((+ 1 2)"
      expect { JuneLisp::Reader.read_string(input) }.to raise_error("Unbalanced parentheses")

      input = "(+ 1 2))"
      expect { JuneLisp::Reader.read_string(input) }.to raise_error("Unexpected character ')' at position: 7")
    end

  end
end
