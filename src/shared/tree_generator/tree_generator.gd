class_name TreeGenerator
extends Node

var tree_skeleton: TreeSkeleton
var tree_mesh_generator: TreeMeshGenerator
@export var trees: Array[TreeParameters]


# wowee this code is so shitty change it asap
func _ready() -> void:	
	# for test purpose
		
	for params in trees:
		for i in range(10):
			for j in range(20):
				if randf() < 0.5:
					var tree = TreeMesh.new()
					tree.params = params
					add_child(tree)
					tree.generate_tree()
					tree.global_position = Vector3(i*5.0+randf_range(-2.0,2.5),0.0,j*6.0+randf_range(-2.0,2.0))
