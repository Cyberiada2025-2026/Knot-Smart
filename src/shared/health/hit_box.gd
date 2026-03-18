class_name HitBox
extends Area3D

@export var health_component: Node


func _ready() -> void:
	area_entered.connect(_on_damage_entered)
	body_entered.connect(_on_damage_entered)


func _on_damage_entered(node: Node) -> void:
	var damage_components = node.find_children("*DamageComponent")
	for damage in damage_components:
		health_component.health -= damage.get_damage()
