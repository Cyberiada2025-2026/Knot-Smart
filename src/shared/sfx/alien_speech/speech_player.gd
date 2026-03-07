extends Node

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var speech_types: Node = $"../SpeechTypes"

var curr_sentence = []

func play_sound(
	sound: String, cut_ending: bool = true, mood: AlienMoods.Moods = AlienMoods.Moods.NEUTRAL
) -> void:
	var speech: Speech = speech_types.get_node(AlienMoods.get_mood_name(mood))
	var sound_file: AudioStream = speech.speech_type.sounds[sound]
	audio_stream_player.stream = sound_file
	audio_stream_player.pitch_scale = 1.1 + randf_range(-0.05, 0.05)
	audio_stream_player.play()

	if cut_ending:
		var play_duration := sound_file.get_length() * 0.9

		await get_tree().create_timer(play_duration).timeout
		audio_stream_player.stop()
		audio_stream_player.emit_signal("finished")


func play_speech(input: Array, mood: AlienMoods.Moods = AlienMoods.Moods.NEUTRAL) -> void:
	for sentence in input:
		for word in sentence:
			for i in range(len(word)):
				if i != len(word) - 1:
					play_sound(word[i], true, mood)
				else:
					play_sound(word[i], false, mood)
				await audio_stream_player.finished
		await get_tree().create_timer(0.25).timeout
