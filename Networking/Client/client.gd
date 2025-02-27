class_name Client extends ISavable

func copy() -> Client:
	return Client.new()
	
var secure_connection = false
var _username
var _password
var id_server: int
var id_net



#region inputs
	#region
const BECOME_MODERATOR := 3
#[NonSerialized] public Savable<ContainerUserLevel> container_user_levels
var send_picture

## not saved as it's setting when loading
var id_mod_verified = 0
	#endregion
	#region server
## for client which usernames allready exists
#var clientUserNames = {} ## string, long
	#endregion
	#region fingerprint
var Fraud := false
var came_in_with_other_computer		= false
var other_client_can_get_in			= true
var other_computers_can_get_in		= true
	#endregion end fingerprint
	#region PersonData
var honor = 0

var referrer = 0
var time_of_employed
var start_working

var money_system = MoneySystem.new()
##1 pineapple - 1000000000
var reputation := 0
var email := ""
var emailConfirmation := true
## email password change buffer
var rawEmailConfirmationReference := 0
var changePass := ""
var changeEmail := ""
var changeConfirmation := true
	#endregion
	#region macs
var removal := false
var removalYear := 5000
var removalMonth := 12
var removalBought := 0
var idFingerPrintSession
var notVerified = {} # <long, string>
var itsUnwelcomedGuestInside := false
	#endregion end macs
	#region id
		#region status
## moderator level 0 is not verified at all
## 1 is banished life ban
## 2 is just accepted person
## 3 and above is moderator
## 255 is admin
var user_level = 0
const ADMIN_USER_LEVEL: int = 255

var buffering_user_level

## 0 not verified at all
## 1 maybe pending verification
## 2 level verified corg
var verified_corg = 0

## if it is in corg or not
var corg_verified_person = false
		#endregion status
	#endregion
#endregion end imputs
#region fingerPrint
func make_fraud():
		Fraud = true
		#SaveFraud()
		# always becomes lesser moderator and life ban to become moderator
		user_level = 1
		save_user_level()
		add_save_honor(-5000 - honor)
		
func func_other_computers_can_get_in(idMacss):
	# false if newly created client
	# false => throw out
	if len(idMacss) == 0:
		return false
	return true

func register_mac(mac):
	came_in_with_other_computer = false
	#index all mac
	for item in mac:
		Mac.get_or_create(item)
	var m:Mac = Mac.get_or_create(mac[0])
	# get all mac unser one macs
	var macs:Macs = Macs.get_index_data(m.id_macs)
	macs.set_data(mac)
	for item in mac:
		var ma = Mac.get_or_create(item)
		var approved = g_man.savable_multi_server_client__mac.new_data(id, ma.id)
		approved.approved = UnwelcomeMac.approving.APPROVED
		approved.id_mac = ma.id
		approved.fully_save()
	g_man.multi_server_client__macs.add_row(0, id, m.id_macs)
	
func try_log_in(mac):
	load_security_protocol()
	came_in_with_other_computer = false
	var idRowsMacs = g_man.multi_server_client__macs.select_oposite_ids(id, 0)
	var idMacss = idRowsMacs
	
	var unwelcome = false
	var addNewMacs = false
	var oneCorrectMac = false
	var totallyWrongOne = false
	var correct_macs_id
	
	for t in mac:
		var m:Mac = Mac.get_or_create(t)
		
		#if other clients can't get in we fetch it here
		if !other_client_can_get_in:
			var other_persons = g_man.multi_server_client__macs.select(0, m.id_macs)
			for id_other in other_persons:
				if id_other != id:
					var other = g_man.savable_server_accounts.get_index_data(id_other)
					push_warning(String("person {p} cannot get in to {u}").format({p = other._username, u = _username}))
					return false
		# permanent id always throw out through the window
		var unwel:UnwelcomeMac = g_man.savable_multi_server_client__mac.new_data(id, m.id)
		if not unwel.id_mac:
			unwel.id_mac = m.id
			unwel.approved = UnwelcomeMac.approving.PENDING
			unwel.fully_save()
		if unwel.approved == UnwelcomeMac.approving.BANNED:
			push_warning("permanent wrong MAC:", m._str_mac)
			unwelcome = true
			totallyWrongOne = true
			continue
		# if it was approved
		elif unwel.approved == UnwelcomeMac.approving.APPROVED:
			oneCorrectMac = true
			correct_macs_id = m.id_macs
		elif unwel.approved == UnwelcomeMac.approving.PENDING:
			came_in_with_other_computer = true
		
		#permanent hacker
		var permanent:PermanentUnwelcomeMac = g_man.savable_permanent_unwelcome_mac.get_index_data(m.id)
		if permanent:
			if permanent.hacker:
				unwelcome = true
				totallyWrongOne = true
				continue
		push_warning(m.id, " : ", m._str_mac)
		#other client idMacs
		var other_clients_macs = g_man.multi_server_client__macs.select(0, m.id_macs)
		for other_client in other_clients_macs:
			#var other_macs = g_man.multi_server_client__macs.select_oposite_ids(other_client, 0)
			if not idMacss:
				idMacss.push_back(m.id_macs)
		if ! addNewMacs && unwelcome && !oneCorrectMac || totallyWrongOne:
			push_error("unwelcome false log in")
			return false
		if oneCorrectMac:
			var macs:Macs = Macs.get_index_data(correct_macs_id)
			# we set all mac under same macs
			macs.set_data(mac)
			came_in_with_other_computer = false
		
		# if unwelcome
		else:# we set all mac under same mac
			var macs:Macs =  Macs.get_index_from_string(mac[0])
			macs.set_data(mac)
			
	return ! unwelcome || oneCorrectMac

