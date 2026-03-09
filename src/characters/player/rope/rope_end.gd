class_name RopeEnd
extends RigidBody3D

enum StrategyType { STATIC, DYNAMIC, KINEMATIC }

var prev_pos: Vector3
var params: RopeParams
var other: RopeEnd
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
	var spring_accel = -k * dx - b * v

	return spring_accel


func get_total_accel() -> Vector3:
	return integrate_accel(params.spring_constant, params.damping)


func get_hooke_accel() -> Vector3:
	return integrate_accel(params.spring_constant, 0)


func _physics_process(_delta: float) -> void:
	apply_force(params.mass * get_total_accel())
