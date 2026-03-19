class_name SpeechManager
extends Node

signal finished_playing

@export var voice_bank : VoiceBank
var curr_sentence = []
var audio_stream_player: AudioStreamPlayer

func _init() -> void:
	audio_stream_player = AudioStreamPlayer.new()
	add_child(audio_stream_player)


func set_mood(mood: VoiceBank):
	voice_bank = mood


func play_sound(sound: String, multiplier: float = 1.0):
	var sound_file: AudioStream = voice_bank.syllables[sound]
	audio_stream_player.stream = sound_file
	var variance := randf_range(-voice_bank.pitch_variance, voice_bank.pitch_variance)
	var new_pitch := voice_bank.base_pitch + variance
	audio_stream_player.pitch_scale = new_pitch
	audio_stream_player.play()

	var play_duration := sound_file.get_length() * multiplier
	await get_tree().create_timer(play_duration).timeout
	audio_stream_player.stop()
	audio_stream_player.finished.emit()


func play_speech(input: Array):
	for sentence in input:
		for word in sentence:
			for i in range(len(word) - 1):
				await play_sound(word[i], voice_bank.length_multiplier)
			await play_sound(word.back())

		await get_tree().create_timer(voice_bank.pause_between_sentence).timeout
	finished_playing.emit()
