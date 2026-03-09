class_name Rope
extends Node3D

var params: RopeParams

var rope_vfx = preload("uid://djqe8wkjmmn8n")

var vfx: RopeVFX
var rope: Area3D
var collision_shape: CapsuleShape3D

var node: Array[Node]
var inner: Array[InnerNode]
var pos: Array[Vector3]

func _init(rope_params: RopeParams, nodes: Array[Node], positions: Array[Vector3]) -> void:
	self.params = rope_params
	self.node = nodes
	self.inner = []
	self.pos = positions

	for i in range(2):
		var strategy
		match node[i].get_class():
			"RigidBody3D":
				strategy = BasicDynamicStrategy.new(params.min_rope_length)
			"CharacterBody3D":
				strategy = BasicKinematicStrategy.new()
			_:
				strategy = BasicStaticStrategy.new()
		inner.append(InnerNode.new(self.params, strategy, pos[i]))

		add_child(inner[i])

func init_rope_mesh():
	vfx = rope_vfx.instantiate()
	vfx.start(params.min_rope_length)
	vfx.rotate_x(-PI/2)
	rope.add_child(vfx)

func init_rope_collider():
	var direction = pos[1] - pos[0]
	
	collision_shape = CapsuleShape3D.new()
	collision_shape.radius = params.rope_collision_radius

	if pow(params.rope_collision_buffer, 2) < direction.length_squared():
		collision_shape.height = direction.length() - params.rope_collision_buffer
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
	var direction = inner[1].position - inner[0].position
	var length = direction.length()
	vfx.set_length(length)
	if params.rope_collision_buffer < length:
		collision_shape.height = length - params.rope_collision_buffer
	rope.look_at_from_position(inner[0].position + direction/2, inner[0].position)

func _ready() -> void:
	inner[0].bind(node[0], inner[1])
	inner[1].bind(node[1], inner[0])

	rope = Area3D.new()
	init_rope_mesh()
	init_rope_collider()
	var direction = pos[1] - pos[0]
	rope.look_at_from_position(pos[0] + direction/2, pos[0])
	rope.body_entered.connect(_on_area_entered)
	add_child(rope)

func apply_forces() -> void:
	for i in range(2):
		inner[i].strategy.release_force(inner[i], node[i])

func _physics_process(_delta: float) -> void:
	var difference = inner[1].position - inner[0].position

	if difference.length_squared() > params.max_rope_length:
		finish()

	if inner[0].strategy.get_strategy_type() == StrategyType.STATIC \
		and inner[1].strategy.get_strategy_type() == StrategyType.STATIC:
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
	var params: RopeParams
	var other: InnerNode
	var strategy: Node

	func _init(rope_params, equilibrium_strategy, pos) -> void:
		self.strategy = equilibrium_strategy
		self.freeze = (get_strategy_type() == StrategyType.STATIC)
		self.params = rope_params
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
		return integrate_accel(params.spring_constant, params.damping)
	
	func get_hooke_accel() -> Vector3:
		return integrate_accel(params.spring_constant, 0)

	func _physics_process(_delta: float) -> void:
		apply_force(params.mass * get_total_accel())
