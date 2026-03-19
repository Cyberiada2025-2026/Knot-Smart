extends Node

@export var speech_manager : SpeechManager
var path := "res://shared/speech/alien/"

func _ready() -> void:
	var dialogues = load("res://scenes/debug/language_generator/dialogues.json").data
	var curr_dialogue = dialogues.intro_cutscene

	for line in curr_dialogue:
		print(LanguageGenerator.process_dialogue(line.dialogue))
		speech_manager.set_mood(load(path + line.mood + "/" + line.mood +".tres") as VoiceBank)
		await speech_manager.play_speech(LanguageGenerator.process_dialogue(line.dialogue))
