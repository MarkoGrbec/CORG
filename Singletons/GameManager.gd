class_name GameManager extends Node
#
#region scenes
const SOCIAL_NODE = preload("res://Networking/SocialNode/SocialNode.tscn")
const CORG_NODE = preload("res://Networking/CorgNode/CorgNode.tscn")
#endregion scenes

#region inputs
var test: Testing
var planet
var map: RootMap
var camera: Camera

var server_accounts_container
var server_accounts_buttons_container = {}
	#region windows
var array_mouse_inside_windows: Array[Callable]
var admin_manager: AdminManager
var reg_login_tabs: reg_login
var main_menu_tabs: MainMenu
var social: Social
var corg: Corg
var options: Options
var marketplace: Marketplace
var welcome_unwelcome_window: WelcomeUnwelcome
var corg_apply_to_be_approved: CorgApplyToBeApproved
var workers_window: WorkersWindow
var account_worker_stats_window: AccountWorkerStatsWindow
var store_manager: StoreManager
var item_manager: ItemManager
var commercial_manager: CommercialManager
var law_tab: LawTab
var spender_tab: SpenderTab
var law_manager: LawManager
var record_voice: RecordVoice
var database_reader: DBMSReadWriter
var mold_window: MoldWindow
var music_manager: MusicManager
var file_dialog: FileDialog
var debug_draw_ray: DebugDrawRay
var changes_manager: ChangesManager
	#endregion windows
var scripts

##global rect for global windows position
var global_canvas: CanvasControl

	#region networking
		#region main
var net_manager = ENetMultiplayerPeer.new()
var port
var server_ip_address

var self_send := false
var android
var android_force
var access_granted
var local_network_node:NetworkNode
var local_server_network_node:NetworkNode

var dict_id_unique__connected_node = {}
## for p2p client sides
var dict_id_unique__dp_node = {}
var admin_unique_id: int
		#endregion main
		#region corg
var server_money_system:MoneySystem

# ment for law calculation
var client_total_persons_on_corg_count = 1
var stat_total_persons_on_corg_count = 0
var count_per_container_corg_accounts = 1
var last_in_chain_user_level = 1
		#endregion corg
	#endregion networking
#endregion inputs

#region savable input
var dbms = "DBMS"
#endregion savable input
#region pesonal data
	#region local
var server_usernames = {}
var dictMac = {}# string, Mac
var dict_emso__id = {}
var dict_id__emso = {}
## key id, value username
var existing_accounts = {}
var SavableMac: Savable
var SavableMacs: Savable
var savable_static_vars: Savable
var statics: Statics
	#endregion local
	#region network
		#region mac
var savable_server_accounts: Savable
var savable_multi_server_client__mac: SavableMulti
var multi_server_client__macs: DataBase.MultiTable
var savable_permanent_unwelcome_mac: Savable
		#endregion mac
		#region client
var multi_client__server_client: DataBase.MultiTable
var savable_client_client: Savable
## client corg - server corg
var multi_client__server_corg: DataBase.MultiTable
var savable_client_corg: Savable
signal client_signal
signal corg_signal
		#endregion client
		#region corg
var savable_tax: Savable
var container_user_levels: Savable
#var savable_server_corg: Savable
var savable_multi_account__corg: SavableMulti
var multi_server_worker__corg: DataBase.MultiTable
var multi_server_corg__applied: DataBase.MultiTable
var savable_server_client_work_time: SavableDateTime
var savable_multi_corg__daily_income: SavableMulti
			#region comercialist
var savable_multi_corg__pictures: SavableMulti
var savable_multi_client__server_pictures: SavableMulti
var multi_client_corg__client_commercial_pictures: DataBase.MultiTable
			#endregion comercialist
		#endregion corg
		#region marketplace
var savable_multi_corg__items: SavableMulti
var multi_s_corg__customer___requested_item: SavableMulti
var multi_s_corg__customer: DataBase.MultiTable
var savable_multi_item__seller____reserved_on_item: SavableMulti
var savable_multi_corg__reserved_on_corg: SavableMulti
		#endregion marketplace
		#region law
var savable_law_meta: Savable
var savable_multi_law_type__law: SavableMulti
var savable_multi_law__voter: SavableMulti
		#endregion law
		#region spender
var savable_multi_type__spender: SavableMulti
var savable_multi_id_client_spender__id_voter_vote_system: SavableMulti
		#endregion spender
		#region forum
var savable_multi_forum__forum_threads: SavableMulti
var savable_multi_forum__post: SavableMulti
var savable_multi_post__comment: SavableMulti
var savable_multi_comment__comment: SavableMulti
		#endregion forum
		#region id picture
