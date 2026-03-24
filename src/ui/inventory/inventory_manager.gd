class_name InventoryManager
extends Control


var interact = {"NONE": 0, "TAKE": 1, "PUT": 2}

@export var column_num = 7
@export var row_num = 2

var grid: GridContainer
var items: Array[ItemDescription] = []
var interaction: int = interact["NONE"]
var inventory_cell: PackedScene

const SIZE = Vector2(320.0, 240.0)
const POSITION = Vector2(0.0, 170.0)
const GRID_SIZE = Vector2(320.0, 70.0)


func _ready() -> void:
	inventory_cell = preload("uid://cqikghn2wbpuv")
	set_grid()
	set_cells()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		idk_item()
	if event.is_action_pressed("toggle_inventory"):
		grid.visible = not grid.visible


func set_grid():
	set_anchors_preset(Control.PRESET_FULL_RECT)
	size = SIZE
	position = POSITION
	grid = GridContainer.new()
	grid.size = GRID_SIZE
	grid.visible = false
	add_child(grid)


func set_cells():
	for child in grid.get_children():
		child.queue_free()
	grid.columns = column_num
	for i in range(column_num*row_num):
		var cell = inventory_cell.instantiate()
		grid.add_child(cell)


func idk_item():
	for item in items:
		for cell in grid.get_children():
			if cell.get_type()==item.item_name and interaction == interact["PUT"]:
				cell.remove_item(item)
				break
			elif (cell.get_type()==item.item_name or cell.is_empty()) and interaction == interact["TAKE"]:
				cell.add_item(item)	
				break


func set_items(can_interact: bool, items: Array[ItemDescription], type: String):
	if can_interact:
		self.items = items
		interaction = interact[type]
	else:
		if self.items.is_empty():
			interaction = interact["NONE"]
			return
		if items.front().get_instance_id() == self.items.front().get_instance_id():
			interaction = interact["NONE"]
			self.items = []
