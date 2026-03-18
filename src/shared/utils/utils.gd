class_name Utils
extends Node

# Vector3i.Axis doesn't have its dictionary equivalent, so the redefinition is necessary
enum Axis {
	X = Vector3i.Axis.AXIS_X,
	Y = Vector3i.Axis.AXIS_Y,
	Z = Vector3i.Axis.AXIS_Z,
}

static func normalize(value: float, range_min: float, range_max: float) -> float:
	return (value - range_min)/(range_max - range_min)
