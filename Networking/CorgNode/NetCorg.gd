class_name NetCorg extends Node
@warning_ignore("unused_private_class_variable")
var _name
#region intro
func intro():
	if get_multiplayer_authority() != 1:
		push_error("is not server")
		return
	var node:NetworkNode = g_man.dict_id_unique__connected_node[multiplayer.get_remote_sender_id()]
	if not node.secure_connection:
		push_warning("connection failed it's not secure")
		g_man.local_server_network_node.target_instructions.rpc_id(node.id_net, ["your connection isn't secure"])
		return
	if not node.client.verified_corg > 2:
		return
	return node
#endregion intro
	#region fingerPrint
	#[ServerRpc]
	#public void CmdMakeVerifiedFingerPrint(long idMac, NetworkConnection caller = null){
		#try
		#{
			#if (!client.cameInWithOtherComputer)
			#{
				#var idRows = g_man.MultiSPer_UnwelcomedMac.Select(client.ID, idMac)
				#foreach (var idRow in idRows)
				#{
					#DataBase.Insert(true, NetMan.DbMs, DataBase.path.fingerPrintServPer_UnwelcomedMac, DataBase.fileName.approved, idRow, true, DataBase.Operating.equals)
				#}
#
				#g_man.MultiServPer_PermenantUnwelcomedMac.Delete(client.ID, idMac)
			#}
			#else
			#{
				#MakeHacker(idMac)
			#}
		#}
		#catch (Exception e){Debug.LogError(e) MoldWindowManager.sin.SetMoldWindowInstructionsOnly("Fatal error", $"{e}")}
	#}
	#[ServerRpc]
	#public void CmdMakeHacker(long idMac, NetworkConnection caller = null){
		#try
		#{
			#//need to verify if the person has not been broken in to so that anyone can't make everyone a hacker
			#var alreadyUnwelcome = g_man.MultiSPer_UnwelcomedMac.Select(client.ID, idMac)
			#if (alreadyUnwelcome.Length > 0)
			#{
				#MakeHacker(idMac)
				#return
			#}
			#var alreadyPermUnwelcome = g_man.MultiServPer_PermenantUnwelcomedMac.Select(client.ID, idMac)
			#if (alreadyPermUnwelcome.Length > 0)
			#{
				#MakeHacker(idMac)
			#}
		#}
		#catch (Exception e){Debug.LogError(e) MoldWindowManager.sin.SetMoldWindowInstructionsOnly("Fatal error", $"{e}")}
	#}
	#private void MakeHacker(long idMac)
	#{
		#//make permanent unwelcome at specific id person
		#var idRows = g_man.MultiSPer_UnwelcomedMac.Select(client.ID, idMac)
		#if(idRows.Length > 0)
			#DataBase.Insert(true, NetMan.DbMs, DataBase.path.fingerPrintServPer_UnwelcomedMac, DataBase.fileName.approved, idRows[0], false, DataBase.Operating.equals)
#
		#g_man.MultiServPer_PermenantUnwelcomedMac.AddRow(0, client.ID, idMac)
#
		#var idRow = g_man.MultiPerUnwelcomeMac_IdMac.Select(0, idMac)
		#if (idRow.Length == 0)
		#{
			#var newIdRow = g_man.SavablePermanentUnwelcomeMac.Set(new PermanentUnwelcomeMac()
			#{
				#Count = 1,
				#IDMac = idMac
			#})
			#g_man.MultiPerUnwelcomeMac_IdMac.AddRow(0, newIdRow, idMac)
		#}
		#else
		#{
			#var perm = g_man.SavablePermanentUnwelcomeMac.Get(idRow[0])
			#perm.Count++
			#perm.Save()
#
		#}

	#endregion end FingerPrint
#region mainMenu
	#region ID


@rpc("call_local", "any_peer", "reliable")
func target_confirm_picture_received():
	g_man.local_network_node.client.send_picture = true

@rpc("call_local", "any_peer", "reliable")
func cmd_refresh_id_pictures():
	var node = intro()
	if node:
		var level = node.client.user_level
		if level < Client.BECOME_MODERATOR:
			return
		var not_verified = g_man.multi_server_client__not_verified_picture.select(0, level)
		target_load_id_pictures.rpc_id(node.id_net, not_verified)

@rpc("call_local", "any_peer", "reliable")
func target_load_id_pictures(ids):
	g_man.corg.mod_pictures_button_tool.add_buttons(ids)

@rpc("call_local", "any_peer", "reliable")
func cmd_refresh_id_picture(id_picture):
	var node = intro()
	if node:
		var c:Client = g_man.savable_server_accounts.get_index_data(id_picture)
		if c.verified_corg == 0:
			push_error("should never come to this")
			return
		var array_pictures = c.load_return_raw_picture_data()
		#debugging
		push_error("delete bottom emso it's for debugging only")
		var debug_emso = c.load_return_emso()
		
		printerr("refresh id picture", id_picture)
		target_load_id_picture.rpc_id(node.id_net, id_picture, array_pictures[0], array_pictures[1], debug_emso)

@rpc("call_local", "any_peer", "reliable")
func target_load_id_picture(id, raw_face, raw_id, emso):
	var pending = PendingForCorg.new()
	pending.raw_face = raw_face
	pending.raw_id = raw_id
	pending.emso = emso
	g_man.corg.refreshed_id(id, pending)
	
	
## add ID to person with correct identity card linked to ID Moderator is doing this
## id of person
## emso id of identity card
@rpc("call_local", "any_peer", "reliable")
func cmd_add_id(id, emso):
	var node = intro()
	if node:
		var moderator:Client = node.client
		if moderator.user_level < 3:
			push_error("too low user level: ", moderator.user_level)
			return
		var person:Client = g_man.savable_server_accounts.get_index_data(id)
		# if mod level is 1 size more than before user it can go through AND 255 mod level
		if person.verified_corg + 1 != moderator.user_level && moderator.user_level != 255:
			push_error("too low/high mod level: ", moderator.user_level, " needed: ", person.verified_corg + 1)
			return
		
		if emso == "reset picture":
			person.reset_ems(moderator.user_level, true)
			return
		if emso == "x":
			person.reset_ems(moderator.user_level, false)
			return
		if len(emso) < 9:
			return
		# mod that has approve it
		Client.add_mod(person.id, moderator.id, emso)
		# if added emšo is correct in any case
		var client_emso = person.load_return_emso()
		var client_emso_repair = person.load_return_emso_repair()
		if client_emso == emso || client_emso_repair == emso || person.verified_corg == 1:
			# same emšo maybe moderator has one check moderator he made fraud
			# else emšo is good
			if g_man.dict_emso__id.has(emso):
				var person_id = g_man.dict_emso__id[emso]
				# emšo isn't same id
				if person_id != person.id:
					# this EMŠO is good for the checked person
					# but he has alt made an emšo so he cannot be moderator
					var client_emso_starter = person.load_return_emso_starter()
					if client_emso_starter == emso:
						push_error("NOT TESTED SQL")
						actually_this_is_fraud(person_id)
						correct_emso(person, moderator, emso)
						return
					
					verify_mods_get_fraud_client(person)
					# this emšo is never good
					push_error("NOT TESTED SQL")
					person.reset_ems(moderator.user_level, false)
					return
			
			correct_emso(person, moderator, emso)
			return
		# could be typo or wrong picture will see in next verifications of moderators
		if person.verified_corg != 1:
			push_warning("repair EMS ", emso)
			person.save_emso_repair(emso)
			person.reset_ems(moderator.user_level, false)
			person.save_mod_verified(moderator.id, emso)
			# demote mod
			##//person.RewardBeforeMod(client.id, -10)
			# save new emso
		# if EMSO already exists it won't go through
		if g_man.dict_emso__id.has(emso):
			# check it again
			# it used to be granted
			push_error("NOT TESTED SQL")
			person.reset_ems(moderator.user_level, true)
			var idDouble = g_man.dict_emso__id[emso]
			# check first one too
			# it tried to be granted
			var first_already_confirmed_person:Client = g_man.savable_server_accounts.get_index_data(idDouble)
			first_already_confirmed_person.reset_ems(moderator.user_level, true)
			

