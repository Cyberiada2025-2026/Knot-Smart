extends Node3D

const SOMETHING_INTERESTING = preload("uid://crgmysckc65sm")

@onready var player_physics: PlayerPhysics = $".."
@onready var timer: Timer = $Timer


func make_footstep() -> void:
	var footstep := SOMETHING_INTERESTING.instantiate()
	get_tree().root.add_child(footstep)
	footstep.global_position = player_physics.global_position


func _physics_process(_delta: float) -> void:
	if (
		not player_physics.velocity.is_zero_approx()
		and player_physics.is_on_floor()
		and timer.is_stopped()
	):
		make_footstep()
		timer.start()


func _on_timer_timeout() -> void:
	make_footstep()
	if player_physics.velocity == Vector3.ZERO || !player_physics.is_on_floor():
		timer.stop()
