class_name POI_Speech
extends Node

@export var subtitle: String


func _ready() -> void:
	get_parent().triggered.connect(_on_trigger)


func _on_trigger(entity: Node3D):
	SubtitleManager.display(subtitle)
	var translated = LanguageGenerator.process_dialogue(subtitle)
	await entity.get_node("SpeechManager").play_speech(translated)
	SubtitleManager.hide()
	queue_free()
