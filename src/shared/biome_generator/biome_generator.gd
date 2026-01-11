extends Node3D

@export_category("GeneratorNodes")
@export var pointScene: String		= "res://shared/biome_generator/debug/generator_point_mesh.tscn"
@export var lineScene: String		= "res://shared/biome_generator/debug/generator_line_mesh.tscn"
@export var wallScene: String		= "res://shared/biome_generator/wall.tscn"
@export_category("Biomes")
@export var biomes: Dictionary[String, int] = {
	"start": 20,
	"sklepowy": 20
}
@export_category("GeneratorVariables")
@export var sizeX: float 					= 200
@export var sizeZ: float 					= 200
@export var pointsRandomizeInX: float 		= 4.5
@export var pointsRandomizeInZ: float 		= 4.5
@export var startX: float 					= 100
@export var startZ: float 					= 100
@export var pointsInX: int 					= 19
@export var pointsInZ: int 					= 19

var s: int = 0
var points: Array[Vector2]
var lines: Array[Vector2]
var lineNodes: Dictionary[Vector2, Node3D]
var trianglesLine1: Array[int]
var trianglesLine2: Array[int]
var trianglesLine3: Array[int]
var biomesLines: Array
var setTriangles

func _ready() -> void:
	s = pointsInX
	generate()
	
	


func generate() -> void:
	_set_points()
	_randomize_points()
	_set_lines_and_triangles()
	_show_lines()
	_set_biome()


func _set_points() -> void:
	for z: int in range(pointsInX):
		for x: int in range(pointsInZ):
			points.append(Vector2((x+1)*(sizeX/(pointsInX+1)), (z+1)*(sizeZ/(pointsInZ+1))))


func _randomize_points() -> void:
	for z: int in range(1, pointsInX-1):
		for x: int in range(1, pointsInZ-1):
			var i:int = z*s+x
			#print(i%s, "  ", i/s, "  ", points[i])
			points[i].x += (2*randf()-1) * pointsRandomizeInX
			points[i].y += (2*randf()-1) * pointsRandomizeInZ


func _set_lines_and_triangles() -> void:
	for z: int in range(pointsInX-1):
		for x: int in range(pointsInZ-1):
			var i:int = z*s+x
			lines.append(Vector2(i, i+1))
			lines.append(Vector2(i, i+s))
			lines.append(Vector2(i+1, i+1+s))
			lines.append(Vector2(i+s, i+1+s))
			trianglesLine1.append(lines.size())
			trianglesLine1.append(lines.size())
			if randi()%2 == 1:
				trianglesLine2.append(lines.size()-2)
				trianglesLine3.append(lines.size()-4)
				trianglesLine2.append(lines.size()-1)
				trianglesLine3.append(lines.size()-3)
				lines.append(Vector2(i, i+1+s))
			else:
				trianglesLine2.append(lines.size()-3)
				trianglesLine3.append(lines.size()-4)
				trianglesLine2.append(lines.size()-1)
				trianglesLine3.append(lines.size()-2)
				lines.append(Vector2(i+1, i+s))



func _set_biome() -> void:
	for b in biomes:
		var biomeLines: Array[int]
		var biomeTriangles: Array[int]
		biomesLines.append(biomeLines)
		var startT: int = randi_range(0, trianglesLine1.size()-1)
		biomeLines.append(trianglesLine1[startT])
		biomeLines.append(trianglesLine2[startT])
		biomeLines.append(trianglesLine3[startT])
		for i in range(biomes[b]-1):
			#var l: int = biomesLines.pick_random()
			pass





func _show_points() -> void:
	for p: Vector2 in points:
		var mesh: MeshInstance3D = load(pointScene).instantiate()
		mesh.position.x = p.x - startX
		mesh.position.z = p.y - startX
		mesh.position.y = 0
		self.add_child(mesh)
		#print(p)


func _show_lines() -> void:
	for l: Vector2 in lines:
		var mesh: MeshInstance3D = load(lineScene).instantiate()
		lineNodes.set(l, mesh)
		mesh.mesh.resource_local_to_scene = true
		var a: float = points[l.x].x - points[l.y].x
		var b: float = points[l.x].y - points[l.y].y
		var c: float = sqrt(pow(a, 2) + pow(b, 2))
		mesh.mesh.size.x = c
		mesh.rotation.y = -atan(b/a)
		mesh.position.x = points[l.x].x - startX - a/2
		mesh.position.z = points[l.x].y - startZ - b/2
		self.add_child(mesh)
		#print(l)
