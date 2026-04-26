extends ColorRect

@export var points_amount: int = 100
@export var points_param: String = "points"
@export var tint_param: String = "tint"
@export var acceleration: float = 0.1
@export var drag = 5
@export var center_pull = 0.01
@export var force: Curve
@export var sequence: Array[float]

var timer: float = 0.0
var points: Array[Vector2]
var speeds: Array[Vector2]

var spawned_cells = 1

func _ready() -> void:
	points.resize(points_amount)
	points.fill(Vector2.ONE * 10000)

	speeds.resize(points_amount)
	speeds.fill(Vector2.ZERO)

	points[0] = Vector2.ONE * 0.5

	material.set_shader_parameter(points_param, points)
	var tween = get_tree().create_tween()
	tween.tween_method(
		func(value): material.set_shader_parameter("tint", value),  
		Color.BLACK,# Start value
		Color.WHITE,	# End value
		sequence[0]# Duration
	)

func _process(delta: float) -> void:
	timer += delta
	if timer >= sequence[min(spawned_cells, sequence.size() - 1)]:
		spawn()
		timer = 0.0

	var r: Vector2

	for i in range(points_amount):
		for j in range(points_amount):
			if i != j:
				speeds[i] += force.sample(points[i].distance_to(points[j])) * (points[j] - points[i])
		r = Vector2(randf(), randf()) * 2.0 - Vector2.ONE
		speeds[i] += r * delta * acceleration
		speeds[i] += (Vector2.ONE * 0.5 - points[i]) * center_pull * delta
		speeds[i] -= speeds[i] * drag * delta
		points[i] += speeds[i] * delta

	material.set_shader_parameter(points_param, points)

func spawn() -> void:
	if spawned_cells > points_amount - 1:
		respawn_player()
		return

	var p: int = randi_range(0, spawned_cells - 1)
	points[spawned_cells] = points[p]
	spawned_cells += 1

#TODO
func respawn_player() -> void:
	pass
