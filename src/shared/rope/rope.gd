class_name Rope
extends Node3D

@export var node1: PhysicsBody3D
@export var node2: PhysicsBody3D

const LENGTH = 1.0
const MAX_LENGTH = 32.0

@export var spring_constant = 15.0
@export var damping = 0.5

var inner1: InnerNode
var inner2: InnerNode

var pt1: Vector3
var pt2: Vector3

func _init(p1: Vector3, obj1: Node3D, p2: Vector3, obj2: Node3D) -> void:
	pt1 = p1
	pt2 = p2
	node1 = obj1
	node2 = obj2

	inner1 = InnerNode.new(pt1)
	add_child(inner1)

	inner2 = InnerNode.new(pt2)
	add_child(inner2)

func finish():
	queue_free()

func _ready() -> void:
	inner1.bind(node1)
	if node1 is not RigidBody3D:
		inner1.is_static = true
	
	inner2.bind(node2)
	if node2 is not RigidBody3D:
		inner2.is_static = true

func _physics_process(_delta: float) -> void:
	inner1.set_spring_params(spring_constant, damping)
	inner2.set_spring_params(spring_constant, damping)

	var difference = inner2.position - inner1.position

	if difference.length_squared() > MAX_LENGTH:
		finish()
	
	var direction = difference.normalized()
	
	if node1 is RigidBody3D and node2 is RigidBody3D:
		var midpoint = (inner1.position + inner2.position)/2
		inner1.equilibrium = midpoint - direction * 0.5 * LENGTH
		inner2.equilibrium = midpoint + direction * 0.5 * LENGTH
	elif node1 is not RigidBody3D and node2 is RigidBody3D:
		inner1.equilibrium = inner1.position
		inner2.equilibrium = inner1.position + direction * LENGTH
		pass
	elif node2 is not RigidBody3D and node1 is RigidBody3D:
		inner2.equilibrium = inner2.position
		inner1.equilibrium = inner2.position - direction * LENGTH
	elif node1 is StaticBody3D and node2 is CharacterBody3D:
		inner1.equilibrium = inner1.position
		inner2.equilibrium = inner1.position
	elif node2 is StaticBody3D and node1 is CharacterBody3D:
		inner2.equilibrium = inner2.position
		inner1.equilibrium = inner2.position
	else:
		queue_free()

class InnerNode extends RigidBody3D:
	var prev_pos: Vector3
	var equilibrium: Vector3
	var is_static = false

	var k = 5.0
	var b = 0.5

	func set_spring_params(k, b) -> void:
		self.k = k
		self.b = b

	func _init(pos) -> void:
		self.position = pos
		self.prev_pos = pos

	func bind(obj: PhysicsBody3D) -> void:
		var joint = PinJoint3D.new()
		joint.node_a = get_path()
		joint.node_b = obj.get_path()
		add_child(joint)

	func get_accel() -> Vector3:
		if is_static:
			return Vector3.ZERO

		var v = linear_velocity
		var dx = position - equilibrium
		var spring_accel = (-k*dx - b*v) / mass

		return spring_accel

	func _physics_process(_delta: float) -> void:
		apply_force(mass * get_accel())
