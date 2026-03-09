class_name Rope
extends Node3D

var node1
var node2

const MIN_LENGTH = 1.0
const MAX_LENGTH = 32.0
const COLLISION_RADIUS = 0.01
const COLLISION_BUFFER = 1.0

@export var spring_constant = 5.0
@export var damping = 0.5
@export var mass = 1.0

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

	var strategy
	match node1.get_class():
		"RigidBody3D":
			strategy = BasicDynamicStrategy.new(MIN_LENGTH)
		"CharacterBody3D":
			strategy = BasicKinematicStrategy.new()
		_:
			strategy = BasicStaticStrategy.new()
	inner1 = InnerNode.new(self, strategy, pt1)

	add_child(inner1)

	var strategy2
	match node2.get_class():
		"RigidBody3D":
			strategy2 = BasicDynamicStrategy.new(MIN_LENGTH)
		"CharacterBody3D":
			strategy2 = BasicKinematicStrategy.new()
		_:
			strategy2 = BasicStaticStrategy.new()
	
	inner2 = InnerNode.new(self, strategy2, pt2)
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
	inner1.bind(node1, inner2)
	inner2.bind(node2, inner1)

	rope = Area3D.new()
	init_rope_mesh()
	init_rope_collider()
	var direction = pt2 - pt1
	rope.look_at_from_position(pt1 + direction/2, pt1)
	rope.body_entered.connect(_on_area_entered)
	add_child(rope)

func apply_forces() -> void:
	inner1.strategy.release_force(inner1, node1)
	inner2.strategy.release_force(inner2, node2)

func _physics_process(_delta: float) -> void:
	var difference = inner2.position - inner1.position

	if difference.length_squared() > MAX_LENGTH:
		finish()

	if inner1.strategy.get_strategy_type() == StrategyType.STATIC \
		and inner2.strategy.get_strategy_type() == StrategyType.STATIC:
		finish()

	update_rope()

enum StrategyType {
	STATIC,
	DYNAMIC,
	KINEMATIC
}

class BasicStaticStrategy extends Node:
	func get_strategy_type() -> StrategyType:
		return StrategyType.STATIC

	func get_equilibrium(current: InnerNode, _other: InnerNode):
		return current.position

	func release_force(_inner: InnerNode, _node: Node):
		return

class BasicDynamicStrategy extends Node:
	var length

	func _init(min_length):
		self.length = min_length

	func get_strategy_type() -> StrategyType:
		return StrategyType.DYNAMIC
	
	func get_equilibrium(current: InnerNode, other: InnerNode) -> Vector3:
		var direction = current.position - other.position
		var equilibrium
		match other.get_strategy_type():
			StrategyType.STATIC:
				equilibrium = other.position - direction * length
			StrategyType.DYNAMIC:
				var midpoint = (current.position + other.position)/2
				equilibrium = midpoint - direction * 0.5 * length
			StrategyType.KINEMATIC:
				equilibrium = other.position
				
		return equilibrium

	func release_force(inner: InnerNode, node: Node):
		var accel = inner.get_hooke_accel()
		node.apply_impulse(-accel)

class BasicKinematicStrategy extends Node:
	func get_strategy_type() -> StrategyType:
		return StrategyType.KINEMATIC

	func get_equilibrium(current: InnerNode, _other: InnerNode):
		return current.position

	func release_force(inner: InnerNode, node: Node):
		var direction = inner.other.position - inner.position
		node.velocity += 2 * direction

class InnerNode extends RigidBody3D:
	var prev_pos: Vector3
	var rope: Rope
	var other: InnerNode
	var strategy: Node

	func _init(rope_ref, equilibrium_strategy, pos) -> void:
		self.strategy = equilibrium_strategy
		self.freeze = (get_strategy_type() == StrategyType.STATIC)
		self.rope = rope_ref
		self.position = pos
		self.prev_pos = pos

	func get_strategy_type():
		return self.strategy.get_strategy_type()

	func bind(obj, other_node) -> void:
		self.other = other_node
		var joint = PinJoint3D.new()
		joint.node_a = get_path()
		joint.node_b = obj.get_path()
		add_child(joint)

	func integrate_accel(k, b) -> Vector3:
		var v = linear_velocity
		var equilibrium = strategy.get_equilibrium(self, other)
		var dx = position - equilibrium
		# Direct application of the damped oscillator formula
		var spring_accel = -k*dx - b*v

		return spring_accel

	func get_total_accel() -> Vector3:
		return integrate_accel(rope.spring_constant, rope.damping)
	
	func get_hooke_accel() -> Vector3:
		return integrate_accel(rope.spring_constant, 0)

	func _physics_process(_delta: float) -> void:
		apply_force(rope.mass * get_total_accel())