#endregion end fingerprint
#region clientConstructor
static func construct_for_client_new_id(_id_server, _name):
	var id_client = g_man.multi_client__server_client.select(0, _id_server)
	var new_client = null
	if not id_client:
		new_client = set_new_client(_id_server, _name)
	else:
		new_client = g_man.savable_client_client.get_index_data(id_client[0])
		if not new_client:
			new_client = set_new_client(_id_server, _name)
	g_man.multi_client__server_client.add_row(0, new_client.id, _id_server)
	new_client.set_server_id(false, _id_server, _name)
	return new_client

## make client on local database
static func set_new_client(_id_server, _name):
	var new_client = Client.new()
	new_client._username = _name
	g_man.savable_client_client.set_data(new_client)
	return new_client

## don't think I need this one, ...
func set_server_id(param_server: bool, _id_server: int, _name):
	_server = param_server
	if param_server:
		id = _id_server
	else:
		id_server = _id_server
		var row = g_man.multi_client__server_client.select_oposite_ids(0, _id_server)
		if row:
			id = row[0]
		else:
			push_error("client id does not exist for server id: ", _id_server, " ", _name)
#endregion

#region picture/EMŠO
func set_picture_raw_datas(raw_face_picture_data, raw_id_picture_data, set_emso):
	push_warning("verified corg:", verified_corg)
	var array = load_return_raw_picture_data()
	if verified_corg > 0 && array[0]:
		return
	if not raw_id_picture_data || not raw_face_picture_data:
		return
	var emso = load_return_emso()
	#if emšo is bigger than 8 don't add it
	if emso && len(emso) > 8 && array[0]:
		return
	
	g_man.multi_server_client__not_verified_picture.add_row(0, id, 3)
	change_verified_corg(2)
	if save_raw_picture_datas(raw_face_picture_data, raw_id_picture_data):
		save_emso(set_emso)
		send_picture = true
		save_send_picture()
		return true
	return false
#endregion piture/EMŠO
#region verification
## EMŠO		Mod has written
## idClient	# id EMŠO has been written to
## idMod	# id wrote EMŠO
## emso		# EMŠO
static func add_mod(id_client, id_mod, emso):
	var mod_verified = g_man.savable_multi_client__id_mod_verified.new_data(id_client, 0)
	mod_verified.emso = emso
	mod_verified.id_mod = id_mod

## remove mods, reward or demote all mods if correctly changed
static func RemoveAllMods(idClient):
	var wrong_count = 0
	if not idClient:
		push_error("client is null!!!")
		return
	
	var client:Client = g_man.savable_server_accounts.get_index_data(idClient)
	var emso = client.load_return_emso()
	var mods_verified = g_man.savable_multi_client__id_mod_verified.get_all(idClient, 0)
	for mod_verified:ModVerified in mods_verified:
		
		var mod:Client = g_man.savable_server_accounts.get_index_data(mod_verified.id_mod)
		if mod:
			# get less honour for each wrongly made EMŠO
			if emso != mod_verified.emso:
				mod.add_save_honor(-10)
			else:
				mod.add_save_honor(1)
		# delete references
		g_man.savable_multi_client__id_mod_verified.delete_id_row(mod_verified.id)
	push_warning("wrong count is: ", wrong_count, " client name: ", client._username, " id: ", client.id, " how many mods have written EMŠO wrongly")




func reset_ems(moderator_level, total_reset:bool):
	if moderator_level == 3:
		push_error("total reset too close down")
		total_reset = true
	# reset
	if total_reset:
		push_warning("total reset")
		save_raw_picture_datas([], [])
		send_picture = false
		save_send_picture()
		## TODO HERE NEEDS TO BE DONE
		push_error("TO DO LIST if person has added correct EMŠO this EMŠO is not valid for anyone else EXCEPT if new EMŠO has been approved")
		# total_reset
		save_emso("resetP")
		# it does not have a option to be moderator yet till next moderator approve
		save_change_user_level(0)
		# we lost a verified person
		# only once IF it was set as true
		if corg_verified_person:
			g_man.stat_total_persons_on_corg_count -= 1
		corg_verified_person = false
		save_corg_verified_person()
		save_emso("resetP")
	var new_level = moderator_level
	#//to remove before mod level
	new_level -= 1
	if (moderator_level > BECOME_MODERATOR):
		var idRow = g_man.multi_server_client__not_verified_picture.select(id, 0)
		if idRow:
			# add 1 level less which mod is on turn
			if new_level > BECOME_MODERATOR && !total_reset:
				g_man.multi_server_client__not_verified_picture.add_row(0, id, new_level)
			#//delete which mod level was on turn
			g_man.multi_server_client__not_verified_picture.delete(id, moderator_level)
	# //var x = HalfSin.MultiPersonNotVerifiedid_picture.Select(id, 0)
	#//to set new mod level check
	new_level -= 1
	# total reset resets it to 0
	if total_reset:
		new_level = 0
	if Fraud:
		new_level = 1
	change_verified_corg(new_level)

