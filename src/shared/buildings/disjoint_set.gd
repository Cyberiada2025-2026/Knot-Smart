class_name DisjointSet
extends RefCounted

var _arr: Array = []

func _init(size: int =  0) -> void:
	for i in size:
		_arr.push_back(i)


func union(id_a: int, id_b: int) -> void:
	var result = is_in_same_set(id_a, id_b)
	if not result[0]:
		_arr[result[2]] = result[1]


func is_in_same_set(id_a: int, id_b: int) -> Array:
	var x = find(id_a)
	var y = find(id_b)

	return [x == y, x, y]


func find(id: int) -> int:
	if _arr[id] == id:
		return id
	return find(_arr[id])
