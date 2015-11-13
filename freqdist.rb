# http://a-rne.tumblr.com/post/32006036891/character-frequency-analysis-part-2

@gen_char_freq={"a"=>8.167,"b"=>1.492,"c"=>2.782,"d"=>4.253,"e"=>12.702,"f"=>2.228,"g"=>2.015,"h"=>6.094,"i"=>6.966,"j"=>0.153, "k"=>0.747,"l"=>4.025,"m"=>2.406,"n"=>6.749,"o"=>7.507,"p"=>1.929,"q"=>0.095,"r"=>5.987,"s"=>6.327,"t"=>9.056, "u"=>2.758,"v"=>1.037,"w"=>2.365,"x"=>0.150,"y"=>1.974,"z"=>0.074}
frequency_results = [["z", 12.609], ["v", 8.696], ["o", 8.696], ["j", 7.826], ["c", 6.957], ["i", 5.652], ["d", 5.217], ["n", 4.348], ["m", 4.348], ["x", 3.478], ["g", 3.478], ["t", 3.478], ["h", 3.478], ["r", 3.043], ["y", 3.043], ["k", 2.174], ["p", 2.174], ["q", 1.739], ["a", 1.304], [".", 1.304], [",", 1.304], ["f", 1.304], ["w", 1.304], ["?", 0.87], ["'", 0.87], ["!", 0.435], ["b", 0.435], ["l", 0.435]]

def match_char(hash_results)
  dist = 100
  dist_c = ""
  match_hash = Hash.new
  hash_results.each { |a,b| @gen_char_freq.each { |c,d| dist,dist_c = (d-b).abs, c if (d-b).abs < dist}
    match_hash[a],dist = dist_c,100}
  return match_hash
end

r = match_char(frequency_results)

puts "#{r}"