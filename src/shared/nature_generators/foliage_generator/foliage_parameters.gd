class_name FoliageParameters
extends Resource

@export var material: StandardMaterial3D
@export_range(1, 5, 1) var count: int = 2
@export_range(0.5, 5.0, 0.5) var scale: float = 1.0
@export_range(0.5, 5.0, 0.5) var scale_randomization: float = 1.0

@export_group("DEBUG")
@export var plane_scale: Vector3 = Vector3.ONE
@export var plane_offset = Vector3.ZERO
