class_name HitBox
extends Area3D

@export var health_component: Node


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	


func _on_area_entered(area: Area3D) -> void:
	var hurt_box = area as HurtBox
	if hurt_box == null:
		return

	health_component.health -= hurt_box.get_damage()
