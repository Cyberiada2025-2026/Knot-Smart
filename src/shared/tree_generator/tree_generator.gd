class_name TreeGenerator
extends Node

var tree_skeleton: TreeSkeleton
var tree_mesh_generator: TreeMeshGenerator
@export var trees: Array[TreeParameters]


# wowee this code is so shitty change it asap
func _ready() -> void:	
	# for test purpose
	#for i in range(15):
		#for j in range(25):
			#if randf() < 0.6:
				#var tree = TreeMesh.new()
				#tree.type = randi()%2
				#tree.pos = Vector3(i*5.0+randf_range(-2.0,2.5),0.0,j*6.0+randf_range(-2.0,2.0))
				#trees.push_back(tree)
				
	for params in trees:
		var tree = TreeMesh.new()
		tree.params = params
		add_child(tree)
		tree.generate_tree()
