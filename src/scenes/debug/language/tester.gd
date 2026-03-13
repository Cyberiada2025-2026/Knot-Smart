extends Node
@onready var speech_player: Node = $"../SpeechPlayer"


func _ready() -> void:
	var dialogues = load("res://scenes/debug/language_generator/dialogues.json").data
	var curr_dialouge = dialogues.intro_cutscene
	for line in curr_dialouge:
		speech_player.set_mood(line.mood)
		speech_player.play_speech(LanguageGenerator.process_dialogue(line.dialogue))
		await speech_player.finished_playing
