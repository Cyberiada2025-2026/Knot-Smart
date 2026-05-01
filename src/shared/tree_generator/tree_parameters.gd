class_name TreeParameters
extends Resource

@export var segment_displacement: float = 0.8
@export var material: StandardMaterial3D
## how much first branches (every branch for SIDE tree) are snatched towards the ground
@export var branch_spread_angle: float = PI / 20

@export_group("Trunk")
@export_range(1, 20, 1) var trunk_segment_count = 3
@export_range(0.1, 5.0, 0.05) var trunk_radius = 0.8
@export_range(0.1, 1.0, 0.01) var trunk_rate_of_shrinking = 0.85
@export_range(3, 10, 1) var trunk_sides = 6
@export_range(0.1, 10.0, 0.02) var trunk_segment_length: float = 1.0

@export_group("Branches")
@export_range(2, 20, 1) var min_count = 3
@export_range(2, 20, 1) var max_count = 6
@export_range(0, 5, 1) var branch_recursion_level = 2
@export_range(1, 20, 1) var branch_segment_count = 5
@export_range(0.1, 5.0, 0.05) var branch_radius = 0.3
@export_range(0.1, 1.0, 0.01) var branch_rate_of_shrinking = 0.85
@export_range(3, 10, 1) var branch_sides = 4
@export_range(0.1, 10.0, 0.02) var branch_segment_length: float = 1.0

@export_group("Type")
@export_enum("NORMAL", "SIDE") var subtype: String = "NORMAL"
