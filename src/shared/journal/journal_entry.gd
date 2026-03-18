extends HBoxContainer

var model: Node3D

func addEntry(obj_des: ObjectDescription) -> void:
	pass

func _ready() -> void:
	model = null

func _process(_delta: float) -> void:
	if(model!=null):
		model.rotate_y(0.1)