var multi_server_client__not_verified_picture: DataBase.MultiTable
var savable_multi_client__id_mod_verified: SavableMulti
		#endregion id picture
	#endregion network
#endregion personal data
#region Database
func populate_database():
	var _table = DataBase.Table.new("client")
	columns_client(_table, true)
	columns_client(_table, false)
	
	_table = DataBase.Table.new("statics")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "last_in_chain_user_level")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "stat_total_persons_on_corg_count")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "count_per_container_corg_accounts")
	
	_table = DataBase.Table.new("windows")
	_table.create_column(false, dbms, DataBase.DataType.RECT, 1, "rect")
	
	_table = DataBase.Table.new("container_user_levels")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "count")
	
	_table = DataBase.Table.new("options")
	_table.create_column(false, dbms, DataBase.DataType.INT, 1, "c_font_size")
	#region mac
	_table = DataBase.Table.new("mac")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "id_macs")
	_table.create_column(true, dbms, DataBase.DataType.STRING, 40, "mac")
	
	_table = DataBase.Table.new("s_client__mac")
	_table.create_column(true, dbms, DataBase.DataType.INT, 1, "approved")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "id_mac")
	_table.create_column(true, dbms, DataBase.DataType.FLOAT, 1, "wait_time")
	
	_table = DataBase.Table.new("s_client__id_mod_verified")
	_table.create_column(true, dbms, DataBase.DataType.STRING, 20, "emso")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "id_mod")
	#endregion mac
	#region corg
	_table = DataBase.Table.new("tax")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "money")
	
	_table = DataBase.Table.new("s_corg__daily_income")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "money")
	_table.create_column(true, dbms, DataBase.DataType.INT, 1, "year")
	_table.create_column(true, dbms, DataBase.DataType.INT, 1, "month")
	_table.create_column(true, dbms, DataBase.DataType.INT, 1, "day")
	
	_table = DataBase.Table.new("corg")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "money")
	_table.create_column(true, dbms, DataBase.DataType.INT, 1, "company_wait_add_time")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "company_comercial_pay")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "founder")
	_table.create_column(false, dbms, DataBase.DataType.LONG, 1, "money")
	_table.create_column(false, dbms, DataBase.DataType.INT, 1, "company_wait_add_time")
	_table.create_column(false, dbms, DataBase.DataType.LONG, 1, "company_comercial_pay")
	_table.create_column(false, dbms, DataBase.DataType.LONG, 1, "founder")
	
	_table = DataBase.Table.new("s_client__corg")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "money")
	_table.create_column(true, dbms, DataBase.DataType.INT, 1, "company_wait_add_time")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "company_comercial_pay")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "founder")
	
	_table = DataBase.Table.new("s_commercials_pictures")
	_table.create_column(true, dbms, DataBase.DataType.INT, 8388608, "raw_texture")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "time")
	
	_table = DataBase.Table.new("c__server_commercials_pictures")
	_table.create_column(false, dbms, DataBase.DataType.INT, 8388608, "raw_texture")
	_table.create_column(false, dbms, DataBase.DataType.LONG, 1, "time")
	
	_table = DataBase.Table.new("s_corg__item")
	_table.create_column(true, dbms, DataBase.DataType.STRING, 25, "item_name")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "item_cost")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "item_id_server_corg")
	
	_table = DataBase.Table.new("s_corg__customer___requested_item")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "cost")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "id_item")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "id_customer")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "id_trader")
	_table.create_column(true, dbms, DataBase.DataType.STRING, 25, "item_name")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "quantity")
	_table.create_column(true, dbms, DataBase.DataType.INT, 1, "shipment")
	
	_table = DataBase.Table.new("s_item__seller___reserved_on_item")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "money")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "id_item")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "id_buyer")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "id_seller")
	
	_table = DataBase.Table.new("savable_multi_corg__reserved_on_corg")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "money")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "id_buyer")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "id_seller")
	
	#endregion corg
	#region law
	_table = DataBase.Table.new("law_meta")
	_table.create_column(true, dbms, DataBase.DataType.STRING, 45, "header")
	
	_table = DataBase.Table.new("law")
	_table.create_column(true, dbms, DataBase.DataType.STRING, 45, "header")
	_table.create_column(true, dbms, DataBase.DataType.STRING, 512, "text")
	_table.create_column(true, dbms, DataBase.DataType.INT, 1, "type")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "id_poster")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "up")
	_table.create_column(true, dbms, DataBase.DataType.BOOL, 1, "accepted")
	_table.create_column(true, dbms, DataBase.DataType.BOOL, 1, "deleted")
	
	_table = DataBase.Table.new("vote_system")
	_table.create_column(true, dbms, DataBase.DataType.BOOL, 1, "vote")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "id_client")
	#endregion law
	#region spenders
	_table = DataBase.Table.new("s_type__id_client_spender")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "id_client")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "up_vote")
	_table.create_column(true, dbms, DataBase.DataType.STRING, 1000, "text")
	
	_table = DataBase.Table.new("s_id_client_spender__id_voter_vote_system")
	_table.create_column(true, dbms, DataBase.DataType.BOOL, 1, "vote")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "id_client")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "up_vote")
	
	#endregion spenders
	#region social
	_table = DataBase.Table.new("s_forum__forum")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "id_father")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "id_client")
	_table.create_column(true, dbms, DataBase.DataType.STRING, 25, "thread_name")
	_table.create_column(true, dbms, DataBase.DataType.STRING, 128, "body")
	_table.create_column(true, dbms, DataBase.DataType.INT, 1, "type")
	
	_table = DataBase.Table.new("s_forum__post")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "id_father")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "id_client")
	_table.create_column(true, dbms, DataBase.DataType.STRING, 25, "thread_name")
	_table.create_column(true, dbms, DataBase.DataType.STRING, 1024, "body")
	
	_table = DataBase.Table.new("s_post__comment")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "id_father")
	_table.create_column(true, dbms, DataBase.DataType.LONG, 1, "id_client")
	_table.create_column(true, dbms, DataBase.DataType.STRING, 256, "body")
	#endregion social
	
	_table.create_column(false, dbms, DataBase.DataType.INT, 1, "c_font_size")
	#endregion gameing