func correct_emso(person:Client, moderator, emso):
	# jump from starterEmšo
	person.change_emso(moderator.user_level, moderator.id, emso)
	person.save_emso_repair("x")
	
	# send message to the client that he's been approved
	if g_man.dict_id_unique__connected_node.has(person.id_net):
		var node:NetworkNode = g_man.dict_id_unique__connected_node[person.id_net]
		node.target_instructions.rpc_id(person.id_net, ["you have been approved", "to enter CORG", "your id number is now bound to this account"])
		target_send_corg_verified_person.rpc_id(node.id_net, person.corg_verified_person)
	
	# all done he is ready to enter CORG for good
	push_warning("moderator User Level:", moderator.user_level, " last in chain: ", g_man.last_in_chain_user_level - 2)
	# first some are going to be approved instantly as they will be approved by me or sister
	if moderator.user_level >= g_man.last_in_chain_user_level - 2:
		push_warning("added to the staff")
		# remove mods from DB and add him almost permanently to the staff 
		Client.RemoveAllMods(person.id)

func actually_this_is_fraud(id_fraud_one):
	var fraud = g_man.savable_server_accounts.get_index_data(id_fraud_one)
	fraud.reset_ems(255, true)
	fraud.userLevel = 1
	fraud.SaveUserLevel()
	push_warning("username fraud one: ", fraud._userName)
	printerr("username fraud one: ", fraud._userName)

func verify_mods_get_fraud_client(client):
	var mods_verified = g_man.savable_multi_client__id_mod_verified.select(client.id, 0)
	for mod_verified in mods_verified:
		push_warning("mod verified id: ", mod_verified.id_mod)
		var macs = g_man.savable_multi_server_client__mac.get_all(mod_verified.id_mod, 0)
		for mac in macs:
			var mod_mac_ids = g_man.savable_multi_server_client__mac.get_all(0, mac.id)
			# if any mod is same as person.id
			for mod_mac_id:UnwelcomeMac in mod_mac_ids:
				var mod_mac:Mac = Mac.get_index_data(mod_mac_id.id_mac)
				var ids = g_man.multi_server_client__macs.select(0, mod_mac.id_macs)
				var x = false
				for id_mod in ids:
					if id_mod == client.id:
						# mod is a fraud he is trying to get him self in
						x = true
						break
				if not x:
					continue
				for id_mod in ids:
					var fraud_mod = g_man.savable_server_accounts.get_index_data(id_mod)
					push_error("fraud mod name: ", fraud_mod._username)
	if not mods_verified:
		return true
	return false

func add_id(node, emso):
	if node:
		if len(emso) < 9:
			return
		# skop_to_correct_emso check I'm the master of the emšo
		if node.client.load_return_emso_starter() == emso:
			skip_to_correct_emso(node, node.client, emso)
		# same ems maybe moderator has one check moderator he made fraud
		if g_man.dict_emso__id.has(emso):
			var person_id = g_man.dict_emso__id[emso]
			# emšo-s id isn't same id
			# this emšo is never good
			if person_id != node.client.id:
				if verify_mods_get_fraud_client(node.client):
					push_error("someone deleted emšo and wanted to gain his emšo")
					node.client.MakeFraud()
				push_error("this emšo is never good")
				# this emšo is never good
				return
		skip_to_correct_emso(node, node.client, emso)

func skip_to_correct_emso(node:NetworkNode, client:Client, emso):
	# master starter IF it wasn't in conflicts with any before it even tried
	# if it does come in conflict later we know who's the boss -->> this account and macAddress is marked as a low level user all accounts logged in with his macAddress
	if not client.load_return_emso_starter():
		client.save_emso_starter(emso)
		g_man.local_server_network_node.target_instructions.rpc_id(node.id_net, ["please await patiently you have changed your emso"])
	else:
		g_man.local_server_network_node.target_instructions.rpc_id(node.id_net, ["please await patiently your emso needs to be rechecked"])
	client.save_emso(emso)
	g_man.dict_emso__id[emso] = client.id
	g_man.dict_id__emso[client.id] = emso
	client.save_emso_repair("x")

@rpc("call_local", "any_peer", "reliable")
func target_send_corg_verified_person(corg_verified_person):
	g_man.local_network_node.client.corg_verified_person = corg_verified_person

	#endregion id
	#region referrer
@rpc("call_local", "any_peer", "reliable")
func cmd_set_referrer(referrer_name):
	var node = intro()
	if node:
		if node.client.save_referrer_from_cmd(referrer_name):
			var referrerClient = g_man.savable_server_accounts.get_index_data(node.client.referrer)
			g_man.local_server_network_node.target_instructions.rpc_id(node.id_net, ["you successfully bond the referrer", referrerClient._username, "to your account", "as the reward you gain 1 pineapple as starter money", "which we will be paying instead of the employers"])
		elif node.client.referrer:
			var referrerClient = g_man.savable_server_accounts.get_index_data(node.client.referrer)
			target_set_referrer.rpc_id(node.id_net, referrerClient.id, referrerClient._username)

@rpc("call_local", "any_peer", "reliable")
func target_set_referrer(id_referrer, name_referrer):
	Client.construct_for_client_new_id(id_referrer, name_referrer)
	g_man.local_network_node.client.referrer = id_referrer
	push_warning(id_referrer, " : ", g_man.local_network_node.client.id)
	g_man.main_menu_tabs.refresh_referrer()
			
@rpc("call_local", "any_peer", "reliable")
func cmd_refresh_referrer():
	var node = intro()
	if node:
		var referrer = g_man.savable_server_accounts.get_index_data(node.client.load_return_referrer())
		if referrer:
			target_set_referrer.rpc_id(node.id_net, referrer.id, referrer._username)
	#endregion end referrer
	#region refresh Money
@rpc("call_local", "any_peer", "reliable")
func cmd_refresh_money():
	var node = intro()
	if node:
		var company_money = 0
		var corg:Company = Company.try_get_server_corg(node.client.id)
		if corg:
			company_money = corg.get_money()
			target_refresh_commercial_pay.rpc_id(node.id_net, corg.comercialist_pay)
		target_refresh_money.rpc_id(node.id_net, node.client.money_system.get_money(), node.client.load_return_salary(), company_money)

@rpc("call_local", "any_peer", "reliable")
func target_refresh_money(person_money, salary, company_money):
	push_warning("corg Money ", company_money, " person ", person_money, " need to make money on person ", salary, " company money: ", company_money)
	var client = g_man.local_network_node.client
	client.money_system.set_money(person_money)
	client.save_salary(salary)
	var corg:Company = Company.try_get_client_corg(client.id)
	if corg:
		corg.set_money(company_money)
		g_man.corg.refresh_money()
	g_man.main_menu_tabs.refresh_money()
	#endregion end refresh Money
	#region honor