func change_emso(moderatorLevel, idMod, emso):
	# if picture don't exist don't make EMSO anything
	var raw_pic = load_return_raw_picture_data()
	if not raw_pic[0]:
		push_error("should never come to this picture doesn't exist yet id", id)
		for item in g_man.multi_server_client__not_verified_picture.Select(id, 0):
			push_error(item)
		return
	# if it's verified don't change it again except if it's reset
	if verified_corg + 1 != moderatorLevel:
		push_error("moderator ", moderatorLevel, " level cannot change: verified by level ", verified_corg)
		return
	
	g_man.dict_emso__id.erase(emso)
	save_emso(emso)
	# client verified to CORG
	if len(emso) > 8:
		push_warning("verified")
		change_verified_corg(moderatorLevel)#//(byte)(moderatorLevel - 1)
		g_man.dict_emso__id[emso] = id
		g_man.dict_id__emso[id] = emso
		g_man.multi_server_client__not_verified_picture.delete(id, moderatorLevel)
		g_man.multi_server_client__not_verified_picture.add_row(0, id, moderatorLevel + 1)
		add_basic_user_level(moderatorLevel)
		save_mod_verified(idMod, emso)
	# should never come to this
	else: # if it's lower than 9 length recheck it
		push_error("should never come to this")
		# if picture doesn't exist remove person
		if not raw_pic[0]:
			push_error("remove person from CORG")
			g_man.multi_server_client__not_verified_picture.delete(id, verified_corg)
			g_man.multi_server_client__not_verified_picture.delete(id, moderatorLevel)
			return
		push_error("check it")
		g_man.dict_id__emso.erase(id)
		g_man.multi_server_client__not_verified_picture.delete(id, moderatorLevel)
		g_man.multi_server_client__not_verified_picture.add_row(0, id, 1)
	save_emso(emso)

#}TODO:
	#/// <summary>
	#/// could be good emso
	#/// </summary>
	#/// <param name="emso"></param>
#func EmsToRepair(emso):
	#EmsRepair = emso
	#
	#DataBase.Insert
	  #(true, NetMan.DbMs, DataBase.path.Person, DataBase.fileName.EMSORepair, id,
		  #emso, DataBase.Operating.overwrite
	  #)
#}
#endregion verification
#region honor & mod verification
func add_basic_user_level(moderatorLevel):
	# last in chain tells if he is really the correct person to get inside to CORG
	if moderatorLevel > g_man.last_in_chain_user_level-2:
		# only once IF it wasn't verified yet
		if not corg_verified_person:
			g_man.stat_total_persons_on_corg_count += 1
			corg_verified_person = true
			save_corg_verified_person()
	if moderatorLevel == 3 && user_level == 0:
		# normal user
		user_level = 2
		# is a must to change even if too many in the buffer
		save_user_level()
		add_save_honor(1000)
	elif moderatorLevel == 4 && user_level == 2 && honor > 999:
		# basic moderator
		add_save_honor(1001)
#endregion honor & mod verification
#region unwelcomed
	#
	#///<summary>serverOnly</summary>
	#public void AddUnwelcomed(long idFP){
		#HalfSin.multiFingerPrintUnwelcomedAtHost.AddRow(1, idFP, id)
		#//DictionaryTool.Add(notVerified, idFP, FingerPrint.Get(idFP))
	#}
	#///<summary>serverOnly</summary>
	#public void RemoveUnwelcomed(long idFP){
		#//Debug.LogError(id)
		#//Debug.LogError(halfsin.multiFingerPrintUnwelcomedAtHost.Delete(idFP, id))
		#DictionaryTool.Remove(notVerified, idFP)
	#}
	#
#endregion end unwelcomed
#region session
#
	#
	#public bool Session(long[] idFPs){
		#/*
		#Debug.Log("Session unwelcomed guest")
		#bool potentialUnwelcomed = false
		#long[] idPersons = FingerPrint.GetIdPersons(idFPs[0])
		#//if none has been inside we add one and register all his FP
		#if(FingerPrint.GetIdFingerPrints(id).Length == 0){
			#//Debug.Log("Add finger prints")
			#AddWelcomedFingerPrint(idFPs)
			#//Debug.Log($"Session host: {id}  guest: {idPersons.Length}  fingerPrint: {idFPs[0]}")
			#return true
		#}
		#Debug.LogError($"Session {idPersons.Length}")
		#foreach (long idPersonFP in idPersons){
			#//Debug.Log($"Session host: {id}  unwelcomed guest: {idPersonFP} fingerPrint: {idFPs[0]}")
			#if(idPersonFP == id){
				#idFingerPrintSession = idFPs[0]
				#itsUnwelcomedGuestInside = false
				#return true
				#//potentialUnwelcomed = false
			#}
		#}
		#Debug.LogError("TESTING")
		#//if person is up to 4 it's debugging person and is allowed to plant mine and do all stuff
		#if(id < 5){itsUnwelcomedGuestInside = false return true}
#
		#itsUnwelcomedGuestInside = true
		#foreach (long idFP in idFPs){
			#AddUnwelcomed(idFP)
		#}
		#idFingerPrintSession = idFPs[0]
#
		#Debug.LogError(! potentialUnwelcomed)
		#
		#return ! potentialUnwelcomed
		#*/
		#return false
	#}
	#
		##region fingerprint
	#/*
	#public void AddWelcomedFingerPrint(long[] idFPs){
		#foreach (long idFP in idFPs){
			#FingerPrint.RemoveFromBlindSpot(idFP, id)
		#}
	#}
	#*/
		##endregion end fingerprint