func columns_client(_table, server: bool):
	# server && client
	_table.create_column(server, dbms, DataBase.DataType.STRING, 3256, "rsa private")
	_table.create_column(server, dbms, DataBase.DataType.INT, 3256, "rsa public")
	_table.create_column(server, dbms, DataBase.DataType.STRING, 30, "username")
	_table.create_column(server, dbms, DataBase.DataType.STRING, 30, "password")
	_table.create_column(server, dbms, DataBase.DataType.LONG, 1, "secret")
	_table.create_column(server, dbms, DataBase.DataType.BOOL, 1, "sudo")
	_table.create_column(server, dbms, DataBase.DataType.LONG, 1, "employed_at")
	_table.create_column(server, dbms, DataBase.DataType.LONG, 1, "employed_at_corg")
	_table.create_column(server, dbms, DataBase.DataType.LONG, 1, "referrer")
	_table.create_column(server, dbms, DataBase.DataType.LONG, 1, "money")
	_table.create_column(server, dbms, DataBase.DataType.LONG, 1, "salary")
	_table.create_column(server, dbms, DataBase.DataType.LONG, 1, "honor")
	_table.create_column(server, dbms, DataBase.DataType.STRING, 1500, "biography")
	#server only
	if server:
		_table.create_column(server, dbms, DataBase.DataType.BOOL, 1, "client_can_get_in")
		_table.create_column(server, dbms, DataBase.DataType.BOOL, 1, "comput_can_get_in")
		_table.create_column(server, dbms, DataBase.DataType.BOOL, 1, "send_picture")
		_table.create_column(server, dbms, DataBase.DataType.INT, 8388608, "face_picture")
		_table.create_column(server, dbms, DataBase.DataType.INT, 8388608, "id_picture")
		_table.create_column(server, dbms, DataBase.DataType.STRING, 20, "emso")
		_table.create_column(server, dbms, DataBase.DataType.STRING, 20, "emso_repair")
		_table.create_column(server, dbms, DataBase.DataType.STRING, 20, "emso_starter")
		_table.create_column(server, dbms, DataBase.DataType.BOOL, 1, "corg_verified_person")
		_table.create_column(server, dbms, DataBase.DataType.INT, 1, "verify_corg")
		_table.create_column(server, dbms, DataBase.DataType.INT, 1, "user_level")
		_table.create_column(server, dbms, DataBase.DataType.INT, 1, "buffer")
		_table.create_column(server, dbms, DataBase.DataType.LONG, 1, "mod_verified")
		_table.create_column(server, dbms, DataBase.DataType.LONG, 1, "person_starter_money")
		_table.create_column(server, dbms, DataBase.DataType.BOOL, 1, "working")
		_table.create_column(server, dbms, DataBase.DataType.LONG, 1, "id_active_law_suggested")
		_table.create_column(server, dbms, DataBase.DataType.LONG, 1, "id_spender")
	# client only
	else:
		_table.create_column(server, dbms, DataBase.DataType.INT, 1, "save_commercials_wait")

#endregion Database

#region networking
	#region server client
