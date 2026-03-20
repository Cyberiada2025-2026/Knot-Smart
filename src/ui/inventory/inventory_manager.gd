@tool
extends Control


@export var column_num = 7
@export var row_num = 2
@export_tool_button("Run", "Callable") var run = set_cells

var grid: GridContainer
var can_interact: bool = false
var interactable_item: Node3D


func _ready() -> void:
	set_grid()
	set_cells()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		pass
	if event.is_action_pressed("check_inventory"):
		grid.visible = not grid.visible


func set_grid():
	set_anchors_preset(Control.PRESET_FULL_RECT)
	size = Vector2(320.0, 240.0)
	position = Vector2(0.0, 170.0)
	grid = GridContainer.new()
	grid.size = Vector2(320.0, 70.0)
	grid.visible = false
	add_child(grid)


func set_cells():
	for child in grid.get_children():
		child.queue_free()
	grid.columns = column_num
	for i in range(column_num*row_num):
		var cell = InventoryCell.new()
		grid.add_child(cell)


func add_item(item: ItemDescription):
	for cell in grid.get_children():
		if cell.is_empty() or cell.get_type()==item.name:
			cell.add_item(item)
			break


func remove_item(item: ItemDescription):
	for cell in grid.get_children():
		if cell.get_type()==item.name:
			cell.remove_item()
