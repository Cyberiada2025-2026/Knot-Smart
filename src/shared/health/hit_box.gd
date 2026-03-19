class_name HitBox
extends Area3D
## Area where an object can be hit in order to cause damage.
## Damage will be based on DamageComponents attatched to the other node.
## Control over what can damage the hitbox is set using physics collision layer masks.


@export var health_component: Node


func _ready() -> void:
	area_entered.connect(_on_damage_entered)
	body_entered.connect(_on_damage_entered)


func _on_damage_entered(node: Node) -> void:
	var damage_components = node.get_children().filter(func(c): return c.has_method("get_damage"))
	for damage in damage_components:
		health_component.health -= damage.get_damage()