func server():
	push_warning("server savables")
	server_savables()
	push_warning("server savables granted")
	if self_send:
		client_savables()
	if access_granted:
		if savable_server_accounts.last_id() < 5:
			set_default_moderators()
		if savable_law_meta.last_id() < 2:
			set_default_law_meta()
	
	net_manager.create_server(port)
	multiplayer.multiplayer_peer = net_manager
	
	add_network_node(1, "server")
	
	multiplayer.peer_connected.connect(
		func(new_peer_id):
			#after the connection is made
			net_node(new_peer_id, "server")
			add_network_node.rpc(new_peer_id, "client")
	)
	multiplayer.peer_disconnected.connect(disconnect_client)
	reg_login_tabs.set_current_tabing(5)

func client():
	client_savables()
	if net_manager.get_connection_status() == net_manager.CONNECTION_DISCONNECTED:
		net_manager.create_client(server_ip_address, port)
		multiplayer.multiplayer_peer = net_manager
		multiplayer.server_disconnected.connect(disconnect_from_server)
		# if no existing accounts send to register
		if existing_accounts.size() == 0:
			reg_login_tabs.set_current_tabing(2)
		# if existing accounts send to login with ref
		else:
			reg_login_tabs.set_current_tabing(3)
	#endregion server client
	#region disconnect
## on server
func disconnect_client(id):
	push_warning("disconnected client ", id)
	local_server_network_node.rpc_disconnect_peer.rpc(id)
	if dict_id_unique__connected_node.has(id):
		dict_id_unique__connected_node[id].destroy_me(true)
		dict_id_unique__connected_node[id].queue_free()
		dict_id_unique__connected_node.erase(id)
	if server_accounts_buttons_container.has(id):
		server_accounts_buttons_container[id].queue_free()
		server_accounts_buttons_container.erase(id)
	if id == admin_unique_id:
		admin_unique_id = 0

## on client
func disconnect_from_server():
	if local_network_node and local_network_node.client:
		push_warning("disconnected from server ", local_network_node.id_net, " : ", local_network_node.client._username)
	multiplayer.server_disconnected.disconnect(disconnect_from_server)
	local_network_node.clean_yourself()
	local_network_node.destroy_me(false)
	local_network_node.queue_free()
	local_network_node = null
	reg_login_tabs.show_window(true)
	mold_window.set_instructions_only(["you have been disconnected from server"])
	#endregion disconnect
	#region logout
func logout():
	var peers = multiplayer.get_peers()
	if peers.has(1):
		multiplayer.multiplayer_peer.disconnect_peer(1)
	reg_login_tabs.show_window(true)
	#endregion logout
	#region moderators
func set_default_moderators():
	var admin:Client = savable_server_accounts.get_set_new()
	admin._username = "admin"
	admin._password = "SkoziTujaVrata"
	admin.verified_corg = 3
	admin.corg_verified_person = true
	admin.user_level = Client.ADMIN_USER_LEVEL
	admin.save_moderator_variables()
	
	var mod:Client = savable_server_accounts.get_set_new()
	mod._username = "mod0"
	mod._password = "SkoziMojaVrata0"
	mod.verified_corg = 3
	mod.corg_verified_person = true
	mod.user_level = 0
	mod.honor = 0
	mod.save_moderator_variables()
	
	mod = savable_server_accounts.get_set_new()
	mod._username = "mod1"
	mod._password = "SkoziMojaVrata1"
	mod.verified_corg = 3
	mod.corg_verified_person = true
	mod.user_level = 1
	mod.honor = 1
	mod.save_moderator_variables()
	
	mod = savable_server_accounts.get_set_new()
	mod._username = "mod2"
	mod._password = "SkoziMojaVrata2"
	mod.verified_corg = 3
	mod.corg_verified_person = true
	mod.user_level = 2
	mod.honor = 1000
	mod.save_moderator_variables()
	
	mod = savable_server_accounts.get_set_new()
	mod._username = "mod3"
	mod._password = "SkoziMojaVrata3"
	mod.verified_corg = 3
	mod.corg_verified_person = true
	mod.user_level = 3
	mod.honor = 2000
	mod.save_moderator_variables()
	
	mod = savable_server_accounts.get_set_new()
	mod._username = "mod4"
	mod._password = "SkoziMojaVrata4"
	mod.verified_corg = 3
	mod.corg_verified_person = true
	mod.user_level = 4
	mod.honor = 3000
	mod.save_moderator_variables()
	
	mod = savable_server_accounts.get_set_new()
	mod._username = "mod5"
	mod._password = "SkoziMojaVrata5"
	mod.verified_corg = 3
	mod.corg_verified_person = true
	mod.user_level = 5
	mod.honor = 4000
	mod.save_moderator_variables()
	#endregion moderators
	#region net_node