@rpc("call_local", "any_peer", "reliable")
func cmd_load_honor():
	var node = intro()
	if node:
		target_load_honor.rpc_id(node.id_net, node.client.honor)

@rpc("call_local", "any_peer", "reliable")
func target_load_honor(honor):
	g_man.local_network_node.client.honor = honor
	g_man.corg.update_honor()
	#endregion honor
	#region Workers
		#region addWorker

@rpc("call_local", "any_peer", "reliable")
func cmd_add_self_proprietor():
	var node:NetworkNode = intro()
	if node:
		if not node.client._username:
			node.client.load_username()
		if node.client.can_i_be_employed(0):
			var salary = MoneyCurrency.convert_money(5, MoneyCurrency.plant.apple)
			var id_corg
			var corgs = g_man.savable_multi_account__corg.get_all(node.client.id, 0)
			var corg:Company
			if corgs:
				id_corg = corgs[0].id
				corg = g_man.savable_multi_account__corg.get_p_s_data(node.client.id, id_corg)
			else:
				corg = g_man.savable_multi_account__corg.new_data(node.client.id, 0)
			corg.add_to_profit_cap(MoneyCurrency.convert_money(1, MoneyCurrency.plant.pineapple))
			corg.set_money(MoneyCurrency.convert_money(10, MoneyCurrency.plant.apple))
			corg.save_money()
			id_corg = corg.id
			node.client.employ_me(id_corg, salary)
			target_update_worker.rpc_id(node.id_net, node.client.id, node.client.id, id_corg, node.client._username, salary, node.client.load_return_biography())
			target_refresh_money.rpc_id(node.id_net, node.client.get_money(), node.client.load_return_salary(), corg.get_money())
			return
		if node.client.self_employed():
			var corgs = g_man.savable_multi_account__corg.get_all(node.client.id, 0)
			target_update_worker.rpc_id(node.id_net, node.client.id, node.client.id, corgs[0].id, node.client._username, node.client.load_return_salary(), node.client.load_return_biography())

## only corg ask for this
@rpc("call_local", "any_peer", "reliable")
func cmd_add_worker(employeeName, salary):
	var node = intro()
	if node:
		var corgs = g_man.savable_multi_account__corg.get_all(node.client.id, 0)
		if corgs:
			# let's check if worker exists
			if !g_man.server_usernames.has(employeeName):
				push_warning("employee: " + employeeName + " doesn't exists")
				return
			# we load employee data
			var id_employee = g_man.server_usernames[employeeName]
			var id_corgs = g_man.multi_server_worker__corg.select(id_employee, 0)
			if id_corgs:
				var id_employer = g_man.savable_multi_account__corg.select(0, id_corgs[0])
				var employee_employer = g_man.savable_server_accounts.get_index_data(id_employer[0])
				g_man.local_server_network_node.target_instructions.rpc_id(node.id_net, [employeeName, "is already employed at:", employee_employer._username])
			else:
				g_man.multi_server_worker__corg.add_row(0, id_employee, corgs[0].id)
				g_man.multi_server_corg__applied.delete(0, id_employee)
				# we check salary integrity:
				if salary < 5:
					salary = 5
				elif salary > 25:
					salary = 25
				# we change it to apples/day
				salary *= MoneyCurrency.convert_money(1, MoneyCurrency.plant.apple)
				var employee:Client = g_man.savable_server_accounts.get_index_data(id_employee)
				employee.save_salary(salary)
				target_update_worker.rpc_id(node.id_net, id_employee, node.client.id, corgs[0].id, employee._username, salary, employee.load_return_biography())
		#endregion end addWorker
		#region refreshWorkers
@rpc("call_local", "any_peer", "reliable")
func cmd_refresh_workers():
	var node = intro()
	if node:
		var corgs = g_man.savable_multi_account__corg.get_all(node.client.id, 0)
		if corgs:
			var id_workers = g_man.multi_server_worker__corg.select(0, corgs[0].id)
			target_refresh_workers.rpc_id(node.id_net, id_workers)

@rpc("call_local", "any_peer", "reliable")
func target_refresh_workers(id_workers):
	g_man.corg.add_workers(id_workers)
		#endregion end refreshWorkers
		#region refreshWorker
@rpc("call_local", "any_peer", "reliable")
func cmd_refresh_worker(id_worker):
	var node = intro()
	if node:
		var worker:Client = g_man.savable_server_accounts.get_index_data(id_worker)
		if worker:
			worker.load_username()
			var worker_employed_at
			var corgs = g_man.multi_server_worker__corg.select(worker.id, 0)
			if corgs:
				var employers = g_man.savable_multi_account__corg.select(0, corgs[0])
				if employers:
					worker_employed_at = employers[0]
				else:
					push_error("worker doesn't have corg any longer")
			else:
				worker.fire_me(true)
				push_error("worker doesn't have corg any longer")
			if worker_employed_at:
				if worker_employed_at == node.client.id:
					target_update_worker.rpc_id(node.id_net, worker.id, worker_employed_at, corgs[0], worker._username, worker.load_return_salary(), worker.load_return_biography())
				else:
					push_error("worker doesn't same employer")
			else:
				push_error("worker isn't employed")
		else:
			push_error("worker doesn't exists")

@rpc("call_local", "any_peer", "reliable")
func target_update_worker(id_employee, id_employed_at, id_corg, username, salary, biography):
	var employee:Client = Client.construct_for_client_new_id(id_employee, username)
	employee._username = username
	employee.fully_save()
	employee.save_salary(salary)
	employee.save_biography(biography)
	employee.save_employed_at(id_employed_at)
	employee.save_employed_at_corg(id_corg)
	
	# self proprietor
	g_man.corg.is_self_proprietor()
	if id_employed_at:
		g_man.corg.refresh_worker(employee)
		g_man.corg.remove_applicator(employee)
	else:
		g_man.corg.remove_worker(employee)
		#if employee.id_server == g_man.local_network_node.client.id_server:
		g_man.workers_window.close_window()
		#endregion end refreshWorker
		#region change salary
## only employer can do this
@rpc("call_local", "any_peer", "reliable")
func cmd_change_salary(id_employee, salary):
	var node = intro()
	if node:
		var employee:Client = g_man.savable_server_accounts.get_index_data(id_employee)
		if employee:
			var corgs = g_man.savable_multi_account__corg.get_all(node.client.id, 0)
			if corgs:
				if g_man.multi_server_worker__corg.select(id_employee, corgs[0].id):
					if salary < 5:
						salary = 5
					elif salary > 25:
						salary = 25
					salary = MoneyCurrency.convert_money(salary, MoneyCurrency.plant.apple)
					employee.save_salary(salary)
					#corgs.calc_profit_cap()
					target_update_worker.rpc_id(node.id_net, employee.id, node.client.id, corgs[0].id, employee._username, salary, employee.load_return_biography())
		#endregion end change salary
		#region remove worker
@rpc("call_local", "any_peer", "reliable")
func cmd_remove_worker(id_employee):
	var node = intro()
	if node:
		var employee:Client = g_man.savable_server_accounts.get_index_data(id_employee)
		if employee:
			var corgs = g_man.savable_multi_account__corg.get_all(node.client.id, 0)
			if corgs:
				if g_man.multi_server_worker__corg.select(id_employee, corgs[0].id):
					#destroy corg
					if node.client.id == id_employee:
						node.client.fire_me(true)
					else:
						g_man.multi_server_worker__corg.delete(id_employee, corgs[0].id)
					target_update_worker.rpc_id(node.id_net, id_employee, 0, 0, employee._username, 0, employee.load_return_biography())
			# something went wrong let's let him fire him self
			elif id_employee == node.client.id:
				node.client.fire_me(true)
				target_update_worker.rpc_id(node.id_net, id_employee, 0, 0, employee._username, 0, employee.load_return_biography())
		#endregion end remove worker
		#region applyForJob
