class_name VVertices extends Node

var vertices: Array[Vector3]
var find: Dictionary[Vector3, int]
var index = 0

var n1 = Vector3.ZERO
var n2 = Vector3.ZERO
var n3 = Vector3.ZERO

func get_index_vertex(vertex: Vector3):
	if find.has(vertex):
		return find[vertex]
	vertices.push_back(vertex)
	find[vertex] = index
	index =  index + 1
	return index

func to_array():
	return vertices
