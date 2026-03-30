@tool
class_name BuildingNavObstacleGenerator
extends RefCounted

const NAV_MESH_OBSTACLE_HEIGHT: float = 100.0

var buidling_generator: BuildingGenerator


func generate_navmesh_obstacles(_buidling_generator: BuildingGenerator) -> void:
	buidling_generator = _buidling_generator
	var scaling: Vector3 = buidling_generator.grid_cell_size

	for cell in buidling_generator.initial_cells:
		var outline = cell.get_base_vertices(scaling)

		var obstacle = NavigationObstacle3D.new()
		obstacle.affect_navigation_mesh = true
		obstacle.avoidance_enabled = false
		obstacle.height = NAV_MESH_OBSTACLE_HEIGHT
		obstacle.vertices = outline
		obstacle.visible = false

		buidling_generator.add_child(obstacle)


func clear() -> void:
	for obstacle in buidling_generator.find_children("", "NavigationObstacle3D"):
		obstacle.queue_free()
