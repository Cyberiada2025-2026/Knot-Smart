class_name Speech
extends Node

@export var mood: AlienMoods.Moods
var speech_type: SpeechType
var path :=


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	speech_type = SpeechType.new()
	for key in speech_type.sounds.keys():
		speech_type.sounds[key] = load(path + AlienMoods.get_mood_name(mood) + "/" + key + ".wav")
