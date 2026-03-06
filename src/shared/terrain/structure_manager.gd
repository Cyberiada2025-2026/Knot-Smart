@tool
extends MultiMeshInstance3D
class_name StructureManager

@export var structure_mesh: Mesh:
	set(val):
		structure_mesh = val
		request_parent_update()

func request_parent_update():
	if get_parent() and get_parent().has_method("update_mesh"):
			get_parent().update_mesh()

func place_object_bulk(transforms: Array[Transform3D],structure: Mesh):
	if not structure or transforms.is_empty():
		multimesh = null
		return

	var y_offset = structure_mesh.get_aabb().size.y / 2.0
	transforms.map(func(element): return element.origin.y + y_offset)
	
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = structure_mesh
	mm.instance_count = transforms.size()
	
	var counter = 0
	for st in transforms:
		mm.set_instance_transform(counter, st)
		counter += 1
		
	multimesh = mm
