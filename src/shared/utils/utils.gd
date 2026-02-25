class_name Utils
extends Node

# Vector3i.Axis doesn't have its dictionary equavalent, so the redefinition is necessary
enum Axis {
	X = Vector3i.Axis.AXIS_X,
	Y = Vector3i.Axis.AXIS_Y,
	Z = Vector3i.Axis.AXIS_Z,
}

enum Axis2 {
	X = Vector2i.Axis.AXIS_X,
	Y = Vector2i.Axis.AXIS_Y,
}