## client applies for a job
@rpc("call_local", "any_peer", "reliable")
func cmd_apply_for_job(str_employer):
	var node = intro()
	if node:
		if g_man.multi_server_worker__corg.select(node.client.id, 0):
			g_man.local_server_network_node.target_instructions.rpc_id(node.id_net, ["you are already employed", "you cannot apply for job at the moment."])
			return
		
		if not g_man.server_usernames.has(str_employer):
			g_man.local_server_network_node.target_instructions.rpc_id(node.id_net, ["employer you are willing to apply to", "does not exist."])
			return
		
		var id_employer = g_man.server_usernames[str_employer]
		var id_corgs = g_man.savable_multi_account__corg.select(id_employer, 0)
		if not id_corgs:
			g_man.local_server_network_node.target_instructions.rpc_id(node.id_net, ["employer you are willing to apply to", "does is not corg."])
			return
		
		if g_man.multi_server_corg__applied.select(id_corgs[0], node.client.id):
			g_man.local_server_network_node.target_instructions.rpc_id(node.id_net, ["you have already applied to corg", str_employer, "please await patiently for him to approve you"])
			return
		
		g_man.multi_server_corg__applied.add_row(0, id_corgs[0], node.client.id)
		g_man.local_server_network_node.target_instructions.rpc_id(node.id_net, ["you sucessfully applied to corg"])

@rpc("call_local", "any_peer", "reliable")
func cmd_refresh_applicators():
	var node = intro()
	if node:
		var corgs = g_man.savable_multi_account__corg.get_all(node.client.id, 0)
		if corgs:
			var applicators = g_man.multi_server_corg__applied.select(corgs[0].id, 0)
			if applicators:
				target_refresh_applications.rpc_id(node.id_net, applicators)
@rpc("call_local", "any_peer", "reliable")
func target_refresh_applications(applicators):
	g_man.corg.add_applicators(applicators)

@rpc("call_local", "any_peer", "reliable")
func cmd_refresh_applicator(id_applicator):
	var node = intro()
	if node:
		var corgs = g_man.savable_multi_account__corg.get_all(node.client.id, 0)
		if corgs:
			if g_man.multi_server_corg__applied.select(corgs[0].id, id_applicator):
				var applicator:Client = g_man.savable_server_accounts.get_index_data(id_applicator)
				if applicator:
					var employed_at = 0
					var employed_at_corgs = g_man.multi_server_worker__corg.select(applicator.id, 0)
					if employed_at_corgs:
						var employers = g_man.savable_multi_account__corg.select(0, employed_at_corgs[0])
						if employers:
							employed_at = employers[0]
					target_refresh_applicator.rpc_id(node.id_net, applicator.id, employed_at, employed_at_corgs[0], applicator._username, applicator.load_return_biography())

@rpc("call_local", "any_peer", "reliable")
func target_refresh_applicator(id_applicator, employed_at, id_corg, username, biography):
	var aplicator:Client = Client.construct_for_client_new_id(id_applicator, username)
	aplicator.save_biography(biography)
	aplicator.save_employed_at(employed_at)
	aplicator.save_employed_at_corg(id_corg)
	g_man.corg.refresh_applicator(aplicator)
		#endregion end applyForJob
		#region biografy
## biography
@rpc("call_local", "any_peer", "reliable")
func cmd_set_biography(text):
	var node = intro()
	if node:
		node.client.save_biography(text)
		g_man.local_server_network_node.target_instructions.rpc_id(node.id_net, ["you have sucessfully saved biography"])

@rpc("call_local", "any_peer", "reliable")
func cmd_load_biography(id_client):
	var node = intro()
	if node:
		var client:Client = g_man.savable_server_accounts.get_index_data(id_client)
		target_load_biography.rpc_id(node.id_net, id_client, client.load_return_biography())

@rpc("call_local", "any_peer", "reliable")
func target_load_biography(id_client, biography):
	var client:Client = Client.construct_for_client_new_id(id_client, "loaded biography's name unknown")
	client.save_biography(biography)
	if g_man.workers_window.id == id_client:
		g_man.workers_window.biography.text = String("{biography}").format({biography = biography})
	if g_man.local_network_node.client.id_server == id_client:
		g_man.account_worker_stats_window.biography.text = String("{biography}").format({biography = biography})
		#endregion end biografy
		#region startEndWorking
# only worker sets him self when he starts to work
@rpc("call_local", "any_peer", "reliable")
func cmd_start_end_job(start:bool):
	var node = intro()
	if node:
		node.client.start_stop_working(start)

@rpc("call_local", "any_peer", "reliable")
func target_update_job_status(currently_working, seconds):
	g_man.account_worker_stats_window.set_working_stats(currently_working, seconds)
		#endregion end startEndWorking
	#endregion end workers
	#region Corgs
@rpc("call_local", "any_peer", "reliable")
func cmd_refresh_corg(id_server_corg):
	var node = intro()
	if node:
		var corg = g_man.savable_multi_account__corg.get_index_data(id_server_corg)
		if corg:
			var id_founders = g_man.savable_multi_account__corg.select(0, corg.id)
			if id_founders:
				target_refresh_corg.rpc_id(node.id_net, corg.id, id_founders[0])

@rpc("call_local", "any_peer", "reliable")
func target_refresh_corg(id_corg, id_founder):
	var client_corg:Company = ConstructForClient.construct_client_shared_multi_table_savable(g_man.multi_client__server_corg, g_man.savable_client_corg, id_corg)
	client_corg.founder = id_founder
	client_corg.save_founder()
	# we activate the signals to which we need to give the data of corg
	g_man.corg_signal.emit(client_corg)
	for item in g_man.corg_signal.get_connections():
		g_man.corg_signal.disconnect(item.callable)
	#endregion
	#region politics
		#region Spenders
			#region addSpenders
@rpc("call_local", "any_peer", "reliable")
func cmd_add_spender(spending_for_text):
	var node = intro()
	if node:
		var type = 1
		var id_spender = node.client.load_return_spender()
		if id_spender:
			var id_left_rows = g_man.savable_multi_type__spender.select(0, node.client.id)
			if id_left_rows:
				if id_left_rows[0] == 1:
					g_man.local_server_network_node.target_instructions.rpc_id(node.id_net, ["you haven't been accepted nor declined", "please wait"])
				elif id_left_rows[0] == 2:
					g_man.local_server_network_node.target_instructions.rpc_id(node.id_net, ["you have been already accepted for spender"])
					type = 2
				elif id_left_rows[0] == 3:
					g_man.local_server_network_node.target_instructions.rpc_id(node.id_net, ["you have been banned for being spender you may no longer apply for spender"])
					#type = 3 doesn't need it for new_data
					return
		push_error("uncomment!!!", node.client.user_level)
		if node.client.user_level < Client.BECOME_MODERATOR:
			g_man.local_server_network_node.target_instructions.rpc_id(node.id_net,
				["you are too low user level cannot be spender yet",
				str("your level: ", node.client.user_level),
				str("needed level: ", Client.BECOME_MODERATOR)]
			)
			#return
		
		# if person needs to become spender
		var spender:Spender = g_man.savable_multi_type__spender.new_data(type, node.client.id)
		spender.save_spending_for_text(spending_for_text)
		spender.save_id_client(node.client.id)
		node.client.save_spender(spender.id)
		
		target_add_spenders.rpc_id(node.id_net, 1, [spender.id], true)

