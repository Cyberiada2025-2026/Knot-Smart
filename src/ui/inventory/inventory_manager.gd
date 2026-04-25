class_name InventoryManager
extends Control


const SIZE = Vector2(320.0, 240.0)
const POSITION = Vector2(0.0, 170.0)
const GRID_SIZE = Vector2(320.0, 70.0)

@export var column_num = 7
@export var row_num = 2
@export var area: Area3D

var grid: GridContainer
var items_node: Node3D = null
var inventory_cell: PackedScene


func _ready() -> void:
	inventory_cell = preload("uid://cqikghn2wbpuv")
	set_grid()
	set_cells()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		interact()
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


func interact():
	get_items_node()
	if items_node == null:
		return
	var items = items_node.get_items()
	for item in items:
		for cell in grid.get_children():
			if items_node is PutItemZone:
				if cell.get_type()==item.item_name:
					items[item] = cell.remove_item(item, items[item])
					break
			elif items_node is TakeItemZone:
				if cell.get_type()==item.item_name or cell.is_empty():
					cell.add_item(item)
					items_node = null
					break


func get_items_node():
	for body in area.get_overlapping_bodies():
		print(body.name)
		for child in body.get_children():
			if child is TakeItemZone or child is PutItemZone:
				items_node = child
				return
