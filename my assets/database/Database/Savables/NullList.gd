class_name NullList extends Node

#region NullList
func _init():
	_container = []
	_null_container = []
	#_count = 1
	set_data(null)

var _container = []
var _null_container
#var _count
func set_index_data(index, data):
	if _container.size() < index + 1:
		#we store nulls till the end of size
		var _count = _container.size()
		for i in range(_count, index):
			if not _null_container.has(i):
				_null_container.push_back(i)
		_count = index + 1
		#it needs count
		_container.resize(_count)
	if _container[index] == null:
		#remove from _null_container
		for i in range(0, _null_container.size(), 1):
			if _null_container[i] == index:
				_null_container.remove_at(i)
				break
	_container[index] = data

func set_data(data):
	if _null_container.size() > 0:
		#use push_front() for little bit performance issue but it'll use first ones and not last ones first
		var index = _null_container.pop_back()
		if _container.size() <= index:
			#_count = index + 1
			_container.resize(index + 1)
		_container[index] = data
		return index
	else:
		#just that it doesn't make full array nullable
		#if _container.size() == 0:
			#if data == null:
				#_container.push_back(0) # might lead to bug this workaround
				#return -1
		_container.push_back(data)
		#_count = _container.size()
		return _container.size() - 1

func get_index_data(index):
	if _container.size() < index + 1:
		return null
	return _container[index]

## frees data if possible
func remove_at(index):
	if _container.size() > index:
		_null_container.push_back(index)
		_queue_free_index_if_not_null(index)
	else:
		_null_container.push_back(index)
		if _container.size() <= index:
			_container.resize(index + 1)
		_queue_free_index_if_not_null(index)

func _queue_free_index_if_not_null(index: int):
	_queue_free_if_not_null(_container[index])
	_container[index] = null

func _queue_free_if_not_null(variant: Variant):
	if variant and variant.has_method("queue_free"):
		variant.queue_free()

func add_null(index):
	if not _null_container.has(index):
		_null_container.push_back(index)

func get_null():
	if _null_container.size() > 0:
		# use push_front() for little bit performance issue but it'll use first ones and not last ones first
		return _null_container.pop_back()

func exists(index):
	if _container.size() > index:
		if _container[index] == null:
			return false
	else:
		return false
	return true
	
func clear():
	for item in _container:
		_queue_free_if_not_null(item)
	for item in _null_container:
		_queue_free_if_not_null(item)
	_container.clear()
	_null_container.clear()
	#_count = 0
	
func count():
	return _container.size() -1
#endregion NullList
