class_name ItemListColumns extends ItemList

var _rows_count: int = 0
var select_row_to_move_to: int
var column__sorted = {}

#region adding
func add_item_with_id(array_columns: Array,  meta_data) -> void:
	if not array_columns.size() == max_columns:
		printerr("array size does not equal to max column size")
		return
	_rows_count += 1
	for column in array_columns:
		if column is Array:
			var index = add_item(str(column[0]))
			if column[1]:
				var texture = SaveLoadPicture.load_image_from_raw_png(column[1])
				set_item_icon(index, texture)
			set_item_metadata(index, meta_data)
		else:
			var index = add_item(str(column))
			set_item_metadata(index, meta_data)
		
#endregion adding
#region moving
func move_to_row(index: int, to_row: int) -> void:
	var i = current_column(index)
	# first in row
	index -= i
	# if same row
	@warning_ignore("integer_division")
	if to_row == int(index / max_columns):
		return
	@warning_ignore("integer_division")
	if to_row < int(index / max_columns):
		# forward
		for ie in max_columns:
			_move_all_in_column(index, ie, to_row)
	else:
		# backward
		for ie in range(max_columns-1, -1, -1):
			_move_all_in_column(index, ie, to_row)

func _move_all_in_column(index: int, i: int, to_row: int) -> void:
	move_item(index + i, i + (max_columns * (to_row) )  )

func move_to_last_selected(index: int, selected: bool) -> void:
	if selected:
		select_row_to_move_to = current_row(index)
	else:
		move_to_row(index, select_row_to_move_to)
#endregion moving
#region get index
func current_column(index: int) -> int:
	return index % max_columns

func current_row(index: int) -> int:
	index = first_in_row(index)
	@warning_ignore("integer_division")
	return int(index / max_columns)

func first_in_row(index: int) -> int:
	var i = index % max_columns
	# first in row
	index -= i
	return index

func get_row_first_index(row: int):
	return row * max_columns
#endregion get index
#region sort
## which column to sort
## how many rows to not sort
## in which order
func sort_items_by_column(column: int, execlude_rows: int = 1, reverse: bool = false):
	var index: int = execlude_rows
	var text_item
	var text_item1
	if reverse:
		index = _rows_count
		while index > -1 + execlude_rows:
			text_item = _get_row_text(column, index)
			text_item1 = _get_row_text(column, index +1)
			if text_item and text_item1 and text_item < text_item1:
				move_to_row(index * max_columns, index + 1)
				index += 1
				continue
			index -= 1
	else:
		while index < _rows_count:
			text_item = _get_row_text(column, index)
			text_item1 = _get_row_text(column, index +1)
			if text_item and text_item1 and text_item > text_item1:
				move_to_row(index * max_columns, index + 1)
				index -= 1
				if index < execlude_rows:
					index = execlude_rows
				continue
			index += 1

func sort_first_row_column(index: int):
	if current_row(index) == 0:
		var _current_column = current_column(index)
		var reverse = column__sorted.get_or_add(_current_column, true)
		reverse = not reverse
		column__sorted[_current_column] = reverse
		print(reverse)
		sort_items_by_column(_current_column, 1, reverse)
#endregion sort
#region get data
func _get_row_text(column: int, row: int):
	if row <= _rows_count:
		return get_item_text(column + max_columns * row)

func get_first_in_row_metadata(row):
	var index = get_row_first_index(row)
	return get_item_metadata(index)

func get_metadata_row(_metadata):
	for row in _rows_count + 1:
		var metadata = get_first_in_row_metadata(row)
		if metadata == _metadata:
			return row
#endregion get data
#region remove row
func remove_all_rows(rows_to_start = 1):
	for i in _rows_count * max_columns:
		remove_item(max_columns * rows_to_start)
	_rows_count = rows_to_start -1
	if _rows_count < 0:
		_rows_count = 0

func remove_row(row):
	var index = get_row_first_index(row)
	for i in max_columns:
		remove_item(index)
#endregion remove row
