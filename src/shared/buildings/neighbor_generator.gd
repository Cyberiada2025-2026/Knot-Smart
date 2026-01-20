@tool
extends Node3D
class_name NeighborGenerator

@export var neighbor_vis_parent: Node3D
@export var entrance_vis_parent: Node3D

@export_tool_button("Toggle neighbors") var toggle_neighbor_action = toggle_neighbor_visualization
@export_tool_button("Toggle open_walls") var toggle_ow_action = toggle_ow_visualization

var nvis_on: bool = false

var neighbors: Array[BorderInfo]

var cells: Array[Cell]

func clear_neighbors():
	neighbors.clear()
	clear_nvis()
	clear_ow()

var ow_on: bool = false

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

func toggle_ow_visualization():
	if ow_on:
		clear_ow()

	else:
		ow_on = true
		for w in neighbors:
			if w.is_open == false:
				continue
			spawn_visualization(entrance_vis_parent, w, Color(1,0,0,1))
	
func clear_ow():
	for w in entrance_vis_parent.get_children():
		w.queue_free()
	ow_on = false

func clear_nvis():
	for n in neighbor_vis_parent.get_children():
		n.queue_free()
	nvis_on = false

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

func print_neighbors(ns: Array) -> void:
	for n in ns:
		print(n.neighbor_a, "-", n.neighbor_b, ": ", n.overlap_start, n.overlap_end)
	
func compare_edge_weights_asc(a: BorderInfo, b: BorderInfo) -> bool:
	return a.edge_weight < b.edge_weight

func create_msp() -> void:
	var all_edges = neighbors
	all_edges.sort_custom(compare_edge_weights_asc)

	var uf = init_union_find(cells.size())
	for e in all_edges:
		if is_in_same_set(uf, e.neighbor_a, e.neighbor_b):
			continue
		e.is_open = true
		union(uf, e.neighbor_a, e.neighbor_b)

	#print_neighbors(open_walls)


func generate_neighbors(new_cells: Array[Cell]) -> Array[BorderInfo]:
	clear_neighbors()

	cells = new_cells
	create_neighbor_graph()
	create_msp()
	
	choose_door_positions()
	return neighbors

func choose_door_positions():
	for n in neighbors:
		if n.is_open:
			n.set_door_position()

func toggle_neighbor_visualization():
	if nvis_on:
		clear_nvis()

	else:
		nvis_on = true
		for n in neighbors:
			spawn_visualization(neighbor_vis_parent, n, Color(1,1,1,1))

	
func init_union_find(size: int) -> Array:
	var uf: Array = []
	for i in size:
		uf.push_back(i)

	#print(uf)
	return uf

func union(uf: Array, id_a: int, id_b: int) -> void:
	var x = find(uf, id_a)
	var y = find(uf, id_b)

	if x == y:
		return

	uf[y] = x

func is_in_same_set(uf: Array, id_a: int, id_b: int) -> bool:
	var x = find(uf, id_a)
	var y = find(uf, id_b)

	return x == y

func find(uf: Array, id: int) -> int:
	if uf[id] == id:
		return id
	else:
		return find(uf, uf[id])
