class_name ArrayManipulation extends Node

static func unique_array(array:Array):
	var unique = []
	for item in array:
		if not unique.has(item):
			unique.push_back(item)
	return unique

static func create_multi_dimensional_array(dimensions : Array[int], default_value) -> Array:
	if len(dimensions) == 0:
		return []
		
	var temp : Array[int]
	temp.append_array(dimensions)
	
	var result := []
	var front := temp.pop_front() as int
	result.resize(front)
	for i in len(result):
		result[i] = default_value
	
	if len(temp) == 0:
		return result

	for i in front:
		result[i] = create_multi_dimensional_array(temp, default_value)
		
	return result
