module Vig_Utilities
  
  @gen_char_freq={"a"=>8.167,"b"=>1.492,"c"=>2.782,"d"=>4.253,"e"=>12.702,"f"=>2.228,"g"=>2.015,"h"=>6.094,"i"=>6.966,"j"=>0.153, "k"=>0.747,"l"=>4.025,"m"=>2.406,"n"=>6.749,"o"=>7.507,"p"=>1.929,"q"=>0.095,"r"=>5.987,"s"=>6.327,"t"=>9.056, "u"=>2.758,"v"=>1.037,"w"=>2.365,"x"=>0.150,"y"=>1.974,"z"=>0.074}
  
  def Vig_Utilities.vig_square
    alphabet = ('A'..'Z').to_a
    square = Array.new(26)
    square[0] = alphabet
    for j in (1..25)
      square[j] = square[j-1].rotate(-1)
    end
    square
  end
 
  @square = Vig_Utilities.vig_square
  for j in @square
    puts "#{j.join}"
  end
  
  def verbose(text)
    puts text if $verbose 
  end

  def debug(text)
    puts text if $debug 
  end
  
  def Vig_Utilities.decrypt(string, key)
    # Use the provided key as a lookup in the Vignere square to decrypt string
    # key is a numeric corresponding to a row representing a rotated alphabet
    # This has been testedand proven to work using ex. from Alice, Bob, Mallory site
    alphas=('A'..'Z').to_a*2
    #string.tr('A-Z', alphas[key..key+26].join)  # generates a right-shift square
    string.tr('A-Z', alphas[-26-key..51-key].join)  # generates a left-shift square 
  end
  
  def Vig_Utilities.english_frequency_analysis(text)
    # If the six most frequent letters contain any of ETAOIN, bump the score up 1 for each
    # If the six least frequent letters contain any of VKJXQZ, bump the score up 1 for each
      counts = {}
      # now populate counts from text
      text.each_char do |char|
        counts[char] = 0 unless counts.include?(char) # initializes each letter count
        counts[char] += 1
      end
      
      # Now sort the whole thing. Preferrably by count and then letter, giving 
      # favor to ETAOIN
      #counts = counts.sort_by {|letter, count| count} # array in ascending sort
      counts = counts.to_a.sort do |a,b|
        comp = (a[1] <=> b[1])
        comp.zero? ? ("ETAOIN".include?(b[0]) ? -1 : 1) : comp
      end
      
      verbose("#{counts}")
      counts
    end
    
    def Vig_Utilities.score_distribution(counts)      
      # Now to compute a score
      score = 0
      
      for j in (0..5) 
        if 'ETAOIN'.include?(counts[-j][0])
          score += 1
        end
        if 'VKJXQZ'.include?(counts[j][0])
          score += 1
        end

        #if 'ETAOIN'.include?(counts[j][0])
        #  score -= 1
        #end
        if 'VKJXQZ'.include?(counts[-j][0])
          score -= 1
        end
      end  
      score
  end
  
  def Vig_Utilities.calculate_distribution(counts)
    sum = 0
    dist = Hash.new
    counts.each {|c| sum += c[1]}
    counts.each {|k, v| dist[k] = (v.to_f/sum)*100}
    verbose("Sum: #{sum}, Distribution: #{dist}")
    dist
  end
  
  def Vig_Utilities.transpose(tlines)
    # At this point words read "down" the columns from 1 .. tlines[0].length
    # There is a transpose method...for arrays of equal size
    tlines = tlines.collect{|t| t.split("")}
    longest = tlines[0].length
    for i in (1..tlines.length-1)
      if tlines[i].length < longest
        tlines[i].push("")
      end
    end
    message = tlines.transpose.flatten.join
    debug("#{message}")
    message
  end
  
  def Vig_Utilities.split_message(message, key_length)
    # Re-arrange into lines using a common key row  
    lines = Array.new(key_length)
    for j in (0..key_length-1)
      lines[j] = message.split("").select.with_index {|_,i| (i-j) % key_length == 0}
    end
    for j in (0..key_length-1)
      lines[j] = lines[j].join("")
    end
  
    for i in (0..lines.length-1)
      verbose("#{i}: #{lines[i]}")
    end   
    lines
  end
  
  def Vig_Utilities.find_candidate_keys(lines)
    # I want to work out what the key actually is, then decrypt using a known key
    # Try decrypting with each possible row A..Z and then look for rows that
    # provide a letter frequency most likely matching English
    # ETAOINSHRDLU - Most common letters in an English phrase
   
    candidates = Array.new
    for l in lines
      verbose("\nIdentify subkeys for next line")
      scores = Hash.new
      for j in (0..25)
        ptext = Vig_Utilities.decrypt(l, j)
        letter_counts = Vig_Utilities.english_frequency_analysis(ptext)
        score = Vig_Utilities.score_distribution(letter_counts)
        if score > 0
          scores[('A'..'Z').to_a[j]] = score
        end
        verbose("#{('A'..'Z').to_a[j]}: #{ptext} #{score}")
      end
      scores = scores.sort_by {|row, score| score}
      t = scores.select {|s| s[1] >= $key_threshold}
      keys = Array.new
      for i in (0..t.length-1)
        keys.push(t[i][0])
      end
      candidates.push(keys)
    end
    # Now to generate all permutations of each
    perm = 1
    for c in candidates
      perm *= c.length
    end
    verbose("#{candidates}")
    verbose("Key Permutations: #{perm}")

    set = candidates[0]
    for i in (1..candidates.length-1)
      set = set.product(candidates[i])
    end
  
    for i in (0..set.length-1)
      set[i] = set[i].flatten.join
    end
    verbose("#{set}")
    set
  end
  
  def Vig_Utilities.match_char(hash_results)
    # Iterates through hash of character occurence percentages, for each one iterating through actual
    # english language letter distributions looking for one that has closest matching distribution
    # that is, the one with minimum distance between the observed and actual distribution.
    dist = 100
    dist_c = ""
    match_hash = Hash.new
    hash_results.each { |a,b| @gen_char_freq.each { |c,d| dist,dist_c = (d-b).abs, c if (d-b).abs < dist}
      match_hash[a],dist = dist_c,100}
    return match_hash
  end

  def Vig_Utilities.find_candidate_keys2(lines)
    # Try this approach:
    #   Perform frequency analysis on each line to identify likely e, t letters
    #   Grab subkey associated with those likely mappings
    #   Generate keys from this set
    # => use whatlanguage gem to identify english phrase from brute-forcing through keys
    # Re-arrange cipher into words of key_length n
    candidates = Array.new
    for l in lines
      verbose("\nIdentify subkeys for next line")
      letter_counts = Vig_Utilities.english_frequency_analysis(l)
      letter_dist = Vig_Utilities.calculate_distribution(letter_counts)
      mapping = Vig_Utilities.match_char(letter_dist)

      # Which subkey most likely produces the mapping? Since "e" occurs the most,
      # let's look for the e mapping. So if z => e, which key produces that mapping?
      echar = mapping.key("e")
      debug("e character is: #{echar}")
      # Which key uses echar as "e"?
      key = ""
      candidates.push(key)
    end
    verbose("Key letters: #{candidates}")
  
  end
  
end