#endregion end session
#region macs
func CheckCORGForRemoval(idCORG):
	push_error("check Corg for removal")
	#// Person CORG = GetHalfSin(Time.time).SavablePersons.Get1(idCORG)
	#// if(idCORG == id){
	#//     //Debug.Log("it's same person")
	#//     return false
	#// }
	#// if(CORG.removal || removal){
	#//     return true
	#// }
	#// //we get dominant fingerprint
	#// long[] idFPs = FingerPrint.GetIdFingerPrints(id)
	#// long[] idFPCORGs = FingerPrint.GetIdFingerPrints(idCORG)
	#// FingerPrint fp = FingerPrint.Get(idFPs[0])
	#// FingerPrint fpCORG = FingerPrint.Get(idFPCORGs[0])
	#// if(fp == null || fpCORG == null){
	#//     Debug.LogError("should never be")
	#//     return true
	#// }
	#// long[] ids = FingerPrint.GetIdPersons(idFPs[0])
	#// long[] idCORGs = FingerPrint.GetIdPersons(idFPCORGs[0])
	#// if(ids.Length == 0 || idCORGs.Length == 0){
	#//     Debug.LogError($"{ids.Length}, {idCORGs.Length} no macs loaded yet why not?")
	#//     return true
	#// }
	#// //check if it's for removal
	#// foreach (long idp in ids){
	#//     foreach (long idc in idCORGs){
	#//         Debug.LogError($"NEED TO UNCOMMENT THIS is it plant miner {idc} {idp}")
	#//         if(idp == idc){
	#//             Debug.Log($"it is plant miner")
	#//             SetForRemoval()
	#//             CORG.SetForRemoval()
	#//             return true
	#//         }
	#//     }
	#// }
	#// //all good it can sell and buy
	return false

	#public void SetForRemoval(){
		#removal = true
		#SaveRemovalDate()
	#}
	#
	#
func IsRemoval(money, seller):
	if ! CheckCORGForRemoval(seller):
		return 0
	
		#if(Timer.PastMonth(removalYear, removalMonth, 1)){
			#Debug.LogError($"{userName} set for removal within time")
			#money_system.EmptyAllInUTD()
			#if(g_man.SavableCorg.TryGet(employed_at, out var corg)){
				#corg.EmptyAllInUTD()
			#}
			#return 2
		#}
		#else if(removalBought > (long)MoneyCurrency.plant.pineapple){
			#Debug.LogError($"{userName} set for removal too much bought")
			#money_system.EmptyAllInUTD()
			#if(g_man.SavableCorg.TryGet(employed_at, out var corg)){
				#corg.EmptyAllInUTD()
			#}
			#return 2
		#}
		#else if(removal){
			#Debug.LogError($"{userName} set for removal watching 1 month")
			#removalBought += money
			#return 1
		#}
		#return 0
	#}
	#
	#public void MaybeSetOffRemoval(){
		#var time = removalYear*365+removalMonth*30
		#//how many months he needs to wait to restart earning plants
		#byte additionalMonths = 2
		#if(time < DateTime.Now.Year*365+(DateTime.Now.Month + additionalMonths)*30){
			#removalYear = 5000
			#removalMonth = 12
		#}
		#Debug.Log($"maybe wear off {removalYear} {removalMonth}")
	#}
	#
#endregion end macs
#region employment
func fire_me(server):
	if server:
		var employed_at = g_man.multi_server_worker__corg.select(id, 0)
		if not employed_at || employed_at[0] == 0:
			g_man.multi_server_worker__corg.delete(0, id)
			if g_man.connected_node_ids.has(id_net):
				g_man.local_server_network_node.net_corg_node.target_update_worker.rpc_id(id_net, id, 0, 0, _username, 0, load_return_biography())
		var corg:Company = Company.try_get_server_corg(id, false)
		if corg:
			#remove sole proprietor
			if Company.try_get_server_corg(id, true):
				push_error("remove sole proprietor ", id)
				# we fetch all workers
				g_man.savable_multi_account__corg.delete_p_s(id, corg.id)
				var id_workers = g_man.multi_server_worker__corg.select(0, corg.id)
				g_man.multi_server_worker__corg.delete(0, corg.id)
				g_man.multi_server_corg__applied.delete(corg.id, 0)
				# we delete all workers
				for id_worker in id_workers:
					var worker:Client = g_man.savable_server_accounts.get_index_data(id_worker)
					if g_man.connected_node_ids.has(worker.id_net):
						g_man.local_server_network_node.net_corg_node.target_update_worker.rpc_id(worker.id_net, worker.id, 0, 0, worker._username, 0, worker.load_return_biography())
			# remove worker
			else:
				g_man.multi_server_worker__corg.delete(id, corg.id)
				if g_man.connected_node_ids.has(id_net):
					g_man.local_server_network_node.net_corg_node.target_update_worker.rpc_id(id_net, id, 0, 0, _username, 0, load_return_biography())
				var id_employer = g_man.savable_multi_account__corg.select(0, corg.id)
				var employer:Client = g_man.savable_server_accounts.get_index_data(id_employer)
				if g_man.connected_node_ids.has(employer.id_net):
					g_man.local_server_network_node.net_corg_node.target_update_worker.rpc_id(employer.id_net, id, 0, 0, _username, 0, load_return_biography())
		# something went wrong let's fire him self
		else:
			g_man.savable_multi_account__corg.delete_p_s(id, 0)
			g_man.multi_server_worker__corg.delete(id, 0)
	# client
	else:
		push_error("client fired")
		save_employed_at(0)
		save_employed_at_corg(0)

## id_corg needs to be sure it exists
func employ_me(id_corg, salary):
	if g_man.savable_multi_account__corg.get_all(0, id_corg):
		if not g_man.multi_server_worker__corg.select(id, 0):
			g_man.multi_server_worker__corg.add_row(0, id, id_corg)
			save_salary(salary)

