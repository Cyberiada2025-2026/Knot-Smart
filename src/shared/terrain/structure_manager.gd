@tool
extends MultiMeshInstance3D

@export var structure_mesh: Mesh:
	set(val):
		structure_mesh = val
		request_parent_update()

@export_range(0.0, 1.0) var density := 0.2:
	set(val):
		density = val
		request_parent_update()

@export var seed_offset := 0: 
	set(val):
		seed_offset = val
		request_parent_update()

func request_parent_update():
	if get_parent() and get_parent().has_method("update_mesh"):
			get_parent().update_mesh()

func update_structures(available_transforms: Array[Vector3]):
	if not structure_mesh or available_transforms.is_empty():
		multimesh = null
		return

	var y_offset = structure_mesh.get_aabb().size.y / 2.0
	var final_transforms: Array[Transform3D] = []
	
	for pos in available_transforms:
		var t = Transform3D()
		t.origin = pos
		
		var noise_val = (int(pos.x) * 36363636) ^ (int(pos.z) * 44444444) ^ seed_offset
		var rand_val = (noise_val % 1000) / 1000.0
		
		rand_val = abs(rand_val)
		
		if rand_val < density:
			var new_t = t
			new_t.origin.y += y_offset
			
			final_transforms.append(new_t)
			
	if final_transforms.is_empty():
		multimesh = null
		return

	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = structure_mesh
	mm.instance_count = final_transforms.size()
	
	for i in range(final_transforms.size()):
		mm.set_instance_transform(i, final_transforms[i])
		
	multimesh = mm