## general network node for all players
@rpc("call_local", "any_peer", "reliable")
func add_network_node(id, text):
	## other clients simply pass this call but still recieve it
	## if the id is my id I'll populate my self and not the others I don't want to care about them now
	if id == multiplayer.get_unique_id(): # || multiplayer.get_unique_id() == 1:
		net_node(id, text)

## client localy can populate data and server can populate all of clients with data
func net_node(id, text):
	var node = preload("res://Networking/Client/NetworkNode.tscn").instantiate()
	map.add_child(node)
	
	node._name = String("net_node {text} id: {id}").format({text = text, id = id})
	node.set_multiplayer_authority(id)
	if id == multiplayer.get_unique_id():
		#changes_manager.add_change("true")
		local_network_node = node
		if id == 1:
			local_server_network_node = node
	#config servers local node
	if(self_send):
		local_network_node = preload("res://Networking/Client/NetworkNode.tscn").instantiate()
		map.add_child(local_network_node)
		local_network_node.set_multiplayer_authority(id)
		local_network_node.id_net = id
	## config
	node.id_net = id
	if multiplayer.get_unique_id() == 1:
		dict_id_unique__connected_node[id] = node
		var player_button = preload("res://GUI/buttons/player_button/PlayerButton.tscn").instantiate()
		player_button.set_multiplayer_authority(id)
		server_accounts_buttons_container[id] = player_button
		server_accounts_container.add_child(player_button)
		node.change_button_name.connect(player_button.change_button_name)
		if admin_unique_id:
			local_server_network_node.target_add_players.rpc_id(admin_unique_id, [id])
	return node.name
	#endregion net_node
	#region secure connection
func secure_connection():
	if not local_network_node.secure_connection:
		local_network_node.get_secret_keys_from_beginning()
		var i = 0
		while not local_network_node.secure_connection:
			await get_tree().create_timer(1).timeout
			i += 1
			if i == 10:
				return false
	return true
	#endregion secure connection
	#region connecting
var connecting = false

func connecting_to_server():
	if not local_network_node:
		connecting = true
		mold_window.set_instructions_only(["you aren't connected", "connecting...", "server may be down please wait max 15 min"])
		client()
		await get_tree().create_timer(15).timeout
		return await connecting_to_server()
	#changes_manager.add_change("you are connected to server")
	connecting = false
	return true
	#endregion connecting
	#region register
var reg_log_call = false
func register(username, password):
	if connecting or not await connecting_to_server():
		return
	# reg_log_call check so that you can't register 10 times at once
	if not reg_log_call:
		local_network_node.client = Client.new()
		local_network_node.client._username = username
		local_network_node.client._password = password
		reg_log_call = true
		push_warning("register")
		if await secure_connection():
			var enc = local_network_node.encrypted
			
			var enc_username# = enc.rsa_encrypt_data(userName) ## if non it returns error when I'm trying to decrypt
			var enc_password# = enc.rsa_encrypt_data(password) ## if non it returns error when I'm trying to decrypt
			
			var secret = enc.secret_key
			enc_username = EncriptData.synchronous_encrypting(username, secret)
			enc_password = EncriptData.synchronous_encrypting(password, secret)
			#print("pass2:", EncriptData.synchronous_decrypting(enc_password, secret))
			
			local_network_node.cmd_register.rpc_id(1, enc_username, enc_password, OS.get_unique_id())
			await get_tree().create_timer(2).timeout
			reg_log_call = false
	#endregion register
	#region login
func login(username, password):
	if connecting or not await connecting_to_server():
		return
	# reg_log_call check so that you can't login 10 times at once
	if not reg_log_call:
		local_network_node.client = Client.new()
		local_network_node.client._username = username
		local_network_node.client._password = password
		reg_log_call = true
		push_warning("login")
		if await secure_connection():
			var enc = local_network_node.encrypted
			
			var enc_username# = enc.rsa_encrypt_data(userName) ## if non it returns error when I'm trying to decrypt
			var enc_password# = enc.rsa_encrypt_data(password) ## if non it returns error when I'm trying to decrypt
			var enc_unique_id#
			
			var secret = enc.secret_key
			enc_username = EncriptData.synchronous_encrypting(username, secret)
			enc_password = EncriptData.synchronous_encrypting(password, secret)
			enc_unique_id = EncriptData.synchronous_encrypting(OS.get_unique_id(), secret)
			
			local_network_node.cmd_connect_try_login.rpc_id(1, enc_username, enc_password, enc_unique_id)
			await get_tree().create_timer(2).timeout
			reg_log_call = false
	#endregion login
	#region login with ref
