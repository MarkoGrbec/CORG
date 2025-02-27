class_name Statics extends ISavable

func copy():					# copy the class which is used by savable when new needs to be created
	return Statics.new()
func partly_save():			# only part save
	pass
func fully_save():				# full save
	pass
func partly_load():			# load only critical data
	pass
func fully_load():				# fully load
	load_last_in_chain_user_level()
	load_stat_total_persons_on_corg_count()
	load_count_per_container_corg_accounts()

func save_last_in_chain_user_level():
	DataBase.insert(_server, g_man.dbms, _path, "last_in_chain_user_level", id, g_man.last_in_chain_user_level)

func save_stat_total_persons_on_corg_count():
	DataBase.insert(_server, g_man.dbms, _path, "stat_total_persons_on_corg_count", id, g_man.stat_total_persons_on_corg_count)

func save_count_per_container_corg_accounts():
	DataBase.insert(_server, g_man.dbms, _path, "count_per_container_corg_accounts", id, g_man.count_per_container_corg_accounts)

func load_last_in_chain_user_level():
	g_man.last_in_chain_user_level = DataBase.select(_server, g_man.dbms, _path, "last_in_chain_user_level", id)
	if not g_man.last_in_chain_user_level:
		g_man.last_in_chain_user_level = 4

func load_stat_total_persons_on_corg_count():
	g_man.stat_total_persons_on_corg_count = DataBase.select(_server, g_man.dbms, _path, "stat_total_persons_on_corg_count", id)
	if not g_man.stat_total_persons_on_corg_count:
		g_man.stat_total_persons_on_corg_count = 1

func load_count_per_container_corg_accounts():
	g_man.count_per_container_corg_accounts = DataBase.select(_server, g_man.dbms, _path, "count_per_container_corg_accounts", id)
	if not g_man.count_per_container_corg_accounts:
		g_man.count_per_container_corg_accounts = 2
