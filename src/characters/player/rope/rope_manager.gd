class_name RopeManager
extends Node3D

@export var control_strategy: ControlStrategyInterface

var sphere: MeshInstance3D = preload("uid://ymb8m1pspwfy").instantiate()


func _ready() -> void:
	add_child(sphere)


func _physics_process(_delta: float) -> void:
	sphere.hide()

	if not get_node("../PlayerCamera").get_view_type() == PlayerCamera.ViewType.FIRST_PERSON:
		return

	var raycast_result = UnsafeRaycastBuilder.new(self).enable_collisions_with_areas().raycast()
	if not raycast_result.is_empty():
		sphere.position = raycast_result.position
		sphere.show()

	if Input.is_action_just_pressed("left_mouse"):
		control_strategy.use_rope(raycast_result)
	if Input.is_action_just_pressed("break_rope"):
		control_strategy.break_rope(raycast_result)
	if Input.is_action_just_pressed("fuse"):
		control_strategy.fuse(raycast_result)
	if Input.is_action_just_pressed("select_player"):
		control_strategy.select_player(raycast_result)
