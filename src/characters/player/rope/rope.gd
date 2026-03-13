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
	vfx.rotate_x(-PI / 2)
	rope.add_child(vfx)


func init_rope_collider():
	var direction = pos[1] - pos[0]

	collision_shape = CapsuleShape3D.new()
	collision_shape.radius = params.rope_collision_radius

	collision_shape.height = direction.length()
	var collider = CollisionShape3D.new()
	collider.shape = collision_shape
	collider.rotate_x(-PI / 2)
	rope.add_child(collider)


func _on_area_entered(body: Node3D):
	for n in self.node:
		if body.get_instance_id() == n.get_instance_id():
			return
	finish()


func finish():
	vfx.end()
	apply_forces()
	queue_free()


func fuse():
	if node[0] is RigidBody3D and node[1] is RigidBody3D:
		var final_pos = (end[0].position + end[1].position) / 2

		for i in range(2):
			var diff = end[i].position - node[i].position
			node[i].position = final_pos + diff
		
		var combined = RigidBody3D.new()
		combined.position = final_pos
		get_node("../../../").add_child(combined)
		for child in node[0].get_children():
			child.reparent(combined)
		for child in node[1].get_children():
			child.reparent(combined)

		for n in node:
			n.queue_free()

		finish()

func update_rope():
	var direction = end[1].position - end[0].position
	var length = direction.length()
	vfx.set_length(length)
	collision_shape.height = length
	rope.look_at_from_position(end[0].position + direction / 2, end[0].position)


func _ready() -> void:
	end[0].pin(node[0], end[1])
	end[1].pin(node[1], end[0])

	rope = Area3D.new()
	init_rope_mesh()
	init_rope_collider()
	var direction = pos[1] - pos[0]
	rope.look_at_from_position(pos[0] + direction / 2, pos[0])
	rope.body_entered.connect(_on_area_entered)
	add_child(rope)


func apply_forces() -> void:
	for i in range(2):
		end[i].strategy.release_force(end[i], node[i])


func _physics_process(_delta: float) -> void:
	if end[0].position.distance_squared_to(end[1].position) > pow(params.max_rope_length, 2):
		finish()

	if (
		end[0].get_strategy_type() == RopeEnd.StrategyType.STATIC
		and end[1].get_strategy_type() == RopeEnd.StrategyType.STATIC
	):
		finish()

	update_rope()
