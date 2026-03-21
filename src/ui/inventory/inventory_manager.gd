extends Control


enum Interact {NONE, TAKE, PUT}

@export var column_num = 7
@export var row_num = 2

var grid: GridContainer
var interactable_item: ItemDescription
var needed_items: Array[ItemDescription] = []
var interaction: Interact = Interact.NONE


func _ready() -> void:
	set_grid()
	set_cells()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if interaction == Interact.TAKE:
			add_item()
		if interaction == Interact.PUT:
			remove_item()
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
	var inventory_cell_scene = preload("res://ui/inventory/inventory_item.tscn")
	for i in range(column_num*row_num):
		var cell = inventory_cell_scene.instantiate()
		grid.add_child(cell)


func add_item():
	for cell in grid.get_children():
		if cell.is_empty() or cell.get_type()==interactable_item.item_name:
			cell.add_item(interactable_item)
			interactable_item = null
			break


func remove_item():
	for item in needed_items:
		for cell in grid.get_children():
			if cell.get_type()==item.item_name:
				cell.remove_item(item)
				break


func set_collectable_item(can_interact: bool, item: ItemDescription):
	if can_interact:
		interactable_item = item
		interaction = Interact.TAKE
	else:
		if interactable_item == null:
			interaction = Interact.NONE
			return
		if item.get_instance_id() == interactable_item.get_instance_id():
			interaction = Interact.NONE
			interactable_item = null


func set_needed_items(can_interact: bool, items: Array[ItemDescription]):
	if can_interact:
		needed_items = items
		interaction = Interact.PUT
	else:
		if needed_items.is_empty():
			interaction = Interact.NONE
			return
		if items.front().get_instance_id() == needed_items.front().get_instance_id():
			interaction = Interact.NONE
			items = []
