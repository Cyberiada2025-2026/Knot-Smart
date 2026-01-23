class_name DisjointSet
extends RefCounted

var _arr: Array = []


static func create(size: int) -> DisjointSet:
	var arr = []
	for i in size:
		arr.push_back(i)

	var disjoint_set = DisjointSet.new()
	disjoint_set._arr = arr

	return disjoint_set


func union(id_a: int, id_b: int) -> void:
	var x = find(id_a)
	var y = find(id_b)

	if x == y:
		return

	_arr[y] = x


func is_in_same_set(id_a: int, id_b: int) -> bool:
	var x = find(id_a)
	var y = find(id_b)

	return x == y


func find(id: int) -> int:
	if _arr[id] == id:
		return id
	return find(_arr[id])
