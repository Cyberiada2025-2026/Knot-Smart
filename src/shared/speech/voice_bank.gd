@tool
class_name VoiceBank
extends Resource

const LANGUAGE_CONSTANTS = preload("res://shared/language_generation/language_constants.json")
@export var syllables: Dictionary[String, AudioStream] = {}
@export var base_pitch := 1.1
@export var pitch_variance := 0.05
@export var shorten_amount := 0.8
@export var pause_between_sentence := 0.1

func _init():
	var syllable_list = LANGUAGE_CONSTANTS.data.syllables
	for name in syllable_list:
		if not syllables.has(name):
			syllables[name] = null
