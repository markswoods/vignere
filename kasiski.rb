module Kasiski
  # Here is what I want to do. Starting with the largest possible key, work down to the smallest
  # For each key size, look for candidates of that size and see if they are repeated anywhere
  # Keep track of matches and where they lie. If a smaller match is found, ignore it

  class DupWord
    @word
    @offset
    @length
    def initialize(word, offset, length)
      @word = word
      @offset = offset
      @length = length
    end
    def details()
      @word + " " + @offset.to_s + " " + @length.to_s
    end
    def word
      @word
    end
    def length
      @length
    end
    def offset
      @offset
    end
  end
  
  def Kasiski.test(message)
    min_key = 3   # Unlikely key will be less than four characters

    repeats = Array.new             # List of subsequently repeated words in cipher text
    dupwords = Array.new            # List of duplicated words and their position
    candidate_length = message.length/2 # Key cannot be longer than 1/2 message for Kasiski to work
    length = candidate_length

    while length >= min_key          # Working through all possible key lengths
      index = 0                      # Reset index for this next loop
      while index < message.length   # optimize this!
        candidate = message[index, length]
        new_candidate = true

        m = message.match(candidate, index + length) 
        if m != nil
          # puts candidate
          # puts "Found a match! l=#{length} i=#{index} #{m[0]} at #{m.offset(0)}"
          # Add to array of candidates, if not already identified at same position
          unique = true
          repeats.each {|c| if c[0].match(m[0]) != nil and c[0].length > m[0].length then unique = false end }
            if unique == true
              if new_candidate
                dupwords.push(DupWord.new(candidate, index, length))
                new_candidate = false
              end
              repeats.push(m)
              dupwords.push(DupWord.new(m[0], m.offset(0)[0], length))
            end
          end
  
          index += 1    # Advance to next candidate of this length
          if (index + length) * 2 > message.length   # Optimization
            break
          end
        end
  
        length -= 1     # Try the next smaller possible key length
      end

      # debugging only
      # dupwords.each {|d| puts "#{d.details}" }

      # Having a list of duplicated words and their positions, I can work out the distance between them
      # and the multiples for that distance. The intersection of these sets will yield a list of candidate
      # key lengths

      distances = Array.new
      first_word = dupwords[0]
      i = 1
      while i < dupwords.length
        next_word = dupwords[i]
        if next_word.word == first_word.word
          distances.push next_word.offset - first_word.offset
        end
        first_word = next_word
        i += 1
      end

      # Next, find common multiples of these distances
      factors = Array.new
      for d in distances
        factors.push(Kasiski.factors_of(d))
      end

      # I have an array of factor arrays at this point, want to find the intersection of common elements
      common_factors = factors[0]
      i = 1
      while i < factors.length
        common_factors = common_factors & factors[i]
        # puts "#{i}: #{common_factors}"
        i += 1
      end

      # Eliminate any factor less than 4 as unrealistically short
      common_factors.flatten!.reject! { |n| n < 4}
    end

    def Kasiski.factors_of(num)
      (1..num).collect { |n| [n] if ((num/n) * n) == num}.compact
    end

end
