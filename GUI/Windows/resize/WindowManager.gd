class_name WindowManager extends Control

var start : Vector2
var initial_position : Vector2
var is_moving : bool
var is_resizing : bool
var resize_x : bool
var resize_y : bool
var initialSize : Vector2
var focus = false
var id_window: int

static var id_windows = {}

@export var GrabThreshold := 55
@export var ResizeThreshold := 20
@export var border := 20
@export var default_window_rect: Rect2 = Rect2(256, 100, 784, 256)
@export var minimum_window_size: Vector2 = Vector2(225, 225)

func _ready() -> void:
	g_man.array_mouse_inside_windows.push_back(mouse_inside)

func focus_enter():
	focus = true

func focus_exit():
	if not is_moving && not is_resizing:
		focus = false

func mouse_inside(pos: Vector2):
	if is_visible_in_tree():
		var rect: Rect2 = get_global_rect()
		pos -= get_global_position()
		var left_right: bool = pos.x > 0 and pos.x < rect.size.x
		if pos.y < rect.size.y and pos.y > 0 and left_right:
			return true
	return false

func show_window(_show: bool = false):
	# close window if it's shown
	if is_visible_in_tree():
		if not _show:
			hide()
		return
	# show window
	last_sibling()
	show()

func close_window():
	hide()

func last_sibling():
	get_parent().move_child.call_deferred(self, get_parent().get_child_count())

func is_last_sibling():
	var parent = get_parent()  # Get the parent node
	var index = get_index()     # Get this node's index
	var total_children = parent.get_child_count()  # Get total children count
	return index == total_children - 1  # Check if it's the last sibling

func set_id_window(id:int, text:String):
	id_window = id
	if id_windows.has(id):
		g_man.mold_window.set_instructions_only([text, "window id:", id, "does not have unique id there for won't save it's position size correctly it conflicts with:", id_windows[id], get_stack()])
	else:
		id_windows[id] = text
		if not id == 14: # slider manager do not resize or move
			default_window_rect = DataBase.select(false, g_man.dbms, "windows", "rect", id_window, default_window_rect)
			set_position(default_window_rect.position)
			set_size(default_window_rect.size)
	reset_window_position()
		
# if it's accidenally out of borders I throw them back and resize
func reset_window_position():
	var pos = get_global_position()
	if pos.x < border:
		pos.x = border
	if pos.y < border:
		pos.y = border
	set_position(pos)
	var newWidith = clamp(get_size().x, minimum_window_size.x, g_man.global_canvas.get_global_canvas_rect().size.x - get_global_rect().position.x - border)
	var newHeight = clamp(get_size().y, minimum_window_size.y, g_man.global_canvas.get_global_canvas_rect().size.y - get_global_rect().position.y - border)
	set_size(Vector2(newWidith, newHeight))

func _input(event):
	if not event is InputEventMouse or not id_window:
		return
	#if focus and event is InputEventMouse:
		#local_exit_mouse_pos = event.position - get_global_position()
	if focus:
		if Input.is_action_just_pressed("LeftMouseButton"):
			last_sibling()
	# don't grab or resize if it's not last sibling like pressed on it
	elif not is_last_sibling():
		return
#region button down
	if Input.is_action_just_pressed("LeftMouseButton"):
		var rect = get_global_rect()
		var localMousePos = event.position - get_global_position()
		var left_right = localMousePos.x > 0 && localMousePos.x < rect.size.x
		var up_down = localMousePos.y > 0 && localMousePos.y < rect.size.y
	#region drag
		if localMousePos.y < GrabThreshold && localMousePos.y > -ResizeThreshold && left_right:
			reset_window_position()
			# set it as last sibling
			last_sibling()
			start = event.position
			initial_position = get_global_position()
			is_moving = true
	#endregion drag
	#region resize
		else:# get_parent().get_child_count() == get_index() + 1: # if last sibling
			if abs(localMousePos.x - rect.size.x) < ResizeThreshold && up_down:
				reset_window_position()
				start.x = event.position.x
				initialSize.x = get_size().x
				resize_x = true
				is_resizing = true
			
			if abs(localMousePos.y - rect.size.y) < ResizeThreshold && left_right:
				reset_window_position()
				start.y = event.position.y
				initialSize.y = get_size().y
				resize_y = true
				is_resizing = true
			
			if localMousePos.x < ResizeThreshold &&  localMousePos.x > -ResizeThreshold && up_down:
				reset_window_position()
				start.x = event.position.x
				initial_position.x = get_global_position().x
				initialSize.x = get_size().x
				is_resizing = true
				resize_x = true
			
			if localMousePos.y < ResizeThreshold &&  localMousePos.y > -ResizeThreshold && left_right:
				reset_window_position()
				start.y = event.position.y
				initial_position.y = get_global_position().y
				initialSize.y = get_size().y
				is_resizing = true
				resize_y = true
	#endregion resize
#endregion button down
#region button hold
	if Input.is_action_pressed("LeftMouseButton"):
		if is_moving:
			var position_x = clamp(initial_position.x + (event.position.x - start.x), border, g_man.global_canvas.get_global_canvas_rect().size.x - get_global_rect().size.x - border)
			var position_y = clamp(initial_position.y + (event.position.y - start.y), border, g_man.global_canvas.get_global_canvas_rect().size.y - get_global_rect().size.y - border)
			set_position(Vector2(position_x, position_y))
		if is_resizing:
			var newWidith = get_size().x
			var newHeight = get_size().y
			
			#right sizing
			if resize_x:
				newWidith = clamp(initialSize.x - (start.x - event.position.x), minimum_window_size.x, g_man.global_canvas.get_global_canvas_rect().size.x - get_global_rect().position.x - border)
			if resize_y:
				newHeight = clamp(initialSize.y - (start.y - event.position.y), minimum_window_size.y, g_man.global_canvas.get_global_canvas_rect().size.y - get_global_rect().position.y - border)
			
			#left sizing AGAIN
			if initial_position.x != 0:
				var right_offset = g_man.global_canvas.get_global_canvas_rect().size.x - initial_position.x - initialSize.x
				newWidith = initialSize.x + (initial_position.x - (clamp(event.position.x, border, g_man.global_canvas.get_global_canvas_rect().size.x - right_offset - minimum_window_size.x)))
				
				set_position(Vector2(clamp(initial_position.x - (newWidith - initialSize.x), border, g_man.global_canvas.get_global_canvas_rect().size.x - right_offset - minimum_window_size.x), get_position().y))
			
			## it gets here does by resizing on top ##TODO clamp
			#if initial_position.y != 0:
				#newHeight = initialSize.y + (start.y - event.position.y)
				#set_position(Vector2(get_position().x, initial_position.y - (newHeight - initialSize.y)))
			
			set_size(Vector2(newWidith, newHeight))
			
#endregion button hold
#region button released
	if Input.is_action_just_released("LeftMouseButton"):
		if is_moving or is_resizing or resize_x or resize_y:
			save_rect()
		is_moving = false
		initial_position = Vector2.ZERO
		start = Vector2.ZERO
		resize_x = false
		resize_y = false
		is_resizing = false
		
#endregion button released

func set_min_size(min_size:Vector2 = minimum_window_size):
	default_window_rect.size = min_size
	set_size(default_window_rect.size)

func save_rect():
	print("Save ", id_window, " : ", get_global_rect(), " :/: ", get_rect())
	DataBase.insert(false, g_man.dbms, "windows", "rect", id_window, get_rect())
