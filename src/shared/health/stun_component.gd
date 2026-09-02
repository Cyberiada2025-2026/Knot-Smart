class_name StunComponent
extends Node
## Slows down the alien and makes it lose its grip on walls and ceilings.

@export var stun_duration: float
@export_range(0, 1) var speed_multiplier: float
