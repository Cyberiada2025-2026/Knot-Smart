extends Node3D

@onready var player_physics: PlayerPhysics = $".."
@onready var timer: Timer = $Timer

const SOMETHING_INTERESTING = preload("uid://crgmysckc65sm")

func make_footstep():
	var footstep := SOMETHING_INTERESTING.instantiate()
	get_tree().root.add_child(footstep)
	footstep.global_position = player_physics.global_position


func _physics_process(_delta: float) -> void:
	if player_physics.velocity != Vector3.ZERO && player_physics.is_on_floor() && timer.is_stopped():
		timer.start()



func _on_timer_timeout() -> void:
	make_footstep()
	if  player_physics.velocity == Vector3.ZERO || !player_physics.is_on_floor():
		timer.stop()
