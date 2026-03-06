class_name Rope
extends Node3D

var node1
var node2

const MIN_LENGTH = 1.0
const MAX_LENGTH = 32.0
const COLLISION_RADIUS = 0.01
const COLLISION_BUFFER = 1.0

@export var spring_constant = 15.0
@export var damping = 0.5

var rope_vfx = preload("uid://djqe8wkjmmn8n")

var inner1: InnerNode
var inner2: InnerNode
var vfx: RopeVFX
var rope: Area3D
var collision_shape: CapsuleShape3D

var pt1: Vector3
var pt2: Vector3

func _init(p1: Vector3, obj1: Node3D, p2: Vector3, obj2: Node3D) -> void:
	pt1 = p1
	pt2 = p2
	node1 = obj1
	node2 = obj2

	var is_frozen_1 = node1 is not RigidBody3D and node1 is not CharacterBody3D
	inner1 = InnerNode.new(self, is_frozen_1, pt1)
	add_child(inner1)

	var is_frozen_2 = node2 is not RigidBody3D and node2 is not CharacterBody3D
	inner2 = InnerNode.new(self, is_frozen_2, pt2)
	add_child(inner2)

func init_rope_mesh():
	vfx = rope_vfx.instantiate()
	vfx.start(MIN_LENGTH)
	vfx.rotate_x(-PI/2)
	rope.add_child(vfx)

func init_rope_collider():
	var direction = pt2 - pt1
	
	collision_shape = CapsuleShape3D.new()
	collision_shape.radius = COLLISION_RADIUS

	if COLLISION_BUFFER*COLLISION_BUFFER < direction.length_squared():
		collision_shape.height = direction.length() - COLLISION_BUFFER
	var collider = CollisionShape3D.new()
	collider.shape = collision_shape
	collider.rotate_x(-PI/2)
	rope.add_child(collider)

func _on_area_entered(_node):
	finish()

func finish():
	vfx.end()
	apply_forces()
	queue_free()

func update_rope():
	var direction = inner2.position - inner1.position
	var length = direction.length()
	vfx.set_length(length)
	if COLLISION_BUFFER < length:
		collision_shape.height = length - COLLISION_BUFFER
	rope.look_at_from_position(inner1.position + direction/2, inner1.position)

func _ready() -> void:
	inner1.bind(node1)
	inner2.bind(node2)
	
	rope = Area3D.new()
	init_rope_mesh()
	init_rope_collider()
	var direction = pt2 - pt1
	rope.look_at_from_position(pt1 + direction/2, pt1)
	rope.body_entered.connect(_on_area_entered)
	add_child(rope)

func apply_forces() -> void:
	if node1 is RigidBody3D:
		var accel = inner1.get_hooke_accel()
		node1.apply_impulse(-accel)

	if node2 is RigidBody3D:
		var accel = inner2.get_hooke_accel()
		node2.apply_impulse(-accel)

	if node1 is CharacterBody3D:
		var direction = node2.position - node1.position
		node1.velocity += 2 * direction

	if node2 is CharacterBody3D:
		var direction = node1.position - node2.position
		node2.velocity += 2 * direction

func _physics_process(_delta: float) -> void:
	var difference = inner2.position - inner1.position

	if difference.length_squared() > MAX_LENGTH:
		finish()
	
	var direction = difference.normalized()
	
	if node1 is RigidBody3D and node2 is RigidBody3D:
		var midpoint = (inner1.position + inner2.position)/2
		inner1.equilibrium = midpoint - direction * 0.5 * MIN_LENGTH
		inner2.equilibrium = midpoint + direction * 0.5 * MIN_LENGTH
	elif node1 is not RigidBody3D and node2 is RigidBody3D:
		inner2.equilibrium = inner1.position + direction * MIN_LENGTH
	elif node2 is not RigidBody3D and node1 is RigidBody3D:
		inner1.equilibrium = inner2.position - direction * MIN_LENGTH
	elif node1 is not RigidBody3D and node2 is CharacterBody3D:
		inner2.equilibrium = inner1.position
	elif node2 is not RigidBody3D and node1 is CharacterBody3D:
		inner1.equilibrium = inner2.position
	else:
		queue_free()
	
	update_rope()

class InnerNode extends RigidBody3D:
	var prev_pos: Vector3
	var equilibrium: Vector3
	var rope: Rope

	func _init(rope, is_frozen, pos) -> void:
		self.freeze = is_frozen
		self.rope = rope
		self.position = pos
		self.prev_pos = pos

	func bind(obj) -> void:
		var joint = PinJoint3D.new()
		joint.node_a = get_path()
		joint.node_b = obj.get_path()
		add_child(joint)

	func integrate_accel(k, b) -> Vector3:
		var v = linear_velocity
		var dx = position - equilibrium
		var spring_accel = (-k*dx - b*v) / mass

		return spring_accel

	func get_total_accel() -> Vector3:
		return integrate_accel(rope.spring_constant, rope.damping)
	
	func get_hooke_accel() -> Vector3:
		return integrate_accel(rope.spring_constant, 0)

	func _physics_process(_delta: float) -> void:
		apply_force(mass * get_total_accel())