@rpc("call_local", "any_peer", "reliable")
func target_add_spenders(type, id_spenders, force = false):
	g_man.spender_tab.add_buttons_spenders(type, id_spenders)
	if force:
		cmd_refresh_spender.rpc_id(1, id_spenders[0])
			#endregion addSpenders
			#region get spenders
@rpc("call_local", "any_peer", "reliable")
func cmd_get_spenders(type, _start_at = 0):
	var node = intro()
	if node:
		var id_spenders = g_man.savable_multi_type__spender.get_id_rows(type, 0)
		target_add_spenders.rpc_id(node.id_net, type, id_spenders)

			#endregion
			#region get spender
@rpc("call_local", "any_peer", "reliable")
func cmd_refresh_spender(id_spender):
	var node = intro()
	if node:
		var spender:Spender = g_man.savable_multi_type__spender.get_index_data(id_spender)
		if spender:
			var mc = g_man.savable_multi_type__spender.get_mc_from_id(id_spender)
			var spender_array = Serializable.serialize([spender])
			target_refresh_spender.rpc_id(node.id_net, mc.left, spender_array, g_man.stat_total_persons_on_corg_count)

@rpc("call_local", "any_peer", "reliable")
func target_refresh_spender(type, spender_array, total_persons_on_corg_count):
	g_man.client_total_persons_on_corg_count = total_persons_on_corg_count
	var spenders = Serializable.deserialize(Spender.new(), spender_array)
	if spenders:
		var spender = spenders[0]
		g_man.spender_tab.refresh_spender(type, spender)
		
			#endregion
			#region voteSpender
@rpc("call_local", "any_peer", "reliable")
func cmd_vote_spender(id, vote):
	var node = intro()
	if node:
		var spender:Spender = g_man.savable_multi_type__spender.get_index_data(id)
		if spender:
			var mc = g_man.savable_multi_type__spender.get_mc_from_id(id)
			spender.add_vote(mc.left, node.client.id, vote)
			var spender_array = Serializable.serialize([spender])
			var types = g_man.savable_multi_type__spender.select(0, spender.id_client)
			if types:
				var type = types[0]
				target_refresh_spender.rpc_id(node.id_net, type, spender_array, g_man.stat_total_persons_on_corg_count)
			#endregion
		#endregion
		#region Law
			#region lawTypes
@rpc("call_local", "any_peer", "reliable")
func cmd_get_last_id_law_types():
	var node = intro()
	if node:
		var last_id = g_man.savable_law_meta.last_id()
		target_get_last_id_law_types.rpc_id(node.id_net, last_id)
		
@rpc("call_local", "any_peer", "reliable")
func target_get_last_id_law_types(last_id):
	g_man.law_tab.add_buttons_last_id(last_id)

@rpc("call_local", "any_peer", "reliable")
func cmd_refresh_law_meta(id):
	var node = intro()
	if node:
		var law_meta:LawMeta = g_man.savable_law_meta.get_index_data(id)
		if law_meta:
			target_refresh_law_meta.rpc_id(node.id_net, law_meta.id, law_meta.header)
		else:
			target_refresh_law_meta.rpc_id(node.id_net, law_meta.id, "xxx")

@rpc("call_local", "any_peer", "reliable")
func target_refresh_law_meta(id, header):
	g_man.law_tab.refresh_law_meta(id, header)
			#endregion
			#region add Laws
@rpc("call_local", "any_peer", "reliable")
func cmd_add_suggest_law(id_type, header, body):
	var node = intro()
	if node:
		if id_type && id_type > 0:
			var id_old_law = node.client.load_return_id_active_law_suggested()
			if id_old_law:
				var old_law:Law = g_man.savable_multi_law_type__law.get_index_data(id_old_law)
				if old_law:
					g_man.local_server_network_node.target_instructions.rpc_id(node.id_net, [old_law.header_text, "was not accepted nor declined", "please wait till then"])
				else:
					# if it's null let's just delete the reference
					g_man.savable_multi_law_type__law.delete_id_row(id_old_law)
					node.client.save_id_active_law_suggested(null)
				return
			if node.client.user_level < Client.BECOME_MODERATOR:
				g_man.local_server_network_node.target_instructions.rpc_id(node.id_net, ["you do not have user level large enough", node.client.user_level, "so you may not suggest any laws yet.", "need at least:", Client.BECOME_MODERATOR])
				return
			# we set it in to type suggested (1)
			var law:Law = g_man.savable_multi_law_type__law.new_data(1, 0)
			law.header_text = header
			law.body_text = body
			law.law_type = id_type
			law.id_poster = node.client.id
			law.accepted_law = false
			law.fully_save()
			node.client.save_id_active_law_suggested(law.id)
			#endregion
			#region get Laws
@rpc("call_local", "any_peer", "reliable")
func cmd_get_id_laws_from_types(id_law_type):
	var node = intro()
	if node:
		var id_laws = g_man.savable_multi_law_type__law.select(id_law_type, 0)
		if id_laws:
			target_get_id_laws.rpc_id(node.id_net, id_laws)

@rpc("call_local", "any_peer", "reliable")
func target_get_id_laws(id_laws):
	g_man.law_manager.add_buttons(id_laws)
			#endregion get laws
			#region get Law
@rpc("call_local", "any_peer", "reliable")
func cmd_get_law(id_law):
	var node = intro()
	if node:
		var law:Law = g_man.savable_multi_law_type__law.get_index_data(id_law)
		if not law:
			return
		if not law.header_text || not law.body_text:
			g_man.savable_multi_law_type__law.delete_id_row(id_law)
		var law_array = Serializable.serialize([law])
		target_refresh_law.rpc_id(node.id_net, law_array, g_man.stat_total_persons_on_corg_count)

@rpc("call_local", "any_peer", "reliable")
func target_refresh_law(law_array, total_persons_on_corg_count):
	g_man.client_total_persons_on_corg_count = total_persons_on_corg_count
	var laws = Serializable.deserialize(Law.new(), law_array)
	if laws:
		g_man.law_manager.refresh_law(laws[0])
			#endregion get law
			#region vote law
@rpc("call_local", "any_peer", "reliable")
func cmd_vote_law(id_law, vote:bool):
	var node = intro()
	if node:
		var law:Law = g_man.savable_multi_law_type__law.get_index_data(id_law)
		if law:
			law.add_vote(node.client.id, vote)
			var law_array = Serializable.serialize([law])
			target_refresh_law.rpc_id(node.id_net, law_array, g_man.stat_total_persons_on_corg_count)
			#endregion vote law
		#endregion
	#endregion
#endregion end mainMenu
#region marketplace
	#region traders
### check all traders in range
#@rpc("call_local", "any_peer", "reliable")
#func cmd_refresh_market_traders(startAt):
	#var ids = g_man.MultiCorg_Items.SelectLeftRow(startAt, 10)
	##// long[] ids = g_man.MultiCorg_Items.Select(0, 2, startAt, count)
	#endregion end traders
		#region all items
			#region items
				#region add to market
@rpc("call_local", "any_peer", "reliable")
func cmd_add_item_to_market(item_name, cost):
	var node = intro()
	if node:
		var corgs = g_man.savable_multi_account__corg.get_all(node.client.id, 0)
		if corgs:
			# make item
			var item:Item = g_man.savable_multi_corg__items.new_data(corgs[0].id, 0)
			item.save_name(item_name)
			item.save_cost(cost)
			item.save_id_server_corg(corgs[0].id)
			target_add_items_to_market.rpc_id(node.id_net, corgs[0].id, [item.id])

