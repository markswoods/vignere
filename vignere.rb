$LOAD_PATH << '.'

require 'kasiski.rb'
require 'vig_utilities.rb'

$key_threshold = 3 # Min score to include subkey as candidate
$msg_threshold = 5 # Min score to consider message as english plaintext
$debug = false
$verbose = true

#message = "USXALIPVLYCGQHKALARUZALIPVLSYFCZWMNJDGLRCDMWFN" +
#"CTRGMWOPMCOUXOFBDLZTAWYONLNTLYCGQHTHMEUSUAMTJFLIYSCCXSOCTWLPMDJBYLLODGLVAOJZGUYTJYWABIBLPERXGL"
# Note: Message above is 140 characters long

#message = "AOFACFSOAFSZWBEICEIOAZOHSFWQWOAOQQSDWAOFACFSOAFSZWBEICEIOAZOHSFWQWOAOQQSDW"
#1.upto(25) do |n| puts "%2d. %s" % [n, Vig_Utilities.decrypt(message,n)] end
#  exit
message = "PPQCAXQVEKGYBNKMAZUYBNGBALJONITSZMJYIMVRAGVOHTVRAUCTKSGDDWUOXITLAZUVAVVRAZCVKBQPIWPOU"

def verbose(text)
  puts text if $verbose 
end

def debug(text)
  puts text if $debug 
end

# Obtain a list of possible key lengths
key_lengths = Kasiski.test(message)
key_lengths = [4]

for n in key_lengths
  verbose("Trying keys of length: #{n}")
  # Split int n lines, selecting every nth character (characters on each line share the same key)
  lines = Vig_Utilities.split_message(message, n)
    
  # Identify candidate set of keys
  candidates = Vig_Utilities.find_candidate_keys2(lines)

  # Brute force approach
  # For each key in the set, decrypt lines using that key
  # Then need to transpose lines, rejoining on every 6th character
  # Could then try applying english frequency test on result
  
  candidates = ["WICK"]
  for k in candidates
    tlines = Array.new
    debug("Key: #{k}")
    for i in (0..lines.length-1)
      subkey = ('A'..'Z').to_a.join.index(k[i])
      tlines[i]=Vig_Utilities.decrypt(lines[i], subkey)
      debug("#{('A'..'Z').to_a[subkey]}: #{tlines[i]}")
    end
    message = Vig_Utilities.transpose(tlines)
    letter_counts = Vig_Utilities.english_frequency_analysis(message)
    score = Vig_Utilities.score_distribution(letter_counts)
    if score >= $msg_threshold
        verbose("#{k}/#{score}: #{message}")
    end
  end
end