func can_i_be_employed(id_employer_corg):
	var employed_at = g_man.multi_server_worker__corg.select(id, 0)
	if employed_at:
		push_warning("I'm already employed at: ", employed_at)
		return false
	# self employed
	var corg = g_man.savable_multi_account__corg.get_all(id, id_employer_corg)
	if corg:
		var temp = 5 # (DateTime.Now - time_of_employed).TotalDays
		push_error(temp)
		if temp > 0:
			push_warning("I can be employed")
			return true
		elif IsRemoval(0, id_employer_corg) == 2:
			push_error("can't have same employee")
			return false
		elif IsRemoval(0, id_employer_corg) == 1:
			push_error(_username, " we will be watching you")
			
	if not employed_at:
		var temp = 5 # //(DateTime.Now - time_of_employed).TotalDays
		push_warning(temp)
		if temp > 0:
			push_warning("I can be employed")
			return true

## 'm I self employed
func self_employed():
	if g_man.savable_multi_account__corg.select(id, 0):
		return true
	return false

#endregion end employment
#region money
func get_money():
	return money_system.get_money()

func set_money(money):
	money_system.set_money(money)

func enough_money(totalCost):
	var corg = Company.try_get_server_corg(id)
	var corg_money = 0
	if corg:
		corg_money = corg.get_money()
	# either client or his company has enough money
	if get_money() >= totalCost || corg_money >= totalCost:
		return true

##buyer
func outcome_buying(money, id_trader, id_item, quantity):
	var corgs = g_man.savable_multi_account__corg.get_all(0, id_trader)
	if corgs:
		var ref_money = money_system.outcome(money * quantity, true)
		if ref_money:
			save_money()
			var corg_id = 0
			## my company if it exists so that it knows whom to calculate the reserved on corg
			var corg = Company.try_get_server_corg(id)
			if corg:
				corg_id = corg.id
			corgs[0].income(ref_money, id_item, corg_id, quantity)
			return true
## pure outcome for game or UTD</summary>
## TODO: percentUTD: how much it'll go in to UTD
## returns: if it has enough money true
func outcome(money, _percent_utd):
	if money_system.outcome(money, true):
		save_money()
		return true

## salary, comercials only
func income(money):
	money_system.income(money)
	save_money()

func corg_daily_income(to_pay):
	var corgs = g_man.multi_server_worker__corg.select(id, 0)
	if corgs:
		corgs[0].add_to_profit_cap(to_pay)
#endregion end money
#region startStopWorking
# server call only
func start_stop_working(start:bool):
	var employed_at
	var employed_at_corgs = g_man.multi_server_worker__corg.select(id, 0)
	if employed_at_corgs:
		var corgs = g_man.savable_multi_account__corg.get_all(0, employed_at_corgs[0])
		if corgs:
			employed_at = corgs[0].id
	if employed_at:
		var working = load_return_working()
		if start:
			# if we are working or resting our status doesn't change
			# minimum 10 hours must be as sleep
			if working || not g_man.savable_server_client_work_time.end_of_hours(id, 10):
				g_man.local_server_network_node.net_corg_node.target_update_job_status.rpc_id(id_net, working, g_man.savable_server_client_work_time.load_from_last_save_elapsed(id))
				# he is already working
				return
			push_warning("working now")
			working = true
			g_man.savable_server_client_work_time.save_time_now(id)
			start_working = Time.get_unix_time_from_system()
		elif working:
			push_warning("finished work for today")
			get_me_payed()
			working = false
		save_working(working)
		push_warning("currently is working: ", working)
		g_man.local_server_network_node.net_corg_node.target_update_job_status.rpc_id(id_net, working, g_man.savable_server_client_work_time.load_from_last_save_elapsed(id))
	# he needs to be resting at least for 10 hours after he finishes the job
func resting():
	var resting_time = Time.get_unix_time_from_system() - start_working
	if resting_time < 36000:
		push_warning("still resting", float(resting_time) / 3600, "hours")
		return true
	push_warning("was resting for", float(resting_time) / 3600, "hours")
	return false

func get_me_payed():
	var corgs = g_man.savable_multi_account__corg.get_all(id, 0)
	if not corgs:
		push_error("employed at does not exist", id)
		return
	else:
		var _working_time = working_time()
		# max working is 12 hours
		if _working_time > 3600*12:
			_working_time = 3600*12
		var to_pay = float(_working_time)/3600 * load_return_salary()
		push_warning(load_return_salary(), " at: ", _username, " : ", id, " I need to be payed: ", to_pay)
		# we subtract the starter money until it's 0
		var starter_money = load_return_starter_money()
		if starter_money && starter_money > 0:
			var keep_starter = to_pay - starter_money
			push_warning("keep starter: ", keep_starter)
			# we still have some starter money left
			if keep_starter < 0:
				keep_starter *= -1
				starter_money = keep_starter
				push_error("starter money: ", starter_money, " & ", keep_starter)
				save_starter_money(starter_money)
				push_error("to pay: ", to_pay)
				income(to_pay)
				corg_daily_income(to_pay)
				return
			# we need to pay the rest
			else:
				push_warning(to_pay, " : ", keep_starter, " : ", starter_money)
				to_pay = keep_starter
				starter_money = 0
				save_starter_money(starter_money)
		# we are paying rest
		push_warning("finally pay me: ", to_pay)
		
		push_error(to_pay, " salary: ", load_return_salary())
		corgs[0].pay_salary(to_pay, id)
		corg_daily_income(to_pay)
	
func working_time():
	var sum = g_man.savable_server_client_work_time.load_from_last_save_elapsed(id)
	return sum
