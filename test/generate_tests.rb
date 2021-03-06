#!/usr/bin/env ruby

# This will generate a test suite.

def class_header(bits)
  puts <<-SHAVS_CLASS

class SHA3SHAVS#{bits} < Test::Unit::TestCase
  def setup
    @d = Digest::SHA3.new(#{bits})
  end
  SHAVS_CLASS
end

def test_case(length, bits, msg, md)
  puts <<-SHAVS_TEST_CASE

  def test_sha3_shavs_#{bits}_#{length}
    @d.update #{msg.inspect}
    assert_equal #{md.inspect}, @d.hexdigest
  end
  SHAVS_TEST_CASE
end

puts <<-HEADER
# This file generated by generate_tests.rb

require 'test/unit'
HEADER

Dir[File.join('test', 'data', '*.rsp')].each do |rsp|
  length = bits = msg = md = nil
  open(rsp).each_line do |line|
    case line
    when /\[L = (\d+)\]/
      bits = Integer($1)
      class_header(bits)
    when /Len = (\d+)/
      length = Integer($1)
    when /Msg = (\h+)/
      msg = [$1].pack('H*').byteslice(0, length/8)
    when /MD = (\h+)/
      md = $1.downcase
      test_case(length, bits, msg, md)
    end
  end # SHAV .rsp each_line
  puts "end # class SHA3SHAVS#{bits}"
end # each SHAVS .rsp file
