extends Node

class_name SpeechManager

const PATH := "res://shared/sfx/alien_speech/"
const SPEECH := preload("res://shared/sfx/alien_speech/speech.json").data

@export var curr_sentence = []
@export var base_pitch := 1.1
@export var pitch_dif := 0.05
@export var shorten_amount := 0.8
@export var pause_between_sentence := 0.25

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
signal finished_playing

var speech_types: Dictionary
var current_mood: String


func _ready() -> void:
	speech_types = load_speech()


func load_speech() -> Dictionary:
	var moods: Dictionary = {}
	for mood in SPEECH:
		moods[mood] = load_mood(SPEECH[mood])
	return moods


func load_mood(mood: Variant) -> Dictionary:
	var dict: Dictionary
	for syllabe in mood:
		dict[syllabe] = load(PATH + mood[syllabe])
	return dict


func set_mood(mood: String):
	current_mood = mood


func play_sound(sound: String, cut_ending: bool = true) -> void:
	var sound_file: AudioStream = speech_types[current_mood][sound]
	audio_stream_player.stream = sound_file
	audio_stream_player.pitch_scale = base_pitch + randf_range(-pitch_dif, pitch_dif)
	audio_stream_player.play()

	if cut_ending:
		var play_duration := sound_file.get_length() * shorten_amount

		await get_tree().create_timer(play_duration).timeout
		audio_stream_player.stop()
		audio_stream_player.emit_signal("finished")


func play_speech(input: Array) -> void:
	const CUT_ENDING := true
	const PLAY_FULL := false
	for sentence in input:
		for word in sentence:
			# Odtwarzanie wszystkich głosek oprócz ostatniej
			for i in range(len(word) - 1):
				play_sound(word[i], CUT_ENDING)  # cut_ending = true
				# Czekamy na zakończenie skróconego odtwarzania
				await audio_stream_player.finished

			# Odtwarzanie ostatniej głoski bez skracania
			play_sound(word.back(), PLAY_FULL)  # cut_ending = false
			await audio_stream_player.finished

		# Przerwa między zdaniami
		await get_tree().create_timer(pause_between_sentence).timeout

	finished_playing.emit()
