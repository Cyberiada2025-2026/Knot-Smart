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

