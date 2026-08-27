class_name HitBox
extends Area3D
## Area where an object can be hit in order to cause damage.
## Damage will be based on DamageComponents attatched to the other node.
## Control over what can damage the hitbox is set using physics collision layer masks.

@export var health_component: Node

var j := 0

func _ready() -> void:
	area_entered.connect(_on_damage_entered_area)
	body_entered.connect(_on_damage_entered_body)
	print("signals connected")

func _physics_process(_delta: float) -> void:
	j += 1

func _on_damage_entered_body(node: Node) -> void:
	print()
	print("body entered: ", node.name, " / time from start: ", Time.get_ticks_msec(), "ms")
	print("position: ", node.global_position)
	print("physics frame: ", j)
	print()
	var damage_components = node.get_children().filter(func(c): return c.has_method("get_damage"))
	print(damage_components.size());
	for damage in damage_components:
		health_component.health -= damage.get_damage()

func _on_damage_entered_area(node: Node) -> void:
	print("area entered", node.name);
	var damage_components = node.get_children().filter(func(c): return c.has_method("get_damage"))
	print(damage_components.size());
	for damage in damage_components:
		health_component.health -= damage.get_damage()
