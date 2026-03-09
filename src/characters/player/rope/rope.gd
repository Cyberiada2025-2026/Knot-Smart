class_name Rope
extends Node3D

var params: RopeParams

var rope_vfx = preload("uid://djqe8wkjmmn8n")

var vfx: RopeVFX
var rope: Area3D
var collision_shape: CapsuleShape3D

var node: Array[Node]
var end: Array[RopeEnd]
var pos: Array[Vector3]

func _init(rope_params: RopeParams, nodes: Array[Node], positions: Array[Vector3]) -> void:
	self.params = rope_params
	self.node = nodes
	self.end = []
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
		end.append(RopeEnd.new(self.params, strategy, pos[i]))

		add_child(end[i])

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
	var direction = end[1].position - end[0].position
	var length = direction.length()
	vfx.set_length(length)
	if params.rope_collision_buffer < length:
		collision_shape.height = length - params.rope_collision_buffer
	rope.look_at_from_position(end[0].position + direction/2, end[0].position)

func _ready() -> void:
	end[0].bind(node[0], end[1])
	end[1].bind(node[1], end[0])

	rope = Area3D.new()
	init_rope_mesh()
	init_rope_collider()
	var direction = pos[1] - pos[0]
	rope.look_at_from_position(pos[0] + direction/2, pos[0])
	rope.body_entered.connect(_on_area_entered)
	add_child(rope)

func apply_forces() -> void:
	for i in range(2):
		end[i].strategy.release_force(end[i], node[i])

func _physics_process(_delta: float) -> void:
	var difference = end[1].position - end[0].position

	if difference.length_squared() > params.max_rope_length:
		finish()

	if end[0].strategy.get_strategy_type() == StrategyType.STATIC \
		and end[1].strategy.get_strategy_type() == StrategyType.STATIC:
		finish()

	update_rope()

class BasicStaticStrategy extends Node:
	func get_strategy_type() -> StrategyType:
		return StrategyType.STATIC

	func get_equilibrium(current: RopeEnd, _other: RopeEnd):
		return current.position

	func release_force(_end: RopeEnd, _node: Node):
		return

class BasicDynamicStrategy extends Node:
	var length

	func _init(min_length):
		self.length = min_length

	func get_strategy_type() -> StrategyType:
		return StrategyType.DYNAMIC
	
	func get_equilibrium(current: RopeEnd, other: RopeEnd) -> Vector3:
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

	func release_force(end: RopeEnd, node: Node):
		var accel = end.get_hooke_accel()
		node.apply_impulse(-accel)

class BasicKinematicStrategy extends Node:
	func get_strategy_type() -> StrategyType:
		return StrategyType.KINEMATIC

	func get_equilibrium(current: RopeEnd, _other: RopeEnd):
		return current.position

	func release_force(end: RopeEnd, node: Node):
		var direction = end.other.position - end.position
		node.velocity += 2 * direction
