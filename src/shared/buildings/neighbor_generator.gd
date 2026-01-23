@tool
class_name NeighborGenerator
extends Node

var neighbors: Array[BorderInfo]
var cells: Array[Cell]


func generate_neighbors(_cells: Array[Cell]) -> Array[BorderInfo]:
	neighbors.clear()

	cells = _cells
	create_neighbor_graph()
	create_msp()

	choose_door_positions()
	return neighbors


func create_neighbor_graph() -> void:
	neighbors.clear()

	for i in cells.size():
		for j in range(i, cells.size()):
			var neighbor_info = cells[i].get_neighbor_info(cells[j])
			if neighbor_info.is_overlapping:
				neighbors.push_back(neighbor_info)


func compare_edge_weights_asc(a: BorderInfo, b: BorderInfo) -> bool:
	return a.edge_weight < b.edge_weight


func create_msp() -> void:
	var all_edges = neighbors
	all_edges.sort_custom(compare_edge_weights_asc)

	for i in cells.size():
		cells[i].id = i

	var uf = DisjointSet.create(cells.size())
	for e in all_edges:
		if uf.is_in_same_set(e.neighbor_a.id, e.neighbor_b.id):
			continue
		e.is_open = true
		uf.union(e.neighbor_a.id, e.neighbor_b.id)


func choose_door_positions():
	for n in neighbors:
		if n.is_open:
			n.set_door_position()
