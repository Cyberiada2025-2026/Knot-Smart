class_name Rope
extends Node3D

@export var node1: PhysicsBody3D
@export var node2: PhysicsBody3D

var inner1: InnerNode
var inner2: InnerNode

var pt1: Vector3
var pt2: Vector3

func _init(p1: Vector3, obj1: Node3D, p2: Vector3, obj2: Node3D) -> void:
	node1 = obj1
	node2 = obj2

	inner1 = InnerNode.new()
	add_child(inner1)

	inner2 = InnerNode.new()
	add_child(inner2)

func _ready() -> void:
	inner1.bind(node1)
	if node1 is not RigidBody3D:
		inner1.is_static = true
	
	inner2.bind(node2)
	if node2 is not RigidBody3D:
		inner2.is_static = true

class InnerNode extends RigidBody3D:
	func bind(obj: PhysicsBody3D) -> void:
		var joint = PinJoint3D.new()
		joint.node_a = get_path()
		joint.node_b = obj.get_path()
		add_child(joint)
