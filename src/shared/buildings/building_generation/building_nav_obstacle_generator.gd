@tool
class_name BuildingNavObstacleGenerator
extends RefCounted

const NAV_MESH_OBSTACLE_HEIGHT: float = 100.0

var building_generator: BuildingGenerator


func _init(_building_generator: BuildingGenerator) -> void:
	building_generator = _building_generator


func generate_navmesh_obstacles() -> void:
	var scaling: Vector3 = building_generator.grid_cell_size

	for cell in building_generator.initial_cells:
		var outline = cell.get_base_vertices(scaling)

		var obstacle = NavigationObstacle3D.new()
		obstacle.affect_navigation_mesh = true
		obstacle.avoidance_enabled = false
		obstacle.height = NAV_MESH_OBSTACLE_HEIGHT
		obstacle.vertices = outline
		obstacle.visible = false

		building_generator.add_child(obstacle)


func clear() -> void:
	for obstacle in building_generator.find_children("", "NavigationObstacle3D"):
		obstacle.queue_free()
