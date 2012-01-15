#!/usr/bin/env ruby

require "rubygems"
require "stringio"
require "ox"

xml = File.read('datasets/reed.xml')

class Saxit < ::Ox::Sax
	def initialize
	end

  def start_element(name); @name = name;        end
  #def end_element(name);   puts "end: #{name}";          end
  #def attr(name, value);   puts "  #{name} => #{value}"; end
  def text(value);         print "#{@name} => #{value} \n";         end
end

io = StringIO.new(xml)

handler = Saxit.new()
Ox.sax_parse(handler, io)
