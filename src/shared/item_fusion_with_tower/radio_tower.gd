class_name RadioTower
extends StaticBody3D

signal all_parts_fused

@export var number_of_parts: int = 4
var number_of_fused_parts = 0


func item_fused():
	number_of_fused_parts += 1
	print("something fused with tower, num of fused parts: ", number_of_fused_parts)

	if number_of_fused_parts >= number_of_parts:
		print("Fused all parts with tower")
		all_parts_fused.emit()
