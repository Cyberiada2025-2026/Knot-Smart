class_name TreeParameters
extends Resource

@export var diff: float = 0.8
@export var h: float = 1.0
@export var tex_path: String = "res://shared/tree_generator/kora.png"
@export var branches_level = 2

# trunk
@export var levels = 3
@export var r = 0.8
@export var r_low = 0.85
@export var sides = 6

# branches
@export var min_count = 3
@export var max_count = 6
@export var rec_level = 2
@export var levels_branch = 5
@export var r_branch = 0.3
@export var r_low_branch = 0.85
@export var sides_branch = 4
@export var h_branch: float = 1.0
