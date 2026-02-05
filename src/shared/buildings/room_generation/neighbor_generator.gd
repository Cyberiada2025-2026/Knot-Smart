@tool
class_name NeighborGenerator
extends Node

var building_generator: BuildingGenerator


func generate_neighbors(_building_generator: BuildingGenerator) -> void:
	building_generator = _building_generator

	create_neighbor_graph()
	create_msp_kruskal()

	choose_door_positions()


func create_neighbor_graph() -> void:
	building_generator.neighbors.clear()

	for i in building_generator.cells.size():
		for j in range(i, building_generator.cells.size()):
			var neighbor_info = building_generator.cells[i].get_neighbor_info(
				building_generator.cells[j]
			)
			if neighbor_info.is_overlapping:
				building_generator.neighbors.push_back(neighbor_info)


func create_msp_kruskal() -> void:
	var all_edges = building_generator.neighbors
	all_edges.sort_custom(func(a, b): return a.edge_weight < b.edge_weight)

	for i in building_generator.cells.size():
		building_generator.cells[i].id = i

	var cell_disjoint_set = DisjointSet.new(building_generator.cells.size())
	for e in all_edges:
		if cell_disjoint_set.is_in_same_set(e.neighbor_a.id, e.neighbor_b.id)[0]:
			continue
		e.is_open = true
		cell_disjoint_set.union(e.neighbor_a.id, e.neighbor_b.id)


func choose_door_positions():
	for n in building_generator.neighbors:
		if n.is_open:
			n.set_door_position()
