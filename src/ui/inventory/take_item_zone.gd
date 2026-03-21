class_name TakeItemZone
extends Area3D


@export var item: ItemDescription


func _ready() -> void:
	body_entered.connect(_on_area_3d_body_entered)
	body_exited.connect(_on_area_3d_body_exited)
	

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is PlayerPhysics:
		InventoryManager.set_collectable_item(true, item)
	
	
func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is PlayerPhysics:
		InventoryManager.set_collectable_item(false, item)
