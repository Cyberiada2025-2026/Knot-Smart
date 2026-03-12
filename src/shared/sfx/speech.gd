class_name Speech
extends Node

@export var mood: AlienMoods.Moods
var path := "res://shared/sfx/alien_speech/"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for key in speech_type.sounds.keys():
		speech_type.sounds[key] = load(path + AlienMoods.get_mood_name(mood) + "/" + key + ".wav")