func login_with_ref(id:int, id_server:int):
	if connecting or not await connecting_to_server():
		return
	# reg_log_call check so that you can't login 10 times at once
	if not reg_log_call:
		local_network_node.client = savable_client_client.get_index_data(id)
		if not local_network_node.client:
			mold_window.set_instructions_only(["you may not enter this client because you do not have loaded client", "try login with username and password"])
			return
		
		reg_log_call = true
		push_warning("login")
		if await secure_connection():
			var enc = local_network_node.encrypted
			
			var enc_key# = enc.rsa_encrypt_data(userName) ## if non it returns error when I'm trying to decrypt
			var enc_unique_id#
			
			var secret = enc.secret_key
			
			var key = local_network_node.client.load_return_secret()
			
			if not key:
				local_network_node.client.load_username()
				mold_window.set_instructions_only(["cannot enter client id", id, local_network_node.client._username, "you do not have valid key"])
				reg_log_call = false
				return
			
			enc_key = EncriptData.synchronous_encrypting_int(key, secret)
			enc_unique_id = EncriptData.synchronous_encrypting(OS.get_unique_id(), secret)
			local_network_node.cmd_connect_try_login_with_ref.rpc_id(1, id_server, enc_key, enc_unique_id)
			await get_tree().create_timer(1).timeout
			reg_log_call = false
	#endregion login with ref
	#region admin
func send_admin_name(id, username):
	if admin_unique_id:
		local_server_network_node.target_change_id_name.rpc_id(admin_unique_id, [[id, username]])

func set_admin_unique_id(id):
	admin_unique_id = id
	var keys = dict_id_unique__connected_node.keys()
	local_server_network_node.target_add_players.rpc_id(id, keys)
	var array___id__username = []
	for key in keys:
		var node: NetworkNode = dict_id_unique__connected_node.get(key)
		if node.client:
			array___id__username.push_back([key, node.client._username])
	local_server_network_node.target_change_id_name.rpc_id(admin_unique_id, array___id__username)
	#endregion admin
#endregion networking
#region grand access
func grand_access(server = false):
	if server:
		push_warning("granting permissions")
		access_granted = true
		return access_granted
	push_warning("granting permissions")
	var granted = OS.request_permissions()
	access_granted = granted
	android = OS.has_feature("android")
	push_warning("android false")
	show_joysticks(false)
	push_warning("joystick false")
	var manage = OS.get_granted_permissions()
	#changes_manager.add_change(str("access granted:", granted, "\nmanage / read / write", manage, "\nandroid", OS.has_feature("android")))
	#mold_window.set_instructions_only(["access granted:", granted, "manage / read / write", manage, "android", OS.has_feature("android")])
	return granted
#endregion grand access
#region law meta
func set_default_law_meta():
	var law_meta:LawMeta = savable_law_meta.get_set_new()
	law_meta.header = "suggested"
	law_meta.fully_save()
	
	law_meta = savable_law_meta.get_set_new()
	law_meta.header = "constitution"
	law_meta.fully_save()
	
	law_meta = savable_law_meta.get_set_new()
	law_meta.header = "finance"
	law_meta.fully_save()
	
