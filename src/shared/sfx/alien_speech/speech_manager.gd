class_name SpeechManager
extends Node

signal finished_playing
signal sound_finished

@export var curr_sentence = []
@export var base_pitch := 1.1
@export var pitch_variance := 0.05
@export var shorten_amount := 0.8
@export var pause_between_sentence := 0.1

var speech_data := preload("res://shared/sfx/alien_speech/speech.json").data
var path := "res://shared/sfx/alien_speech/"
var speech_types: Dictionary
var current_mood: String

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _init() -> void:
	audio_stream_player = AudioStreamPlayer.new()
	add_child(audio_stream_player)
	speech_types = load_speech()


func load_speech() -> Dictionary:
	var moods: Dictionary = {}
	for mood in speech_data:
		moods[mood] = load_mood(speech_data[mood])
	return moods


func load_mood(mood: Variant) -> Dictionary:
	var dict: Dictionary
	for syllable in mood:
		dict[syllable] = load(path + mood[syllable])
	return dict


func set_mood(mood: String):
	current_mood = mood

func set_speech_data(new_data: Variant):
	speech_data = new_data


func set_speech_dir(new_path: String):
	path = new_path


func play_sound(sound: String, cut_ending: bool = true) -> Signal:
	var sound_file: AudioStream = speech_types[current_mood][sound]
	audio_stream_player.stream = sound_file
	audio_stream_player.pitch_scale = base_pitch + randf_range(-pitch_variance, pitch_variance)
	audio_stream_player.play()

	if cut_ending:
		var play_duration := sound_file.get_length() * shorten_amount
		await get_tree().create_timer(play_duration).timeout
		audio_stream_player.stop()
		audio_stream_player.finished.emit()
	return audio_stream_player.finished

func play_speech(input: Array) -> Signal:
	const CUT_ENDING := true
	const PLAY_FULL := false
	for sentence in input:
		for word in sentence:
			for i in range(len(word) - 1):
				await play_sound(word[i], CUT_ENDING)
			await play_sound(word.back(), PLAY_FULL)

		await get_tree().create_timer(pause_between_sentence).timeout
	finished_playing.emit()
	return finished_playing