@rpc("call_local", "any_peer", "reliable")
func target_add_items_to_market(id_corg, ids):
	g_man.store_manager.add_items_buttons(id_corg, ids)
				#endregion add to market
				#region get traders
@rpc("call_local", "any_peer", "reliable")
func cmd_get_traders(start_at):
	var node = intro()
	if node:
		var id_corgs = g_man.savable_multi_corg__items.get_left_rows(start_at, 10)
		target_refresh_traders.rpc_id(node.id_net, id_corgs)

@rpc("call_local", "any_peer", "reliable")
func target_refresh_traders(id_server_corgs):
	g_man.marketplace.add_trader_buttons(id_server_corgs)

@rpc("call_local", "any_peer", "reliable")
func cmd_refresh_trader(id_corg):
	var node = intro()
	if node:
		var id_clients = g_man.savable_multi_account__corg.select(0, id_corg)
		if id_clients:
			var client:Client = g_man.savable_server_accounts.get_index_data(id_clients[0])
			target_refresh_trader_name.rpc_id(node.id_net, id_corg, client._username)
			
@rpc("call_local", "any_peer", "reliable")
func target_refresh_trader_name(id_corg, trader_name):
	g_man.marketplace.refresh_trader(id_corg, trader_name)

@rpc("call_local", "any_peer", "reliable")
func cmd_refresh_trader_self():
	var node = intro()
	if node:
		var corg = Company.try_get_server_corg(node.client.id)
		if corg:
			var id_server_items = g_man.savable_multi_corg__items.select(corg.id, 0)
			target_add_items_to_market.rpc_id(node.id_net, corg.id, id_server_items)

@rpc("call_local", "any_peer", "reliable")
func cmd_refresh_trader_items(id_corg):
	var node = intro()
	if node:
		var id_server_items = g_man.savable_multi_corg__items.select(id_corg, 0)
		if id_server_items:
			target_add_items_to_market.rpc_id(node.id_net, id_corg, id_server_items)
				#endregion get traders
				#region refresh item
@rpc("call_local", "any_peer", "reliable")
func cmd_refresh_item(id_server_item):
	var node = intro()
	if node:
		var items = g_man.savable_multi_corg__items.get_all(0, id_server_item)
		if items:
			var serialized_item = Serializable.serialize(items)
			target_refresh_item.rpc_id(node.id_net, serialized_item)

@rpc("call_local", "any_peer", "reliable")
func target_refresh_item(serialized_item):
	var items = Serializable.deserialize(Item.new(), serialized_item)
	for item in items:
		g_man.store_manager.refresh_item(item)
				#endregion refresh item
				#region update item
@rpc("call_local", "any_peer", "reliable")
func cmd_update_market_item(id_item, item_name, item_cost, _quantity = 0):
	var node = intro()
	if node:
		var corg = Company.try_get_server_corg(node.client.id)
		if corg:
			var item:Item = g_man.savable_multi_corg__items.get_all(corg.id, id_item)
			if item:
				if not item_name ||  item_name == "x":
					return
				if item_cost < 100:
					item_cost = 100
				item.save_name(item_name)
				item.save_cost(item_cost)
				var serialized_item = Serializable.serialize([item])
				target_refresh_item.rpc_id(node.id_net, serialized_item)
				g_man.local_server_network_node.target_instructions.rpc_id(node.id_net, ["you have successfully changed item"])

@rpc("call_local", "any_peer", "reliable")
func cmd_remove_market_item(id_item):
	var node = intro()
	if node:
		var corg = Company.try_get_server_corg(node.client.id)
		if corg:
			var item:Item = g_man.savable_multi_corg__items.get_all(corg.id, id_item)
			if item:
				ReservedOnItem.server_remove_reserved(item.id, 0)
				g_man.savable_multi_corg__items.delete_id_row(item.id)
				#endregion update item
				#region buy item

## buyer buys product
@rpc("call_local", "any_peer", "reliable")
func cmd_buy_market_item(id_item, quantity, buy_as):
	var node = intro()
	if node.client.itsUnwelcomedGuestInside:
		return
	var id_corgs = g_man.savable_multi_corg__items.select(0, id_item)
	if id_corgs:
		var corg = Company.try_get_server_corg(node.client.id)
		if corg:# can't buy from self
			if corg.id == id_corgs[0]:
				return
		var item = g_man.savable_multi_corg__items.get_all(id_corgs[0], id_item)
		if item:
			# we check item integrity
			## if customer has enough money
			var total_cost = item.cost_text * quantity
			if total_cost > 0 && node.client.enough_money(total_cost):
				# paying the goods
				if buy_as == Item.buy_as.corg:
					if corg:
						if not corg.outcome(total_cost, item.id_server_corg, node.client.id, item.id, quantity):
							# not enough money
							return
					else:
						# not corg
						return
				elif buy_as == Item.buy_as.customer:
					if not node.client.outcome_buying(total_cost, item.id_server_corg, item.id, quantity):
						return
				elif buy_as == Item.buy_as.spender:
					# spender
					printerr("not done yet spender")
					return
				var id_row = g_man.multi_s_corg__customer.add_row(0, item.id_server_corg, node.client.id)
				var buyer_request:RequestedItem = g_man.multi_s_corg__customer___requested_item.new_data(id_row, 0)
				buyer_request.config(item, node.client.id)
				buyer_request.fully_save()
				#endregion buy item
				#region requested item
					#region customer
##TODO: Reserved on CORG
@rpc("call_local", "any_peer", "reliable")
func cmd_get_customers_of_requested_items():
	var node = intro()
	if node:
		var corg = Company.try_get_server_corg(node.client.id)
		if corg:
			var id_customers = g_man.multi_s_corg__customer.select(corg.id, 0)
			target_get_customers_of_requested_items.rpc_id(node.id_net, id_customers)
			
@rpc("call_local", "any_peer", "reliable")
func target_get_customers_of_requested_items(id_customers):
	g_man.store_manager.add_requested_customers_buttons(id_customers)

@rpc("call_local", "any_peer", "reliable")
func cmd_refresh_customer_of_requested_items(id_customer):
	var node = intro()
	if node:
		var acc = g_man.savable_server_accounts.get_index_data(id_customer)
		if acc:
			target_refresh_customer_of_requested_items.rpc_id(node.id_net, id_customer, acc._username)

@rpc("call_local", "any_peer", "reliable")
func target_refresh_customer_of_requested_items(id_customer, username):
	g_man.store_manager.refresh_requested_customers_button(id_customer, username)
					#endregion customer
					#region id requested
@rpc("call_local", "any_peer", "reliable")
func cmd_get_requested_items(id_customer):
	var node = intro()
	if node:
		var corg = Company.try_get_server_corg(node.client.id)
		if corg:
			var id_row = g_man.multi_s_corg__customer.select_id_row_p_s(corg.id, id_customer)
			var id_requested_items = g_man.multi_s_corg__customer___requested_item.select(id_row, 0)
			target_get_requested_items.rpc_id(node.id_net, id_requested_items)

@rpc("call_local", "any_peer", "reliable")
func cmd_get_requested_items_for_customer(id_corg):
	var node = intro()
	if node:
		var id_row = g_man.multi_s_corg__customer.select_id_row_p_s(id_corg, node.client.id)
		var id_requested_items = g_man.multi_s_corg__customer___requested_item.select(id_row, 0)
		target_get_requested_items.rpc_id(node.id_net, id_requested_items)

