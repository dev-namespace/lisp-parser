#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path('lib', __dir__)

require 'june_lisp/reader'

ast = JuneLisp::Reader.read_string("(first (list 1 (+ 2 3) 9))")
puts "AST: #{ast}"
