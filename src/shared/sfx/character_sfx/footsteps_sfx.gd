extends AudioStreamPlayer3D

var character: CharacterBody3D
var time_since_last_step: float = 0

@export var step_interval: float = 0.3

func _ready() -> void:
	character = get_node("../../")
	print(character)

func _process(delta: float) -> void:
	time_since_last_step += delta
	if character.velocity.length() > 0 && time_since_last_step > step_interval:
		time_since_last_step = 0
		play()
