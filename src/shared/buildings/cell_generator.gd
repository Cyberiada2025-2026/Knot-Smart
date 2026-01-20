@tool
extends Node3D
class_name CellGenerator

var cells: Array[Cell] = []

@export_tool_button("Toggle room visibility") var toggle_transparency_action = toggle_transparency
@export_range(0,1) var transparency: float = 0.2

@export var vis_parent: Node3D

var room_vis_on: bool = false
var gen_params: RoomGenerationParams

func toggle_transparency():
	if room_vis_on:
		clear_display_cells()
	else:
		display_cells()

func display_cells() -> void:
	for i in cells.size():
		var cell = cells[i]
		var box: CSGBox3D = CSGBox3D.new()
		box.size = cell.size()
		box.position = cell.center()
		box.name = str(i)
		var material = StandardMaterial3D.new()
		material.albedo_color = Color(randf(), randf(), randf(), transparency)
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS
		if material.albedo_color.a == 1:
			material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
		else:
			material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		box.material = material
		vis_parent.add_child(box)
		box.owner = get_tree().edited_scene_root
		room_vis_on = true

func generate_rooms(new_cells: Array[Cell], generation_params: RoomGenerationParams) -> Array[Cell]:
	cells = new_cells.duplicate_deep()
	gen_params = generation_params

	clear_display_cells()

	split_cells()
	return cells

func split_cells():
	if cells.size() == 0:
		return
	while true:
		var cell = pop_next_cell()
		if cell == null:
			break
			
		var new_cells = cell.split(gen_params)
		cells.push_back(new_cells[0])
		cells.push_back(new_cells[1])


func pop_next_cell() -> Cell:
	for i in cells.size():
		var cell = cells[i]
		if cell.size_y() > gen_params.max_room_size.y:
			cells.remove_at(i)
			return cell
		if (cell.size_x() > gen_params.max_room_size.x and cell.size_x() > gen_params.max_room_size.y) or (cell.size_x() > gen_params.max_room_size.z and cell.size_x() > gen_params.max_room_size.z):
			cells.remove_at(i)
			return cell
	return null

func clear_display_cells():
	for c in vis_parent.get_children():
		c.queue_free()
	room_vis_on = false

func print_cells():
	var max_x = 0 
	var max_z = 0

	for cell in cells:
		if cell.end.x > max_x:
			max_x = cell.end.x
		if cell.end.z > max_z:
			max_z = cell.end.z

	var grid: Array[int] = []
	grid.resize(max_x*max_z)
	grid.fill(-1)

	for i in cells.size():
		var cell = cells[i]
		for x in range(cell.start.x, cell.end.x):
			for z in range(cell.start.z, cell.end.z):
				grid[z*max_x + x] = i 
	
	for i in max_z:
		#print(grid.slice(i*max_x, (i+1)*max_x))
		pass