#endregion law meta
#region savables
func server_savables():
	if not grand_access(true):
		push_error("not granted access")
		return
	push_warning("poppulating server")
	populate_database()
	load_count_per_container_corg_accounts()
	load_stat_total_persons_on_corg_count()
	load_last_in_chain_user_level()
	#region server classes
	savable_static_vars = Savable.new(true, dbms, "statics", Statics.new())
	if savable_static_vars.last_id() < 2:
		var stat:Statics = savable_static_vars.get_set_new()
		stat.fully_load()
	statics = savable_static_vars.get_index_data(1)
	
	server_money_system = MoneySystem.new()
	savable_tax = Savable.new(true, dbms, "tax", Tax.new())
	server_money_system.StartServer()
	#endregion server classes
	#region client
	savable_server_accounts = Savable.new(true, dbms, "client", Client.new())
	
	var count = savable_server_accounts.last_id()
	for i in count:
		var username = DataBase.select(true, dbms, "client", "username", i)
		if username:
			server_usernames[username] = i
		var emso = DataBase.select(true, dbms, "client", "emso", i)
		if emso:
			dict_emso__id[emso] = i
	
	SavableMac = Savable.new(true, dbms, "mac", Mac.new())
	SavableMac.partly_load_all()
	
	SavableMacs = Savable.new(true, dbms, "macs", Macs.new())
	savable_multi_server_client__mac = SavableMulti.new(true, dbms, "s_client__mac", UnwelcomeMac.new())
	multi_server_client__macs = DataBase.MultiTable.new(dbms, "s_client__macs")
	savable_permanent_unwelcome_mac = Savable.new(true, dbms, "permanent_unwelcome_mac", PermanentUnwelcomeMac.new())
	
	container_user_levels = Savable.new(true, dbms, "container_user_levels", ContainerUserLevel.new())
	#endregion client
	#region social
	savable_multi_forum__forum_threads = SavableMulti.new(true, dbms, "s_forum__forum", Forum.new())
	savable_multi_forum__post = SavableMulti.new(true, dbms, "s_forum__post", Post.new())
	savable_multi_post__comment = SavableMulti.new(true, dbms, "s_post__comment", Comment.new())
	savable_multi_comment__comment = SavableMulti.new(true, dbms, "s_comment__comment", Comment.new())
	#endregion social
	#region corg
	multi_server_client__not_verified_picture = DataBase.MultiTable.new(dbms, "s_client__not_verify_pic")
	savable_multi_client__id_mod_verified = SavableMulti.new(true, dbms, "s_client__id_mod_verified", ModVerified.new())
	
	savable_multi_account__corg = SavableMulti.new(true, dbms, "s_client__corg", Company.new())
	multi_server_worker__corg = DataBase.MultiTable.new(dbms, "s_worker__corg")
	multi_server_corg__applied = DataBase.MultiTable.new(dbms, "s_corg__client")
	savable_server_client_work_time = SavableDateTime.new(true, dbms, "client_work_time")
	savable_multi_corg__daily_income = SavableMulti.new(true, dbms, "s_corg__daily_income", DailyIncome.new())
	
	savable_multi_corg__pictures = SavableMulti.new(true, dbms, "s_commercials_pictures", PictureData.new())
	
	savable_multi_corg__items = SavableMulti.new(true, dbms, "s_corg__item", Item.new())
	multi_s_corg__customer___requested_item = SavableMulti.new(true, dbms, "s_corg__customer___requested_item", RequestedItem.new())
	multi_s_corg__customer = DataBase.MultiTable.new(dbms, "s_corg__customer")
	savable_multi_item__seller____reserved_on_item = SavableMulti.new(true, dbms, "s_item__seller___reserved_on_item", ReservedOnItem.new())
	savable_multi_corg__reserved_on_corg = SavableMulti.new(true, dbms, "savable_multi_corg__reserved_on_corg", ReservedOnCorg.new())
	
	savable_law_meta = Savable.new(true, dbms, "law_meta", LawMeta.new())
	savable_multi_law_type__law = SavableMulti.new(true, dbms, "law", Law.new())
	savable_multi_law__voter = SavableMulti.new(true, dbms, "vote_system", VoteSystem.new())
	
	savable_multi_type__spender = SavableMulti.new(true, dbms, "s_type__id_client_spender", Spender.new())
	savable_multi_id_client_spender__id_voter_vote_system = SavableMulti.new(true, dbms, "s_id_client_spender__id_voter_vote_system", VoteSystem.new())
	#endregion corg

func client_savables():
	if not grand_access():
		return
	populate_database()
	
	multi_client__server_client = DataBase.MultiTable.new(dbms, "multiCC_SC")
	savable_client_client = Savable.new(false, dbms, "client", Client.new())
	var ids = multi_client__server_client.select_left_row()
	for item in ids:
		var username = DataBase.select(false, dbms, "client", "username", item)
		if not existing_accounts.has(item):
			existing_accounts[item] = username
			reg_login_tabs.add_existing_account(item, username)
	savable_client_corg = Savable.new(false, dbms, "corg", Company.new())
	multi_client__server_corg = DataBase.MultiTable.new(dbms, "multi_c_corg__s_corg")
	
	savable_multi_client__server_pictures = SavableMulti.new(false, dbms, "c__server_commercials_pictures", PictureData.new())
	multi_client_corg__client_commercial_pictures = DataBase.MultiTable.new(dbms, "c_corg__client_comercial_pictures")
	#savable_multi_client_avatar__customer___id_rack = SavableMulti.new(false, dbms, "c_avatar__customer", Customer.new())
	#region save
func save_last_in_chain_user_level():
	DataBase.insert(true, dbms, "statics", "last_in_chain_user_level", 1, last_in_chain_user_level)

func save_stat_total_persons_on_corg_count():
	DataBase.insert(true, dbms, "statics", "stat_total_persons_on_corg_count", 1, stat_total_persons_on_corg_count)

func save_count_per_container_corg_accounts():
	DataBase.insert(true, dbms, "statics", "count_per_container_corg_accounts", 1, count_per_container_corg_accounts)
	#endregion save
	#region load
