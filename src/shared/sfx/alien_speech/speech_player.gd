extends Node

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var curr_sentence = []

var sounds = {
	'zip' : preload("uid://jp6nfk7wayqi") as AudioStream,
	'ba' : preload("uid://boxuijsvasf8") as AudioStream,
	'rim' : preload("uid://d0hlux11ub3h5") as AudioStream,
	'web' : preload("uid://m82cumlpgpmo") as AudioStream,
	'ga' : preload("uid://ddb3sgd2i2e44") as AudioStream,
	'womp' : preload("uid://crfn4exd8t2vo") as AudioStream,
	'go' : preload("uid://gdq0lrsinig5") as AudioStream,
	'lip' : preload("uid://dw2pe3xbvm1ax") as AudioStream,
	'blop' : preload("uid://ch8ym4b4kycbu") as AudioStream,
	'zop' : preload("uid://bkvgruptillh5") as AudioStream,
	'le' : preload("uid://dam1r25bqjpia") as AudioStream,
	'si' : preload("uid://brhiv2vcifgmy") as AudioStream
}

func play_speech(input: Array) -> void:
	for sentence in input:
		for word in sentence:
			for i in range(len(word)):
				if i != len(word)-1:
					play_sound(sounds[word[i]])
				else:
					play_sound(sounds[word[i]], false)
				await audio_stream_player.finished
		await get_tree().create_timer(0.75).timeout


func play_sound(sound: AudioStream, cut_ending: bool = true) -> void:
	audio_stream_player.stream = sound
	audio_stream_player.pitch_scale = 1.1 + randf_range(-0.05, 0.05)
	audio_stream_player.play()
	
	if cut_ending:
		var play_duration = sound.get_length() * 0.9
		
		await get_tree().create_timer(play_duration).timeout
		audio_stream_player.stop()
		audio_stream_player.emit_signal("finished")
