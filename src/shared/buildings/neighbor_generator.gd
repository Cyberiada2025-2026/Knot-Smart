@tool
extends Node3D
class_name NeighborGenerator

@export var all_walls_vis_parent: Node3D
@export var open_walls_vis_parent: Node3D
@export_tool_button("Toggle neighbors") var toggle_neighbor_action = toggle_all_walls_vis
@export_tool_button("Toggle open_walls") var toggle_ow_action = toggle_open_walls_vis

var all_walls_vis_on: bool = false
var open_walls_vis_on: bool = false

var neighbors: Array[BorderInfo]
var cells: Array[Cell]


func generate_neighbors(new_cells: Array[Cell]) -> Array[BorderInfo]:
	clear_neighbors()

	cells = new_cells
	create_neighbor_graph()
	create_msp()

	choose_door_positions()
	return neighbors


func clear_neighbors():
	neighbors.clear()
	clear_all_walls_vis()
	clear_open_walls_vis()


func create_neighbor_graph() -> void:
	clear_neighbors()

	for i in cells.size():
		for j in range(i, cells.size()):
			var neighbor_info = cells[i].get_neighbor_info(cells[j])
			if neighbor_info.is_overlapping:
				neighbor_info.neighbor_a = i
				neighbor_info.neighbor_b = j
				if cells[i].center().y != cells[j].center().y:
					neighbor_info.edge_weight += 2
				if is_hallway(cells[i]) or is_hallway(cells[j]):
					neighbor_info.edge_weight -= 1
				neighbors.push_back(neighbor_info)


func is_hallway(cell: Cell) -> bool:
	return (cell.size_x() == 1 or cell.size_y() == 1) and cell.area() != 1


func compare_edge_weights_asc(a: BorderInfo, b: BorderInfo) -> bool:
	return a.edge_weight < b.edge_weight


func create_msp() -> void:
	var all_edges = neighbors
	all_edges.sort_custom(compare_edge_weights_asc)

	var uf = DisjointSet.create(cells.size())
	for e in all_edges:
		if uf.is_in_same_set(e.neighbor_a, e.neighbor_b):
			continue
		e.is_open = true
		uf.union(e.neighbor_a, e.neighbor_b)


func choose_door_positions():
	for n in neighbors:
		if n.is_open:
			n.set_door_position()


# Visualizations


func toggle_all_walls_vis():
	if all_walls_vis_on:
		clear_all_walls_vis()

	else:
		all_walls_vis_on = true
		for n in neighbors:
			spawn_visualization(all_walls_vis_parent, n, Color(1, 1, 1, 1))


func toggle_open_walls_vis():
	if open_walls_vis_on:
		clear_open_walls_vis()

	else:
		open_walls_vis_on = true
		for w in neighbors:
			if w.is_open == false:
				continue
			spawn_visualization(open_walls_vis_parent, w, Color(1, 0, 0, 1))


func spawn_visualization(parent: Node3D, n: BorderInfo, color: Color):
	var box: CSGBox3D = CSGBox3D.new()
	box.size = n.size()
	box.position = n.center()
	box.name = str(n.neighbor_a, " - ", n.neighbor_b)

	var material = StandardMaterial3D.new()
	material.albedo_color = color
	box.material = material

	parent.add_child(box)
	box.owner = get_tree().edited_scene_root


func clear_open_walls_vis():
	for w in open_walls_vis_parent.get_children():
		w.queue_free()
	open_walls_vis_on = false


func clear_all_walls_vis():
	for n in all_walls_vis_parent.get_children():
		n.queue_free()
	all_walls_vis_on = false
