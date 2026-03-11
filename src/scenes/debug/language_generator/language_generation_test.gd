extends Node


func _ready() -> void:
	var dialogues = load("res://scenes/debug/language_generator/dialogues.json").data
	for scene in dialogues:
		for line in dialogues[scene]:
			print(LanguageGenerator.process_dialogue(line.dialogue))

# In order to use language generator debugger,
# edit dialogues.json in this folder, then run this scene.
# The output will appear in the output feed, where each line will give
# a table of syllables, grouped into words, grouped into sentences.
#
# The format of the JSON file acts as a draft for the target
# dialogue storage format and is as following:
# {
#	"dialogue_group_name": [
#		{
#			"mood": "mood1",
#			"dialogue": "This is an example dialogue line."
#		},
#		{
#			"mood": "mood2",
#			"dialogue": "A single dialogue line does not have a length limit."
#		}
#	],
#	"other_dialogue_group": [
#		{
#			"dialogue": "The amount of groups and lines is also not strict.",
#			"some-option": "Mood is in fact not required, it's just a draft."
#			"other-option": "Only dialogue is required and read."
#		}
#	]
# }
