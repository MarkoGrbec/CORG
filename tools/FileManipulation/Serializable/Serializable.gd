class_name Serializable extends Node
#region serialize
static  func serialize(array:Array):
	var ret_data = []
	for item in array:
		## check if we haven't put in null
		if item != null:
			var data = item.serialize()
			for it in data:
				ret_data.push_back(it)
	return ret_data
static func deserialize(custom_class, array:Array, turn_around: bool = false):
	var ret_array = []
	while len(array) > 0:
		var default_class = custom_class.copy()
		array = default_class.deserialize(array)
		if turn_around:
			ret_array.push_front(default_class)
		else:
			ret_array.push_back(default_class)
	return ret_array

## custom class with id
static func serialize_ids(array:Array):
	var ret_data = []
	for item in array:
		ret_data.push_back(item.id)
	return ret_data
#endregion serialize
##region serialize
#func serialize():
	#var data = []
	#data.push_back(id)
	#data.push_back(id_father)
	#data.push_back(id_client)
	#data.push_back(body)
	#data.push_back(comment_of_comment)
	#return data
	#
#func deserialize(data:Array):
	#comment_of_comment = data.pop_back()
	#body = data.pop_back()
	#id_client = data.pop_back()
	#id_father = data.pop_back()
	#id = data.pop_back()
	#return data
##endregion serialize
