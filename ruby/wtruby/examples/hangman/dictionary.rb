# Copyright (C) 2005 Wim Dumon
#
# See the LICENSE file for terms of use.
#
# Copyright (C) 2005 Wim Dumon
#
# See the LICENSE file for terms of use.
#


DICT_EN = 0
DICT_NL = 1

def randomWord(dictionary)
  if dictionary == DICT_NL
    dict = File.open("dict-nl.txt")
  else # english is default
    dict = File.open("dict.txt")
  end
    
  lines = dict.readlines
  numwords = lines.length

  srand(Time.new.usec)
  selection = rand(numwords) # not entirely uniform, but who cares?
  retval = lines[selection].chop
  if retval =~ /([^A-Z]+)/
    puts "word #{retval} contains illegal data at pos #{$`.length}"
  end

  return retval
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;
