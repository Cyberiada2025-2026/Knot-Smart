class_name TreeParameters
extends Resource

@export var diff: float = 0.8
@export var tex_path: String = "res://shared/tree_generator/kora.png"

# trunk
@export var levels = 3 # num of stripes
@export var r = 0.8 # radius
@export var r_low = 0.85 # pace of radius shrinking
@export var sides = 6 # faces num of one stripe
@export var h: float = 1.0 # stripe length

# branches
@export var min_count = 3
@export var max_count = 6
@export var rec_level = 2 # num of recursive levels of branches
@export var levels_branch = 5
@export var r_branch = 0.3
@export var r_low_branch = 0.85
@export var sides_branch = 4
@export var h_branch: float = 1.0
