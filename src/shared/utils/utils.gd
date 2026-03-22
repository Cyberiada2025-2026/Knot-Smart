class_name Utils
extends Node

# Vector3i.Axis doesn't have its dictionary equivalent, so the redefinition is necessary
enum Axis {
	X = Vector3i.Axis.AXIS_X,
	Y = Vector3i.Axis.AXIS_Y,
	Z = Vector3i.Axis.AXIS_Z,
}

enum Axis2 {
	X = Vector2i.Axis.AXIS_X,
	Y = Vector2i.Axis.AXIS_Y,
}

static func normalize(value: float, range_min: float, range_max: float) -> float:
	return (value - range_min) / (range_max - range_min)


## Returns random point in a circular ring around the center point.
## Y_AXIS value of the returned vector equals 0.
## source: https://narimanfarsad.blogspot.com/2012/11/uniformly-distributed-points-inside_9.html
static func get_random_point_in_circular_ring(
	min_range: float, max_range: float, center: Vector3
) -> Vector3:
	var theta = randf() * 2 * PI
	var r = sqrt(pow(max_range, 2) - pow(min_range, 2) * randf() + pow(min_range, 2))
	return Vector3(center.x + r * cos(theta), 0, center.z + r * sin(theta))
