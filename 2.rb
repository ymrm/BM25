#!/usr/bim/ruby
# -*- comfig utf-8 -*-
#require 

words_array = Hash.new {|h,k| h[k] = []}
words_array = STDIN.read
print words_array

words_array.each{|k,v|
p k
}
