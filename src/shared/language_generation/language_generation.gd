class_name LanguageGeneretion


extends Node


# we need to move these consts out
const SYLLABLES = [
	"zip", "ba", "rim", "waeb", "ga", "womp", "go", "lip", "blop", "zop", "lle", "si"
]
const PRESETS = {"kurwa": ["waeb", "ba"], "mać": ["zip"], "do": ["zip"], "widzenia": ["zop"]}
var syllable_count = len(SYLLABLES)
var noise = FastNoiseLite.new()

var regex_sentence = RegEx.create_from_string("(?:(?:\\p{Z}|\\p{P})?[\\p{L}\\p{N}\\p{S}])+")
var regex_word = RegEx.create_from_string("\\p{L}+")


func preprocess_string(input_str: String):
	var output = []
	input_str = input_str.to_lower()

	for sentence in regex_sentence.search_all(input_str):
		var sentence_output = []
		for word in regex_word.search_all(sentence.get_string()):
			sentence_output.push_back(word.get_string())
		output.push_back(sentence_output)

	return output


func translate_array(input_array: Array):
	var output_line_array = []

	for sentence in input_array:
		var output_word_array = []

		for word in sentence:
			if word in PRESETS:
				output_word_array.push_back(PRESETS[word])
				continue

			while word.length() < 2:
				word += " "

			var height_map = []
			for i in range(word.length() - 1):
				# iterating through pairs of letters and checking the noise value for that pair
				height_map.append(noise.get_noise_2d(word.unicode_at(i), word.unicode_at(i + 1)))

			var output_word = []

			for i in range(height_map.size()):
				if i > 0 and height_map[i] <= height_map[i - 1]:
					continue
				if i < height_map.size() - 1 and height_map[i] <= height_map[i + 1]:
					continue
				# the number must be bigger than the neighbours in order to generate a syllable
				# in other words, the height must be a local peak

				var result_syllable_id = abs(hash(height_map[i])) % syllable_count
				output_word.push_back(SYLLABLES[result_syllable_id])

			# joining SYLLABLES into word
			output_word_array.push_back(output_word)

		# joining words into a sentence
		output_line_array.push_back(output_word_array)

	# joining lines into the output
	return output_line_array


func process_dialogue(input_str):
	var input_array = preprocess_string(input_str)
	return translate_array(input_array)


func _ready() -> void:
	pass
