class_name StunnableComponent
extends Node

@export var player_physics: PlayerPhysics
@export var gravity_controller: GravityController


func _on_hit_box_entered(node: Node) -> void:
	var children = node.find_children("", "StunComponent")
	if children.size() == 0:
		return

	var stun_component = children[0]
	if stun_component == null:
		return

	var prev_speed = player_physics.speed
	player_physics.speed *= stun_component.speed_multiplier
	gravity_controller.are_sensors_locked = true
	gravity_controller.are_sensors_active = false

	await get_tree().create_timer(stun_component.stun_duration).timeout

	gravity_controller.are_sensors_locked = false
	player_physics.speed = prev_speed
