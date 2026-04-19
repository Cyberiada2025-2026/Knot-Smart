extends ColorRect

@export var points_amount: int = 100
@export var points_param: String = "points"
@export var acceleration: float = 0.1
@export var drag = 0.3

var time: float = 0.0
var points: Array[Vector2]
var speeds: Array[Vector2]

func _ready() -> void:
	points.resize(points_amount)
	points.fill(Vector2.ONE * 10000)
	
	speeds.resize(points_amount)
	speeds.fill(Vector2.ZERO)
	
	points[1] = Vector2.ONE * 0.5

	material.set_shader_parameter(points_param, points)

func _process(delta: float) -> void:
	time += delta
	var r: Vector2

	for i in range(points_amount):
		r = Vector2(randf(), randf()) * 2.0 - Vector2.ONE
		speeds[i] += r * delta * acceleration
		points[i] += speeds[i] * delta
		points[i] -= speeds[i] * drag * delta
	
	material.set_shader_parameter(points_param, points)
