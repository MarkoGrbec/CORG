class_name Macs extends ISavable

func copy():
	return Macs.new()

#var _listMac = []
static func get_index_from_string(mac):# -> Macs
	var m = Mac.get_or_create(mac)
	var macs:Macs = null
	if m.id_macs:
		macs = g_man.SavableMacs.get_index_data(m.id_macs)
	if macs == null:
		macs = Macs.new()
		g_man.SavableMacs.set_data(macs)
		m.id_macs = macs.id
		#if macs._listMac.has(m.id):
			#push_error("should never happen")
		#macs._listMac.push_back(m.id)
		m.save_id_macs(macs.id)
	return macs;
static func get_index_data(index:int):# -> Macs
	return g_man.SavableMacs.get_index_data(index)

## set all macs in to this mac
func set_data(mac: Array):
	for item in mac:
		var m = Mac.get_or_create(item)
		m.save_id_macs(id)
		#if not _listMac.has(m.id):
			#_listMac.push_back(m.id)
#region Savable
func fully_save():
	pass
func partly_save():
	pass
func fully_load():
	pass
func partly_load():
	pass
#endregion