@rpc("call_local", "any_peer", "reliable")
func target_get_requested_items(id_requested_items):
	g_man.store_manager.add_requested_items_of_customer_buttons(id_requested_items)

					#endregion id requested
					#region refresh requested item
@rpc("call_local", "any_peer", "reliable")
func cmd_refresh_requested_item(id_requested_item):
	var node = intro()
	if node:
		var corg = Company.try_get_server_corg(node.client.id)
		var requested_item:RequestedItem = g_man.multi_s_corg__customer___requested_item.get_index_data(id_requested_item)
		if requested_item:
			# if customer is lloking at his own requested items || company is looking at his own customers and their requested items
			if requested_item._id_customer == node.client.id || corg && requested_item.id_trader == corg.id:
				var serialized_requested_item = Serializable.serialize([requested_item])
				target_refresh_requested_item.rpc_id(node.id_net, serialized_requested_item)
			return
		g_man.multi_s_corg__customer___requested_item.delete_id_row(id_requested_item)

@rpc("call_local", "any_peer", "reliable")
func target_refresh_requested_item(serialized_requested_item):
	var array_requested_items = Serializable.deserialize(RequestedItem.new(), serialized_requested_item)
	g_man.store_manager.refresh_requested_item_of_customer_button(array_requested_items[0].id, array_requested_items[0])
					#endregion refresh requested item
					#region shipment of requested item
@rpc("call_local", "any_peer", "reliable")
func cmd_requested_item_shipment_change_status(id_requested_item):
	var node = intro()
	if node:
		var corg = Company.try_get_server_corg(node.client.id)
		var requested_item:RequestedItem = g_man.multi_s_corg__customer___requested_item.get_index_data(id_requested_item)
		if requested_item:
			if corg && requested_item.id_trader == corg.id:
				requested_item.trader_set_new_status()
				requested_item.save_shipment()
				var serialized_requested_item = Serializable.serialize([requested_item])
				target_refresh_requested_item.rpc_id(node.id_net, serialized_requested_item)
				return
			elif node.client.id == requested_item._id_customer:
				requested_item.customer_set_new_status()
				requested_item.save_shipment()
				var serialized_requested_item = Serializable.serialize([requested_item])
				target_refresh_requested_item.rpc_id(node.id_net, serialized_requested_item)
				return
		g_man.multi_s_corg__customer___requested_item.delete_id_row(id_requested_item)
					#endregion shipment of requested item
				#endregion requested item
			#endregion end itmes
			#region reserved
				#region reserveOnItem
@rpc("call_local", "any_peer", "reliable")
func cmd_refresh_reserved(id_reserved):
	var node = intro()
	if node:
		var reserved:ReservedOnItem = g_man.savable_multi_item__seller____reserved_on_item.get_index_data(id_reserved)
		if reserved:
			var corg:Company = Company.try_get_server_corg(node.client.id)
			if reserved.id_buyer == corg.id:
				var reserved_array = Serializable.serialize([reserved])
				target_set_reserve.rpc_id(node.id_net, reserved_array)

@rpc("call_local", "any_peer", "reliable")
func cmd_refresh_reserved_from_item(id_item):
	var node = intro()
	if node:
		var item:Item = g_man.savable_multi_corg__items.get_index_data(id_item)
		if item:
			var ids_reserved = g_man.savable_multi_item__seller____reserved_on_item.get_id_rows(item.id, 0)
			if ids_reserved:
				target_refresh_reserved.rpc_id(node.id_net, ids_reserved)

@rpc("call_local", "any_peer", "reliable")
func target_refresh_reserved(ids_reserved):
	g_man.item_manager.add_buttons_reserved(ids_reserved)

@rpc("call_local", "any_peer", "reliable")
func cmd_add_reserve_to_item(id_item, corg_founder_name, money):
	var node = intro()
	if node:
		if g_man.server_usernames.has(corg_founder_name):
			var id_s_client = g_man.server_usernames[corg_founder_name]
			if id_s_client == node.client.id:
				g_man.local_server_network_node.target_instructions.rpc_id(node.id_net, ["you cannot reserve on your self"])
				return
			# check item
			var item:Item = g_man.savable_multi_corg__items.get_index_data(id_item)
			if not item:
				push_error("item doesn't exist")
				return
			# check the corg integrity
			var id_corg_to_reserve_on = g_man.savable_multi_account__corg.select(id_s_client, 0)
			if not id_corg_to_reserve_on:
				push_error(id_s_client, " doesn't have corg")
				return
			var id_reserving = g_man.savable_multi_account__corg.select(node.client.id, 0)
			if not id_reserving:
				push_error(node.client.id, " doesn't have corg: ", node.client._username)
				return
			var id_row = item.set_new_reserve(money, id_corg_to_reserve_on[0], id_reserving[0])
			var res = g_man.savable_multi_item__seller____reserved_on_item.get_index_data(id_row)
			var res_array = Serializable.serialize([res])
			target_set_reserve.rpc_id(node.id_net, res_array)

@rpc("call_local", "any_peer", "reliable")
func target_set_reserve (reserved_array):
	var reserveds = Serializable.deserialize(ReservedOnItem.new(), reserved_array)
	g_man.item_manager.refresh_reserved(reserveds[0].id, reserveds[0])

					#region delete reserved
@rpc("call_local", "any_peer", "reliable")
func cmd_remove_reserved(id_reserved):
	var node = intro()
	if node:
		var corg = Company.try_get_server_corg(node.client.id)
		if corg:
			var reserved:ReservedOnItem = g_man.savable_multi_item__seller____reserved_on_item.get_index_data(id_reserved)
			if reserved:
				if reserved.id_buyer == corg.id:
					g_man.savable_multi_item__seller____reserved_on_item.delete_id_row(id_reserved)
					var item = g_man.savable_multi_corg__items.get_index_data(reserved.id_item)
					if item:
						var founders = g_man.savable_multi_account__corg.select(0, reserved.id_seller)
						if founders:
							var client:Client = g_man.savable_server_accounts.get_index_data(founders[0])
							if client:
								g_man.local_server_network_node.target_instructions.rpc_id(node.id_net, ["you sucessfully removed reserved on:", client._username, "at item:", item.name_text])
					#endregion delete reserved
					#region reserve on corg
@rpc("call_local", "any_peer", "reliable")
func cmd_refresh_total_reserved_on_corg(id_reserve):
	var node = intro()
	if node:
		var reserved: ReservedOnItem = g_man.savable_multi_item__seller____reserved_on_item.get_index_data(id_reserve)
		if reserved:
			var corg = Company.try_get_server_corg(node.client.id)
			if reserved.id_buyer == corg.id:
				var money = ReservedOnCorg.get_corg_reserve_money(reserved)
				if money:
					target_refresh_total_reserved_on_corg.rpc_id(node.id_net, id_reserve, money)

@rpc("call_local", "any_peer", "reliable")
func target_refresh_total_reserved_on_corg(id_reserve, money):
	g_man.item_manager.refresh_reserved_total_on_corg(id_reserve, money)
					#endregion reserve on corg
				#endregion end reserveOnItem
			#endregion end reserved
		#endregion end all items
		#region comercials
			#region picture
				#region check commercials
