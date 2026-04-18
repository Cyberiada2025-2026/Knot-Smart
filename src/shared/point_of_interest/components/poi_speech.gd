class_name POI_Speech
extends Node

@export var dialogue: Dialogue


func _ready() -> void:
	get_parent().triggered.connect(_on_trigger)


func _on_trigger(entity: Node3D):
	for sentence in dialogue.sentences:
		var subtitle = sentence.text
		SubtitleManager.display(subtitle)
		var translated = LanguageGenerator.process_dialogue(subtitle)
		await entity.get_node("SpeechManager").play_speech(translated)
		SubtitleManager.hide()
	queue_free()
