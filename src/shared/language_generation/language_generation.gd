extends Node

var syllables = []
var syllable_count = 0
var final_seed = 0

var regex_sentence = RegEx.create_from_string("(?:(?:\\p{Z}|\\p{P})?[\\p{L}\\p{N}\\p{S}])+") # matches sentences
var regex_word = RegEx.create_from_string("\\p{L}+") # matches words

func preprocess_string(input_str: String) :
	var output = []
		
	for sentence in regex_sentence.search_all(input_str):
		var sentence_output = []
		for word in regex_word.search_all(sentence.get_string()):
			sentence_output.push_back(word.get_string())
		output.push_back(sentence_output)
	
	return output

func translate_array(input_array: Array, seed_val: int = final_seed, seed_seeking_mode: bool = false):
	# Seed seeking mode avoids generating text from empty arrays during calls from find_seed_from_preset_words()
	if not seed_seeking_mode and syllable_count == 0:
		find_seed_from_preset_words()
	
	var output_line_array = []
	
	for sentence in input_array:
		var output_word_array = []
		
		for word in sentence:
			while word.length() < 2:
				word += " "
			
			var height_map = []
			
			for i in range(word.length() - 1):
				seed(seed_val + 100*word.unicode_at(i) + word.unicode_at(i+1))
				# Making the actual seed dependent on the letters modified gives enough variance for the seed finder to not softlock
				# while preserving rhymes between input and output
				
				var val1 = word.unicode_at(i)
				var val2 = word.unicode_at(i+1)
				
				height_map.append(
					val1 * randf() + 
					val2 * randf()
				)
			
			var output_word = []
			
			for i in range(height_map.size()):
				if i > 0 and height_map[i] <= height_map[i-1]:
					continue
				if i < height_map.size() - 1 and height_map[i] <= height_map[i+1]:
					continue
				# the number must be bigger than the neighbours in order to generate a syllable
				# in other words, the height must be a local peak
				
				var result_syllable_id = abs(hash(height_map[i])) % syllable_count
				if seed_seeking_mode:
					output_word.push_back(result_syllable_id)
				else:
					output_word.push_back(syllables[result_syllable_id])
			
			# joining syllables into word
			output_word_array.push_back(output_word)
		
		# joining words into a sentence
		output_line_array.push_back(output_word_array)
	
	# joining lines into the output
	return output_line_array

func process_dialogue(input_str):
	var input_array = preprocess_string(input_str)
	return translate_array(input_array)

func find_seed_from_preset_words():
	const available_syllables = ["zip", "ba", "rim", "waeb", "ga", "womp", "go", "lip", "blop", "zop", "lle", "si"]
	var mapping = {}
	var mapping_inverse = {}
	
	syllable_count = len(available_syllables)
	
	var words = "Kurwa mać\nDo widzenia"
	const expected_result = [
		[["waeb", "ba"], ["zip"]],
		[["zip"], ["zop"]]
	]
	
	words = preprocess_string(words)
	
	var temp_seed_val = 0
	while temp_seed_val < 100000: # Currently this cap is reached in about 4 seconds - IMO too much
		# but I think the algorithm should be optimised rather than cap reduced
		var output = translate_array(words, temp_seed_val, true)
		var fail = false
		
		for sentence in range(len(expected_result)):
			if fail == true:
				break
			
			for word in range(len(expected_result[sentence])):
				if len(expected_result[sentence][word]) != len(output[sentence][word]):
					fail = true
				if fail == true:
					break
				
				for z in range(len(expected_result[sentence][word])):
					if expected_result[sentence][word][z] not in mapping and output[sentence][word][z] not in mapping_inverse:
						mapping[expected_result[sentence][word][z]] = output[sentence][word][z]
						mapping_inverse[output[sentence][word][z]] = expected_result[sentence][word][z]
					elif expected_result[sentence][word][z] not in mapping or mapping[expected_result[sentence][word][z]] != output[sentence][word][z]:
						fail = true
						break
		
		if fail == false:
			break
		
		mapping.clear()
		mapping_inverse.clear()
		temp_seed_val += 1
	
	print("found seed ", temp_seed_val)
	final_seed = temp_seed_val
	
	syllables.resize(syllable_count) # extending an empty array 
	for syl in mapping:
		syllables[mapping[syl]] = syl # in order to be able to do this
	
	var grab = 0
	for i in range(syllable_count):
		while grab < syllable_count and mapping.has(available_syllables[grab]):
			grab += 1
		if syllables[i] == null:
			syllables[i] = available_syllables[grab]
			grab += 1

func _ready() -> void:
	pass
