#!/usr/bin/env ruby

name = "Phil"
mytime = Time.new
mytime.localtime
myFormTime = mytime.strftime "%Y %m %d  %H:%M:%S %Z"
puts "My name: #{name} ---- Time: #{myFormTime}"

ary = [1,"two", 3.0,"IV",101]
puts "ary.count: #{ary.count}"
puts "ary.size: #{ary.size}"
puts "ary.length: #{ary.length}"
puts "ary[1]: #{ary[1]}"
puts "ary[ary.size]: #{ary[ary.size]}"
puts ary.map
y = ary.map do |x|
  puts "HI"
end
puts "y"
puts y

puts "silly".capitalize
names = ["phil","larry"]
ary2 = names.each {|x|   x.capitalize}
puts names
puts ary2
ary3 = names.map do |x|
  x.capitalize
end
puts ary3.inspect
ary4 = names.each do |x|
  x.capitalize
end
puts ary4.inspect

t1 = (1.3..5.4)
puts "---> #{t1.to_s} succ: #{1.succ}"

d1 = Date.today
d2 = Time.new(2001,3,4)
puts " Date.succ: #{d1.succ}"
