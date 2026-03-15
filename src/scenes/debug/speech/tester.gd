extends Node

func _ready() -> void:
	var dialogues = load("res://scenes/debug/language_generator/dialogues.json").data
	var curr_dialogue = dialogues.intro_cutscene

	for line in curr_dialogue:
		print(LanguageGenerator.process_dialogue(line.dialogue))
		SpeechManager.set_mood(line.mood)
		await SpeechManager.play_speech(LanguageGenerator.process_dialogue(line.dialogue))
