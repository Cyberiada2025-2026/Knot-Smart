class_name BaseDamageComponent
extends Node
## Deals a constant ammount of damage.

@export var base_damage: float = 1.0


func get_damage() -> float:
	return base_damage