#endregion end startStopWorking
#region buffer
#
func release_from_buffer():
	# if it's first time in here let him through
	if buffering_user_level == user_level && user_level != 2:
		return
	# just set the array if it doesn't exists yet
	if not g_man.container_user_levels.get_index_data(user_level):
		g_man.container_user_levels.set_index_data(user_level, ContainerUserLevel.new(), 2)
	# last in chain controls the bit where all verifications ends -2
	if g_man.last_in_chain_user_level < buffering_user_level:
		if buffering_user_level < 3:
			g_man.last_in_chain_user_level = 3
		else:
			g_man.last_in_chain_user_level = buffering_user_level
		g_man.save_last_in_chain_user_level()
			
	var contUserLevel:ContainerUserLevel = g_man.container_user_levels.get_index_data(user_level)
	#//downgrade // upgrade
	#always down grade no matter the buffer	||	# upgrade only if before has enough users to not leave the gap
	if buffering_user_level < user_level || contUserLevel.count -1 > g_man.count_per_container_corg_accounts:
		## user_level	= 3 // 2
		## buffer		= 2 // 3
		var x = g_man.container_user_levels.get_index_data(user_level)
		x.count -= 1
		x.fully_save()
		var bufferContainer:ContainerUserLevel = g_man.container_user_levels.get_index_data(buffering_user_level)
		if not bufferContainer:
			bufferContainer = ContainerUserLevel.new()
			g_man.container_user_levels.set_index_data(buffering_user_level, bufferContainer, 0)
		bufferContainer.count += 1
		bufferContainer.fully_save()
		user_level = buffering_user_level
		save_user_level()
	elif buffering_user_level == 2:
		var containerUserLevel:ContainerUserLevel = g_man.container_user_levels.get_index_data(buffering_user_level)
		containerUserLevel.count += 1
		containerUserLevel.fully_save()
		user_level = buffering_user_level
		save_user_level()

	#/// <summary>
	#/// warning it's used for RegisterLoginManager users to fix where they belong
	#/// </summary>
	#/// <param name="bufferJumpsTo">where is moderator located</param>
	#public void ForceBufferUserLevel(byte bufferJumpsTo)
	#{
		#var contUserLevel = g_man.container_user_levels.Get(user_level)
		#contUserLevel.Count--
		#var bufferLevels = g_man.container_user_levels.Get(bufferJumpsTo)
		#if (bufferLevels == null)
		#{
			#bufferLevels = new ContainerUserLevel()
			#g_man.container_user_levels.Set(bufferJumpsTo, bufferLevels, 2)
		#}
		#bufferLevels.Count++
		#user_level = bufferJumpsTo
		#save_user_level()
	#}
#endregion buffer






#region savable
	#region fully
func fully_save():
	save_username()

func partly_load():
	_username = DataBase.select(_server, g_man.dbms, _path, "username", id)

func fully_load():
	load_username()
	load_money()
	if _server:
		load_verified_corg()
		load_send_picture()
		load_user_level()
		load_honor()
		load_buffering_user_level()
		load_corg_verified_person()
	#endregion fully
	#region save
	#server
func save_password():
	DataBase.insert(_server, g_man.dbms, _path, "password", id, _password)

func save_username():
	DataBase.insert(_server, g_man.dbms, _path, "username", id, _username)
	
func save_secret_key(key):
	DataBase.insert(_server, g_man.dbms, _path, "secret", id, key)

func save_security_protocol():
	DataBase.insert(_server, g_man.dbms, _path, "client_can_get_in", id, other_client_can_get_in)
	DataBase.insert(_server, g_man.dbms, _path, "comput_can_get_in", id, other_computers_can_get_in)

func save_sudo(sudo):
	DataBase.insert(_server, g_man.dbms, _path, "sudo", id, sudo)

func save_send_picture():
	DataBase.insert(_server, g_man.dbms, _path, "send_picture", id, send_picture)

func save_raw_picture_datas(raw_face, raw_id):
	var length = DataBase.get_length(_server, g_man.dbms, _path, "face_picture")
	if length >= len(raw_face):
		length = DataBase.get_length(_server, g_man.dbms, _path, "id_picture")
		if length >= len(raw_id):
			DataBase.insert(_server, g_man.dbms, _path, "face_picture", id, raw_face)
			DataBase.insert(_server, g_man.dbms, _path, "id_picture", id, raw_id)
			return true
	return false

func save_emso(emso):
	DataBase.insert(_server, g_man.dbms, _path, "emso", id, emso)

func save_emso_repair(emso):
	DataBase.insert(_server, g_man.dbms, _path, "emso_repair", id, emso)

func save_emso_starter(emso):
	DataBase.insert(_server, g_man.dbms, _path, "emso_starter", id, emso)

func change_verified_corg(level):
	verified_corg = level
	DataBase.insert(_server, g_man.dbms, _path, "verify_corg", id, verified_corg)

func save_verified_corg():
	DataBase.insert(_server, g_man.dbms, _path, "verify_corg", id, verified_corg)

func save_corg_verified_person():
	DataBase.insert(_server, g_man.dbms, _path, "corg_verified_person", id, corg_verified_person)

func save_user_level():
	DataBase.insert(_server, g_man.dbms, _path, "user_level", id, user_level)
	
func save_buffering_user_level():
	DataBase.insert(_server, g_man.dbms, _path, "buffer", id, buffering_user_level)

func save_mod_verified(id_mod, emso):
	push_warning("id verified mod now ", id_mod, "before: ", id_mod_verified)
	id_mod_verified = id_mod
	var mod_verified:ModVerified = g_man.savable_multi_client__id_mod_verified.new_data(id, id_mod)
	mod_verified.emso = emso
	mod_verified.id_mod = id_mod
	mod_verified.fully_save()
	#DataBase.insert(_server, g_man.dbms, _path, "mod_verified", id, id_mod)
	
