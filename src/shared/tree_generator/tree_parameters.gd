class_name TreeParameters
extends Resource

@export var diff: float = 0.8
@export var tex_path: String = "res://shared/tree_generator/kora.png"
## how much first branches (every branch for SIDE tree) are snatched towards the ground
@export var angle: float = PI/20

@export_group("Trunk")
@export var levels = 3 ## number of stripes
@export var r = 0.8 ## radius
@export_range(0.1, 1.0, 0.01) var r_low = 0.85 ## pace of radius shrinking
@export var sides = 6 ## faces num of one stripe
@export var h: float = 1.0 ## stripe length

@export_group("Branches")
@export var min_count = 3
@export var max_count = 6
@export var rec_level = 2 ## num of recursive levels of branches
@export var levels_branch = 5
@export var r_branch = 0.3
@export_range(0.1, 1.0, 0.01) var r_low_branch = 0.85
@export var sides_branch = 4
@export var h_branch: float = 1.0

@export_group("Type")
@export_enum("NORMAL", "SIDE") var subtype: String = "NORMAL"
