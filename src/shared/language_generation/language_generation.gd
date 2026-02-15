extends Node

# Constants
var syllables = []
var syllable_count = 0
var final_seed = 0

func process_dialogue(input_str: String, seed_val: int = final_seed, seed_seeking_mode: bool = false):
	# Seed seeking mode avoids generating text from empty arrays during calls from find_seed_from_preset_words()
	
	# this regex checks if a character is alphabetical
	var regex = RegEx.new()
	regex.compile('\\p{L}')
	
	var input_line_array = input_str.split('\n')
	var output_line_array = []
	
	for x in range(input_line_array.size()):
		var input_word_array = input_line_array[x].split(' ', false)
		var output_word_array = []
		
		for y in range(input_word_array.size()): # Words to tablica słów 
			var input_word = input_word_array[y]
			
			var word_core = ''
			# word_end is a place for interpuntion and other non-alphabetical characters
			# used only in text preview output
			var word_end = '' 
			
			for i in range(input_word.length()):
				var char_str = input_word[i]
				# Separating the word and interpunction
				if regex.search(char_str):
					word_core += char_str
				else:
					word_end += char_str
			
			# The alghorithm needs words to be at least 2 characters long
			while word_core.length() < 2:
				word_core += ' '
			
			var height_map = []
			
			for i in range(word_core.length() - 1):
				seed(seed_val + 100*word_core.unicode_at(i) + word_core.unicode_at(i+1))
				# Making the actual seed dependent on the letters modified gives enough variance for the seed finder to not softlock
				# while preserving rhymes between input and output
				
				var val1 = word_core.unicode_at(i)
				var val2 = word_core.unicode_at(i+1)
				
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
				
				seed(hash(height_map[i]))
				# height map is a table of floats, hashing gives int
				
				var result_syllable_id = randi() % syllable_count
				if seed_seeking_mode:
					output_word += [result_syllable_id]
				else:
					output_word += [syllables[result_syllable_id]]
			
			# joining syllables into word
			output_word_array += [output_word]
		
		# joining words into a line
		output_line_array += [output_word_array]
	
	# joining lines into the output
	return output_line_array

func create_debug_output(content: Array):
	var debug_str = ''
	for x in range(content.size()):
		var line = ''
		for y in range(content[x].size()):
			var word = ''
			for z in range(content[x][y].size()):
				word += '%x' % content[x][y][z]
			line += word + ' '
		debug_str += line + '\n'
	return debug_str

func find_seed_from_preset_words():
	const available_syllables = ['zip', 'ba', 'rim', 'web', 'ga', 'womp', 'go', 'lip', 'blop', 'zop', 'le', 'si']
	var mapping = {}
	var mapping_inverse = {}
	
	syllable_count = len(available_syllables)
	
	const words = 'Dzień dobry\nDo widzenia'
	const expected_result = [
		[['web', 'ba'], ['zip']],
		[['zip'], ['zop']]
	]
	
	var temp_seed_val = 0
	
	while temp_seed_val < 100000: # Currently this cap is reached in about 4 seconds - IMO too much
		# but I think the algorithm should be optimised rather than cap reduced
		var output = process_dialogue(words, temp_seed_val, true)
		var fail = false
		
		for x in range(len(expected_result)):
			if fail == true:
				break
			
			for y in range(len(expected_result[x])):
				if len(expected_result[x][y]) != len(output[x][y]):
					fail = true
				if fail == true:
					break
				
				for z in range(len(expected_result[x][y])):
					if expected_result[x][y][z] not in mapping and output[x][y][z] not in mapping_inverse:
						mapping[expected_result[x][y][z]] = output[x][y][z]
						mapping_inverse[output[x][y][z]] = expected_result[x][y][z]
					elif expected_result[x][y][z] not in mapping or mapping[expected_result[x][y][z]] != output[x][y][z]:
						fail = true
						break
		
		if fail == false:
			break
		
		mapping = {}
		mapping_inverse = {}
		temp_seed_val += 1
	
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
	find_seed_from_preset_words()