func add_save_honor(add_honor):
	# honor
	push_warning("id verified by mod: ", id_mod_verified)
	honor += add_honor
	save_honor()
	# reset mod level
	if user_level < 2 || user_level == ADMIN_USER_LEVEL:
		return
	# base on honor mod level is changed
	if honor > 999:
		var temp = honor * 0.001
		if honor > 254000:
			save_change_user_level(254)
		else:
			temp += 1
			save_change_user_level(int(temp))
		return
	
	# if honor level is below 1000 it cannot get over user_level 1 any longer
	push_warning("reset user level -> id: ", id, "username: ", _username)
	user_level = 1
	save_user_level()

func save_honor():
	DataBase.insert(_server, g_man.dbms, _path, "honor", id, int(honor))

func save_money():
	DataBase.insert(_server, g_man.dbms, _path, "money", id, int(money_system.get_money()))

func save_referrer():
	DataBase.insert(_server, g_man.dbms, _path, "referrer", id, referrer)

func save_starter_money(starter_money):
	DataBase.insert(_server, g_man.dbms, _path, "person_starter_money", id, starter_money)

func save_employed_at(server_employed_at):
	DataBase.insert(_server, g_man.dbms, _path, "employed_at", id, server_employed_at)

func save_employed_at_corg(server_employed_at_corg):
	DataBase.insert(_server, g_man.dbms, _path, "employed_at_corg", id, server_employed_at_corg)

func save_salary(salary):
	DataBase.insert(_server, g_man.dbms, _path, "salary", id, salary)

func save_biography(biography):
	DataBase.insert(_server, g_man.dbms, _path, "biography", id, biography)

func save_working(working):
	DataBase.insert(_server, g_man.dbms, _path, "working", id, working)

func save_commercials_wait(time):
	DataBase.insert(_server, g_man.dbms, _path, "save_commercials_wait", id, time)

func save_id_active_law_suggested(id_law):
	DataBase.insert(_server, g_man.dbms, _path, "id_active_law_suggested", id, id_law)

func save_spender(id_spender):
	DataBase.insert(_server, g_man.dbms, _path, "id_spender", id, id_spender)

func save_moderator_variables():
	save_password()
	save_username()
	save_verified_corg()
	save_corg_verified_person()
	save_user_level()
	save_honor()
	g_man.server_usernames[_username] = id
	save_sudo(true)

	#endregion save
	#region load
func load_return_password():
	return DataBase.select(_server, g_man.dbms, _path, "password", id)

func load_return_secret():
	return DataBase.select(_server, g_man.dbms, _path, "secret", id)

func load_username():
	_username = DataBase.select(_server, g_man.dbms, _path, "username", id)

func load_security_protocol():
	other_client_can_get_in = DataBase.select(_server, g_man.dbms, _path, "client_can_get_in", id)
	other_computers_can_get_in = DataBase.select(_server, g_man.dbms, _path, "comput_can_get_in", id)
	if other_client_can_get_in == null:
		other_client_can_get_in = true
	if other_computers_can_get_in == null:
		other_computers_can_get_in = true

func load_return_sudo():
	return DataBase.select(_server, g_man.dbms, _path, "sudo", id)

func load_send_picture():
	send_picture = DataBase.select(_server, g_man.dbms, _path, "send_picture", id)

func load_return_raw_picture_data():
	var raw_face = DataBase.select(_server, g_man.dbms, _path, "face_picture", id)
	var raw_id = DataBase.select(_server, g_man.dbms, _path, "id_picture", id)
	return [raw_face, raw_id]

func load_return_emso():
	return DataBase.select(_server, g_man.dbms, _path, "emso", id)

func load_return_emso_repair():
	return DataBase.select(_server, g_man.dbms, _path, "emso_repair", id)

func load_return_emso_starter():
	return DataBase.select(_server, g_man.dbms, _path, "emso_starter", id)

func load_corg_verified_person():
	corg_verified_person = DataBase.select(_server, g_man.dbms, _path, "corg_verified_person", id, false)

func load_verified_corg():
	verified_corg = DataBase.select(_server, g_man.dbms, _path, "verify_corg", id)
	if not verified_corg:
		verified_corg = 0

func load_user_level():
	user_level = DataBase.select(_server, g_man.dbms, _path, "user_level", id)
	if not user_level:
		user_level = 0
		
func load_buffering_user_level():
	buffering_user_level = DataBase.select(_server, g_man.dbms, _path, "buffer", id)
	if not buffering_user_level:
		buffering_user_level = 2

#func load_mod_verified():
	#id_mod_verified = DataBase.select(_server, g_man.dbms, _path, "mod_verified", id)

func load_honor():
	honor = DataBase.select(_server, g_man.dbms, _path, "honor", id)
	if not honor:
		honor = 0

func load_money():
	money_system.set_money(DataBase.select(_server, g_man.dbms, _path, "money", id))

func load_referrer():
	referrer = DataBase.select(_server, g_man.dbms, _path, "referrer", id)

func load_return_starter_money():
	return DataBase.select(_server, g_man.dbms, _path, "person_starter_money", id)

func load_return_employed_at():
	var employed_at = DataBase.select(_server, g_man.dbms, _path, "employed_at", id)
	if employed_at:
		return employed_at
	return 0

func load_return_employed_at_corg():
	var employed_at_corg = DataBase.select(_server, g_man.dbms, _path, "employed_at_corg", id)
	if employed_at_corg:
		return employed_at_corg
	return 0

func load_return_salary():
	return DataBase.select(_server, g_man.dbms, _path, "salary", id)

func load_return_biography():
	return DataBase.select(_server, g_man.dbms, _path, "biography", id)
	
func load_return_working():
	var working = DataBase.select(_server, g_man.dbms, _path, "working", id)
	if working:
		return working
	return false

func load_return_commercials_wait():
	var time = DataBase.select(_server, g_man.dbms, _path, "save_commercials_wait", id)
	if time:
		return time
	return 0

