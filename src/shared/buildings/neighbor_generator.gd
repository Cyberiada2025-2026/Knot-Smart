@tool
class_name NeighborGenerator
extends Node

var room_generator: RoomGenerator


func generate_neighbors(_room_generator: RoomGenerator) -> void:
	room_generator = _room_generator

	create_neighbor_graph()
	create_msp_kruskal()

	choose_door_positions()


func create_neighbor_graph() -> void:
	room_generator.neighbors.clear()

	for i in room_generator.cells.size():
		for j in range(i, room_generator.cells.size()):
			var neighbor_info = room_generator.cells[i].get_neighbor_info(room_generator.cells[j])
			if neighbor_info.is_overlapping:
				room_generator.neighbors.push_back(neighbor_info)


func create_msp_kruskal() -> void:
	var all_edges = room_generator.neighbors
	all_edges.sort_custom(func(a, b): return a.edge_weight < b.edge_weight)

	for i in room_generator.cells.size():
		room_generator.cells[i].id = i

	var cell_disjoint_set = DisjointSet.new(room_generator.cells.size())
	for e in all_edges:
		if cell_disjoint_set.is_in_same_set(e.neighbor_a.id, e.neighbor_b.id)[0]:
			continue
		e.is_open = true
		cell_disjoint_set.union(e.neighbor_a.id, e.neighbor_b.id)


func choose_door_positions():
	for n in room_generator.neighbors:
		if n.is_open:
			n.set_door_position()
