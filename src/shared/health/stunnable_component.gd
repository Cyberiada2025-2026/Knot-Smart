class_name StunnableComponent
extends Node

@export var hitbox: HitBox
@export var player_physics: PlayerPhysics 


func _on_hit_box_entered(node: Node) -> void:
	var stun_component = node.find_children("", "StunComponent").get(0) as StunComponent

	if stun_component == null:
		return

	var prev_speed = player_physics.speed
	player_physics.speed *= stun_component.speed_multiplier
	await get_tree().create_timer(stun_component.stun_duration).timeout
	player_physics.speed = prev_speed