func load_return_id_active_law_suggested():
	return DataBase.select(_server, g_man.dbms, _path, "id_active_law_suggested", id)

func load_return_spender():
	return DataBase.select(_server, g_man.dbms, _path, "id_spender", id)
	#endregion load
#endregion savable
#region saveload

	#region save
		#region AdditionallyFunctionality
func save_referrer_from_cmd(referrer_name):
	load_referrer()
	if referrer == 0:
		if referrer_name != _username && g_man.server_usernames.has(referrer_name):
			referrer = g_man.server_usernames[referrer_name]
			var starter_money = MoneyCurrency.convert_money(1, MoneyCurrency.plant.pineapple)
			save_referrer()
			save_starter_money(starter_money)
			push_error("remove remove section it's only for testing so that when someone gets referrer he immediately gets personal money!!! and CORG money")
			var remove = true
			if remove:
				money_system.set_money(starter_money + money_system.get_money())
				save_money()
				var corg:Company = Company.try_get_server_corg(id)
				if corg:
					corg.set_money(MoneyCurrency.convert_money(1, MoneyCurrency.plant.pineapple))
					corg.save_money()
					return true
			push_warning("doesn't contain name: ", referrer_name)
		#endregion AdditionallyFunctionality

func save_change_user_level(new_user_level):
	if load_return_sudo():
		return
	if user_level == 2 && user_level == new_user_level:
		change_total_corg_accounts(true)
		buffering_user_level = 2
		save_buffering_user_level()
		release_from_buffer()
		return
	# if user level is same than it won't change
	if user_level == new_user_level && user_level != 2:
		return
	var before = 1
	if user_level >= BECOME_MODERATOR - 1:
		before = user_level
	elif user_level == 0 && new_user_level != 0:
		change_total_corg_accounts(true)
	elif user_level != 0 && new_user_level == 0:
		change_total_corg_accounts(false)
	# change user level
	if before < new_user_level:
		buffering_user_level = before + 1
	else:
		buffering_user_level = before - 1
	
	save_buffering_user_level()
	release_from_buffer()

func change_total_corg_accounts(add:bool):
	if add:
		# if it was already confirmed as corg don't add him to the total count of corg accounts
		if not corg_verified_person:
			g_man.stat_total_persons_on_corg_count += 1
	else:
		g_man.stat_total_persons_on_corg_count -= 1
	# total community size is controlled with max 253 batches
	g_man.count_per_container_corg_accounts = g_man.stat_total_persons_on_corg_count / 253
	# if container of moderators is too small
	if g_man.stat_total_persons_on_corg_count * 0.1 > g_man.count_per_container_corg_accounts:
		# minimum is 10% and even bigger minimum is 5
		if g_man.count_per_container_corg_accounts < 5:
			g_man.count_per_container_corg_accounts = 5
	g_man.save_count_per_container_corg_accounts()
	g_man.save_stat_total_persons_on_corg_count()


	#private void SaveFraud()
	#{
		#DataBase.Insert(server, NetMan.DbMs, path, DataBase.fileName.fraud, id, Fraud, DataBase.Operating.equals)
		#//DbmsSqLite.GetSin(Time.time).Update(true, true, DbmsSqLite.TableServPerson, id, DbmsSqLite.ColumnFraud, $"{Fraud}")
	#}

	#public void SaveRemovalDate(){
		#
		#if(removalYear > 4500){
			#removalYear = (short)DateTime.Now.Year
			#removalMonth = (short)DateTime.Now.Month
			#// DbmsSqLite.GetSin(Time.time).Update(true, true, DbmsSqLite.TableServPerson, id, 
			#//     DbmsSqLite.ColumnRemovalYear, $"{removalYear}",
			#//     DbmsSqLite.ColumnRemovalMonth, $"{removalMonth}",
			#//     DbmsSqLite.ColumnRemoval, $"{(removal ? 1 : 0)}"
			#// )
			#DataBase.Insert(true, NetMan.DbMs, DataBase.path.Person, DataBase.fileName.removalYear, id, removalYear, DataBase.Operating.equals)
			#DataBase.Insert(true, NetMan.DbMs, DataBase.path.Person, DataBase.fileName.removalMonth, id, removalMonth, DataBase.Operating.equals)
			#DataBase.Insert(true, NetMan.DbMs, DataBase.path.Person, DataBase.fileName.removal, id, removal, DataBase.Operating.equals)
			#Debug.LogError($"for {userName} set removal year: {removalYear} month: {removalMonth}")
		#}
	#}




	#public void SaveSpender()
	#{
		#DataBase.Insert(server, NetMan.DbMs, path, DataBase.fileName.Spender, id, idSpender, DataBase.Operating.equals)
#
		#// DbmsSqLite.GetSin(Time.time).Update(true, true, DbmsSqLite.TableServPerson, id, DbmsSqLite.ColumnSpender, $"{idSpender}")
	#}
	#endregion end save
	#region load
	#endregion end load
#endregion end saveload
	#public static void ToDebug(long id){
		#Debug.Log($"{g_man.SavableServerPerson.Get(id)?.userName} {id}")
	#}
	#public static void ToDebugError(long id){
		#Debug.LogError($"{g_man.SavableServerPerson.Get(id)?.userName} {id}")
	#public static string ToStringServer(long id) => g_man.SavableServerPerson.Get(id).userName
#region serialize
func serialize():
	var data = []
	data.push_back(id)
	data.push_back(_username)
	return data
	
func deserialize(data:Array):
	_username = data.pop_back()
	id = data.pop_back()
	return data
#endregion serialize
func _to_string():
	return [id]
