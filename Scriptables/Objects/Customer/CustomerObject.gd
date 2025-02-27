class_name CustomerObject extends Resource

@export var customer_name: String
@export var visual: Enums.Esprite = Enums.Esprite.megan_visual
@export var level__items_need: Array[ItemsNeedObject]
@export var level_time: Array[float]
func get_items_need(level):
	# get items need for current level
	if level__items_need.size() > level:
		return level__items_need[level].items_need
	# get items need at max level
	return level__items_need[level__items_need.size() - 1].items_need

## time when customer will apear again
func get_time(level):
	# get time for current level
	if level_time.size() > level:
		return level_time[level]
	# get time at max level
	return level_time[level_time.size() - 1]
