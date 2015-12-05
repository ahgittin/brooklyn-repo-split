#!/usr/bin/env ruby

whitelist = []
ARGV.each do |whitelist_file|
  wl = open(whitelist_file) { |f| f.readlines }
  whitelist = whitelist.concat(wl)
end
whitelist.collect! { |l| l.chomp }

lastout = ""
$stdin.each do |input|
# IO.popen('git ls-files', 'r+').each do |input|
# open('../test-data.txt').each do |input|
  input.chomp!
  if whitelist.select { |x| input.start_with?(x) }.empty?
    # file is blacklisted
    # ...but now need to shorten it to the shortest possible directory component that doesn't conflict with a whitelist
    dcs = input.split("/")

    # special case: dcs is empty means it's a file in the root directory, since it didn't match a whitelist it must be deleted
    if dcs.empty?
      print input
      print "\0"
    else
      lvl = -1
      whitelist.collect { |x|
        xdcs = x.split("/")
        level = 1
        zipped = dcs.zip(xdcs)
        zipped.each do |row|
          if row[0] == row[1]
            level += 1
          else
            break
          end
        end
        lvl = (level > lvl) ? level : lvl
      }
      out = dcs.take(lvl).join("/")
      if lastout != out
        lastout = out
        print lastout
        print "\0"
      end
    end
  end
end