@rpc("call_local", "any_peer", "reliable")
func cmd_load_corg_commercialists():
	var node = intro()
	if node:
		var id_corgs = g_man.savable_multi_corg__pictures.get_left_rows()
		if id_corgs:
			for id in id_corgs:
				var id_pics = g_man.savable_multi_corg__pictures.selecnode.client.user_levelt(id, 0)
				var timers = []
				for id_p in id_pics:
					var picture_data:PictureData = g_man.savable_multi_corg__pictures.get_all(id, id_p)
					timers.push_back(picture_data.load_return_time())
				var corgs = g_man.savable_multi_account__corg.get_all(0, id)
				if corgs:
					target_load_id_commercial_pictures.rpc_id(node.id_net, id, corgs[0].comercialist_company_add_wait, corgs[0].comercialist_pay, id_pics, timers)

@rpc("call_local", "any_peer", "reliable")
func cmd_load_id_commercial_pictures():
	var node = intro()
	if node:
		var corgs = g_man.savable_multi_account__corg.get_all(node.client.id, 0)
		if corgs:
			var id_pictures = g_man.savable_multi_corg__pictures.select(corgs[0].id, 0)
			if id_pictures:
				var timers = []
				for id in id_pictures:
					var picture_data:PictureData = g_man.savable_multi_corg__pictures.get_all(corgs[0].id, id)
					timers.push_back(picture_data.load_return_time())
				target_load_id_commercial_pictures.rpc_id(node.id_net, corgs[0].id, corgs[0].comercialist_company_add_wait, corgs[0].comercialist_pay, id_pictures, timers)

@rpc("call_local", "any_peer", "reliable")
func target_load_id_commercial_pictures(id_corg, time_between_adds, comercialist_pay, id_pictures, timers):
	var corg:Company = ConstructForClient.construct_client_shared_multi_table_savable(g_man.multi_client__server_corg, g_man.savable_client_corg, id_corg)
	corg.client_add_id_pictures(id_pictures, timers)
	corg.comercialist_company_add_wait = time_between_adds
	corg.comercialist_pay = comercialist_pay
	g_man.commercial_manager.open_window()
	var client_corg:Company = Company.try_get_client_corg(g_man.local_network_node.client.id)
	if client_corg:
		if client_corg.id_server == id_corg:
			for id in id_pictures:
				g_man.store_manager.show_store_commercial(id)
				#endregion end check commercials
				#region get picture
## we send picture to server
@rpc("call_local", "any_peer", "reliable")
func cmd_send_commercial_picture_to_server(texture_array):
	var node = intro()
	if node:
		var corg:Company = Company.try_get_server_corg(node.client.id)
		if corg:
			corg.server_add_picture(texture_array)
			var id_pics = g_man.savable_multi_corg__pictures.select(corg.id, 0)
			var timers = []
			for id_p in id_pics:
				var picture_data:PictureData = g_man.savable_multi_corg__pictures.get_all(corg.id, id_p)
				timers.push_back(picture_data.load_return_time())
			target_load_id_commercial_pictures.rpc_id(node.id_net, corg.id, corg.comercialist_company_add_wait, corg.comercialist_pay, id_pics, timers)
			g_man.local_server_network_node.target_instructions.rpc_id(node.id_net, ["send sucessfully commercial"])

@rpc("call_local", "any_peer", "reliable")
func cmd_load_id_commercial_picture(id_corg, id_picture):
	if not id_corg || not id_picture:
		return
	var node = intro()
	if node:
		var picture_data:PictureData = g_man.savable_multi_corg__pictures.get_all(id_corg, id_picture)
		if picture_data:
			var raw_picture = picture_data.load_return_raw_texture()
			if raw_picture:
				target_load_id_commercial_picture.rpc_id(node.id_net, id_corg, id_picture, raw_picture, picture_data.load_return_time())
			else:
				g_man.savable_multi_corg__pictures.delete_p_s(id_corg, id_picture)

@rpc("call_local", "any_peer", "reliable")
func target_load_id_commercial_picture(id_corg, id_picture, raw_texture, time):
	var picture_data:PictureData = ConstructForClient.construct_client_shared_savable_multi(g_man.savable_multi_client__server_pictures, id_picture)
	picture_data.save_picture(raw_texture)
	picture_data.save_time(time)
	var corg:Company = ConstructForClient.construct_client_shared_multi_table_savable(g_man.multi_client__server_corg, g_man.savable_client_corg, id_corg)
	corg.reload_picture(id_picture)
	g_man.store_manager.show_store_commercial(id_picture)

@rpc("call_local", "any_peer", "reliable")
func cmd_delete_id_commercial_picture(id_picture):
	var node = intro()
	if node:
		var id_corgs = g_man.savable_multi_account__corg.select(node.client.id, 0)
		if id_corgs:
			g_man.savable_multi_corg__pictures.delete_p_s(id_corgs[0], id_picture)

@rpc("call_local", "any_peer", "reliable")
func target_delete_id_commercial_picture(id_server_picture):
	if id_server_picture:
		var picture_datas = g_man.savable_multi_client__server_pictures.get_all(0, id_server_picture)
		if picture_datas:
			picture_datas[0]._texture2d = null
			picture_datas[0].save_picture(null)
			print("exists")
		g_man.savable_multi_client__server_pictures.delete_p_s(0, id_server_picture)
				#endregion get picture
			#endregion end picture
			#region set pay and pay comercials

@rpc("call_local", "any_peer", "reliable")
func cmd_set_pay_commercial(money):
	var node = intro()
	if node:
		var corg:Company = Company.try_get_server_corg(node.client.id)
		if corg:
			# 10 carrots is minimum
			var minimum = MoneyCurrency.convert_money(10, MoneyCurrency.plant.carrot)
			if money < minimum:
				money = minimum
			push_error("company is now paying ", money)
			corg.comercialist_pay = money
			corg.save_commercials_pay()
			target_refresh_commercial_pay.rpc_id(node.id_net, money)

@rpc("call_local", "any_peer", "reliable")
func target_refresh_commercial_pay(money):
	g_man.corg.update_add_pay(money)

@rpc("call_local", "any_peer", "reliable")
func cmd_get_reward_commercial(id_picture):
	var node = intro()
	if node:
		if id_picture:
			var id_corgs = g_man.savable_multi_corg__pictures.select(0, id_picture)
			if id_corgs:
				var corgs = g_man.savable_multi_account__corg.get_all(0, id_corgs[0])
				if corgs:
					if not corgs[0].outcome_comercial(node.client.id):
						g_man.savable_multi_corg__pictures.delete_p_s(corgs[0].id, 0)
					else:
						print("rewarded:", corgs[0].comercialist_pay)
						push_error("rewarded:", corgs[0].comercialist_pay)
				else:
					push_error("corg does not exist: ", id_corgs[0])
			# picture does not exist
			else:
				g_man.savable_multi_corg__pictures.delete_p_s(0, id_picture)
				target_delete_id_commercial_picture.rpc_id(node.id_net, id_picture)
			
			#endregion end set pay and pay comercials
			#region commercials time
@rpc("call_local", "any_peer", "reliable")
func cmd_set_corg_commercial_time(time):
	var node = intro()
	if node:
		var corg:Company = Company.try_get_server_corg(node.client.id)
		if corg:
			time = int(time)
			corg.comercialist_company_add_wait = time
			corg.save_commercials_time()
			target_refresh_corg_commercial_time.rpc_id(node.id_net, time)

@rpc("call_local", "any_peer", "reliable")
func target_refresh_corg_commercial_time(time):
	g_man.corg.update_add_time(time)

			#endregion commercials time
		#endregion end comercials
	#endregion end marketplace