func load_last_in_chain_user_level():
	last_in_chain_user_level = DataBase.select(true, dbms, "statics", "last_in_chain_user_level", 1)
	if not last_in_chain_user_level:
		last_in_chain_user_level = 1

func load_stat_total_persons_on_corg_count():
	stat_total_persons_on_corg_count = DataBase.select(true, dbms, "statics", "stat_total_persons_on_corg_count", 1)
	if not stat_total_persons_on_corg_count:
		stat_total_persons_on_corg_count = 1

func load_count_per_container_corg_accounts():
	count_per_container_corg_accounts = DataBase.select(true, dbms, "statics", "count_per_container_corg_accounts", 1)
	if not count_per_container_corg_accounts:
		count_per_container_corg_accounts = 5
	#endregion load
#endregion savables
#region login success
func login_succeed(
	enc_username,
	id_server: int, employed_at: int, employed_at_corg,
	reputation: int, id_referrer: int,
	array_macs,
	user_level: int, verified_corg, honor: int,
	can_come_in_with_other_client: bool,
	can_come_in_with_other_computer: bool,
	came_in_with_other_computer: bool,
	corg_verified_person: bool,
	enc_key,
	send_picture,
	suggested_law_array
):
	print("login succeed")
	#decrypt username
	if enc_username:
		local_network_node.client._username = EncriptData.synchronous_decrypting(enc_username, local_network_node.encrypted.secret_key)
	
	var _client:Client = Client.construct_for_client_new_id(id_server, local_network_node.client._username)
	_client._username = local_network_node.client._username
	local_network_node.client = _client
	
	_client.save_username()
	
	options.fully_load()
	
	if enc_key != null && enc_key != 0:
		var dec_key = EncriptData.synchronous_decrypting_int(enc_key, local_network_node.encrypted.secret_key)
		if dec_key != _client.load_return_secret():
			_client.save_secret_key(dec_key)
	
	
	_client.other_client_can_get_in = can_come_in_with_other_client
	_client.other_computers_can_get_in = can_come_in_with_other_computer
	
	_client.came_in_with_other_computer = came_in_with_other_computer
	_client.corg_verified_person = corg_verified_person
	
	welcome_unwelcome_window.add_macs(array_macs)
	
	#MainMenuManager.sin.honor.text = honor.ToString()
	print("login: salary: ")#, _client.salary)
	_client.honor = honor
	_client.user_level = user_level
	_client.verified_corg = verified_corg
	
	_client.save_employed_at(employed_at)
	_client.save_employed_at_corg(employed_at_corg)
	_client.reputation = reputation
	_client.send_picture = send_picture
	print(String("loginSucceed referrer is: {id_referrer}").format({id_referrer = id_referrer}))
	_client.referrer = id_referrer
	push_warning("login succeed")
	#MainMenuManager.sin.RefreshReferrer()
	
	# if all are not same as client.id than we add client to the existing_accounts for start menu
	if not existing_accounts.has(_client.id):
		existing_accounts[_client.id] = _client._username
		reg_login_tabs.add_existing_account(_client.id, _client._username)
	else:
		reg_login_tabs.update_existing_account(_client)
	reg_login_tabs.close()
	## set tab on gaming
	main_menu_tabs.starter_tab()
	if _client.user_level or _client.verified_corg:
		mold_window.set_instructions_only(["user level is:", _client.user_level, "verified corg is:", _client.verified_corg])
	
	if suggested_law_array:
		var laws = Serializable.deserialize(Law.new(), suggested_law_array)
		if laws:
			var cmd_yes = (func(_id):)
			var cmd_no = cmd_yes
			var law:Law = laws[0]
			var approved = "is still pending"
			var deleted = ""
			if law.accepted_law:
				approved = "was approved"
				deleted = "do you still want to recieve this information and not being able to make new laws?"
				cmd_no = cmd_delete_id_active_law_suggested
			if law.deleted:
				approved = "wasn't approved"
				deleted = "do you want that suggested law will get permanently deleted"
				cmd_yes = cmd_delete_id_active_law_suggested
			mold_window.set_yes_no_cancel([law.header_text, approved, deleted], cmd_yes, cmd_no)

func cmd_delete_id_active_law_suggested():
	local_network_node.cmd_delete_id_active_law_suggested.rpc_id(1)
	pass
#endregion login success
#region game
func show_joysticks(show, force = false):
	if force:
		android_force = force

#endregion game
#region window
func inside_window(pos: Vector2) -> bool:
	for f_inside_window in array_mouse_inside_windows:
		if f_inside_window.call(pos):
			return true
	return false
#endregion window
