class_name LanguageGenerator
extends Node

static var constants = preload("res://shared/language_generation/language_constants.json").data

func preprocess_string(input_str: String):
	input_str = input_str.to_lower()
	
	# swap shortenings for spoken words
	for key in constants.input_replace:
		input_str = input_str.replace(key, constants.input_replace[key])
	
	for chr in [";", "!", "?", "—"]:
		input_str = input_str.replace(chr, ".")
	
	var sentences = Array(input_str.split(".", false))
	# Split sentences into arrays of words
	sentences = sentences.map(func(sentence): return sentence.split(" ", false))
	
	return sentences
	
func translate_word(word: String):
	if word in constants.presets:
		return constants.presets[word]

	while word.length() < 2:
		word += " "

	var height_map = []
	for i in range(word.length() - 1):
		# iterating through pairs of letters and checking the noise value for that pair
		height_map.append(
			FastNoiseLite.new().get_noise_2d(word.unicode_at(i), word.unicode_at(i + 1))
		)
	var output_word = []

	for i in range(height_map.size()):
		if (
			(i > 0 and height_map[i] <= height_map[i - 1])
			or (i < height_map.size() - 1 and height_map[i] <= height_map[i + 1])
		):
			continue
		# the number must be bigger than the neighbours in order to generate a syllable
		# in other words, the height must be a local peak

		var result_syllable_id = abs(hash(height_map[i])) % len(constants.syllables)
		output_word.push_back(constants.syllables[result_syllable_id])

	return output_word


func translate_array(input_array: Array):
	
	var output_line_array = []

	for sentence in input_array:
		var output_word_array = []

		for word in sentence:
			output_word_array.push_back(translate_word(word))

		# joining words into a sentence
		output_line_array.push_back(output_word_array)

	# joining lines into the output
	return output_line_array


func process_dialogue(input_str):
	var input_array = preprocess_string(input_str)
	return translate_array(input_array)
