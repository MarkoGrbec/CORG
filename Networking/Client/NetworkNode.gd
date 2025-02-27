class_name NetworkNode extends Node

func _ready():
	encrypted = EncriptData.new()

#region scenes
const SOCIAL_NODE = preload("res://Networking/SocialNode/SocialNode.tscn")
const CORG_NODE = preload("res://Networking/CorgNode/CorgNode.tscn")
#endregion scenes
#region inputs
@warning_ignore("unused_private_class_variable")
var _name

var secure_connection := false
var idClient := 0
var id_net: int
var encrypted: EncriptData
var client: Client

var username
var password

var hacker_alert := false
var raw_email_confirmation_reference
var registration_time: float
var registration_count: int

signal change_button_name(text: String)

#region network nodes
var net_social_node: NetSocial
var net_corg_node: NetCorg
#endregion network nodes

#endregion inputs
#region debugging
@rpc("call_local", "any_peer", "reliable")
func target_instructions(message: Array):
	var sender = multiplayer.get_remote_sender_id()
	if sender == 1:
		g_man.mold_window.set_instructions_only(message)
	else:
		push_error("sender is: ", sender)

@rpc("call_local", "any_peer", "reliable")
func target_changes(message: String):
	g_man.changes_manager.add_change(message)
#endregion debugging
#region asinhron encription
	#region first call

## make 16 public keys,
## client first call
func get_secret_keys_from_beginning():
	var temp_public_keys = g_man.local_network_node.encrypted.get_public_keys_first_call()
	cmd_send_public_and_request_public_keys.rpc_id(1, temp_public_keys)


@rpc("call_local", "any_peer", "reliable")
func cmd_get_secret_key_from_beginning():
	if multiplayer.get_unique_id() == 1:
		var node:NetworkNode = g_man.dict_id_unique__connected_node[multiplayer.get_remote_sender_id()]
		if node.client:
			srv_get_secret_key_from_beginning(node)
		#else:
			#push_warning("WARNING someone is trying to get secret key")
	#else:
		#push_warning("WARNING this is not server")
## make 1 public key,
## server first call
func srv_get_secret_key_from_beginning(node: NetworkNode):
	var temp_public_key = node.encrypted.get_public_key_first_call()
	target_send_public_and_request_public_key.rpc_id(node.id_net, node.client.id, temp_public_key)
	#endregion end first call
	#region second call

## make 16 public keys and make 16 secret keys on server
@rpc("call_local", "any_peer", "reliable")
func cmd_send_public_and_request_public_keys(ClientPubKeys):
	if multiplayer.get_unique_id() != 1:
		return
	
	#encryption data is only temporarily
	var node = g_man.dict_id_unique__connected_node[multiplayer.get_remote_sender_id()]
	var serverPublicKeys = node.encrypted.get_public_keys_second_call(ClientPubKeys)
	#var encrypted_rsa = node.encrypted.get_rsa_encrypted_private_string()
	target_send_public_keys_last_call.rpc_id(multiplayer.get_remote_sender_id(), serverPublicKeys)#, encrypted_rsa)
	node.secure_connection = true

## make 1 public key and make 1 secret key
@rpc("call_local", "any_peer", "reliable")
func target_send_public_and_request_public_key(id, serverPublicKey):
	if multiplayer.get_remote_sender_id() != 1:
		return
	if client:
		client = Client.construct_for_client_new_id(id, client._username)
		var clientPublicKey = encrypted.get_public_key_second_call(serverPublicKey)
		cmd_send_public_key_last_call.rpc_id(1, clientPublicKey)
		#we save rawVerificationSecret On client's disc
		if client.id != 0:
			client.save_secret_key(encrypted.raw_verification_secret)
		else:
			push_error("client didn't fetch id")
	#endregion end second call
	#region third call
## make 16 secret keys on client
@rpc("call_local", "any_peer", "reliable")
func target_send_public_keys_last_call(ServerPublicKeys):
	if multiplayer.get_remote_sender_id() != 1:
		return
	encrypted.make_client_secret_keys(ServerPublicKeys)
	#encrypted.rsa_decrypt_private_string(encrypted_rsa)
	secure_connection = true


## make 1 secret key
@rpc("call_local", "any_peer", "reliable")
func cmd_send_public_key_last_call(clientPublicKey):
	var node = login_intro()
	if node:
		if node.client:
			var secret_key = node.encrypted.make_server_secret_key(clientPublicKey)
			node.client.save_secret_key(secret_key)
		else:
			push_warning("WARNING someone is trying to get secret key without client")
	#endregion end third call
#endregion end asinhron encription
#region register longins
	#region registration
#var _idFingerPrints
var _macs

@rpc("call_local", "any_peer", "reliable")
func cmd_register(enc_username, enc_password, macs):
	var node = login_intro()
	if not node:
		return
	node._macs = [macs]
	if len(enc_username) == 0 or len(enc_password) == 0 or not node.secure_connection:
		var message = []
		message.push_back("cannot register: ")
		if len(enc_username) == 0:
			message.push_back("username length is 0")
		if len(enc_password) == 0:
			message.push_back("password length is 0")
		target_registration_failed.rpc_id(node.id_net, message)
		return
	#we create RAW new player
	var secret_key = node.encrypted.secret_key
	node.username = EncriptData.synchronous_decrypting(enc_username, secret_key)
	node.password = EncriptData.synchronous_decrypting(enc_password, secret_key)
	if g_man.server_usernames.has(node.username):
		target_registration_failed.rpc_id(node.id_net, [String("username {name} already exists".format({name = node.username}))] )
		return
	#if (HUD.emails.ContainsKey(_client.person.email))
	#{
		#Debug.Log("EmailExists")
		#TargetUserNameExists(Me.GetComponent<NetworkIdentity>().connectionToClient, false)
		#return
	#}
	
	#Registration succeed
	#we give the opportunity to register unless he loges out and than the registration fails
	#var random = RandomNumberGenerator.new()
	#random.randomize()
	#node.raw_email_confirmation_reference = random.randi_range(1, 999999)
	#we send email for registration confirmation
	#EmailSend.Send(_client.person.email, _client.person.rawEmailConfirmationReference.ToString(), ConnectionType.register)
	
	# set it only if it wasn't setted yet
	if not node.registration_time:
		node.registration_time = Time.get_unix_time_from_system()
	else:# he cannot register more than once
		node.hacker_alert = true
		#return or can he but he's fraud
		#if Time.get_unix_time_from_system() - node.registration_time < 1:
			#node.registration_time = Time.get_unix_time_from_system()
		node.registration_count += 1
		if node.registration_count > 3:
			return
	##he must confirm registration with email reference number
	#target_registration_confirmation.rpc_id(node.id_net, node.raw_email_confirmation_reference)


##we need to confirm registration and so we had send verification to email
#@rpc("call_local", "any_peer", "reliable")
#func target_registration_confirmation(confirmation_ref: int):
	#print("target ", get_multiplayer_authority(), " needs to confirm the registration")
	#g_man.reg_login_tabs.set_confirmation(confirmation_ref)

#@rpc("call_local", "any_peer", "reliable")
#func cmd_registration_confirmation(confirmData: int):
	#var node:NetworkNode = g_man.dict_id_unique__connected_node[multiplayer.get_remote_sender_id()]
	#node.id_net = multiplayer.get_remote_sender_id()
	#if 0 than the registration hasn't been set
	if true:#node.raw_email_confirmation_reference != 0 && node.raw_email_confirmation_reference == confirmData:
		#node.raw_email_confirmation_reference = 0#it has been used we reset it
		# we check if it was AI
		#node.registration_time = Time.get_unix_time_from_system() - node.registration_time
		#if node.registration_time < 2:
			## it was faster than 2 second
			#node.registration_time = Time.get_unix_time_from_system()
			#node.hacker_alert = true
			# return so that max 3 are going to be registered and all fraud
			#node.registration_count += 1
			#if node.registration_count > 3:
				#return
		#we set the id to the person
		#lets save data on Disc
		if not g_man.server_usernames.has(node.username):
			node.client = Client.new()
			node.client._username = node.username
			node.client._password = node.password
			g_man.savable_server_accounts.set_data(node.client)
			g_man.server_usernames[node.client._username] = node.client.id
			node.client.save_password()
			if node.hacker_alert:
				node.client.make_fraud()
		else:
			node.registration_time = 0
			target_instructions.rpc_id(node.id_net, "before you managed to confirm, someone else has taken the name")
			push_error("before you managed to confirm, someone else has taken the name")
			return
		##save in dictionary
		##
		##HUD.emails.Add(client.person.email, client.id)
		##we save starter money for bonus heaving new member
		##client.starterMoney = (int)MoneyCurrency.Convert(200, MoneyCurrency.plant.apple)
		push_error(String("long is: {id} client username is: {username}").format({id = node.client.id, username = node.client._username}))
		#only 1 secret key used for logging in - rawVerificationSecret
		node.client.register_mac(node._macs)
		
		node._macs = g_man.savable_multi_server_client__mac.get_all(node.client.id, 0)
		var array_macs = Serializable.serialize(node._macs)
		target_registration_succeed.rpc_id(node.id_net, node.client.id, array_macs)
		node._macs = [Mac.get_index_data(node._macs[0].id_mac)._str_mac]
		srv_login_succseed(node)

		srv_get_secret_key_from_beginning(node)
	#node.raw_email_confirmation_reference = 0

#registration succeed we're given only id to save
@rpc("any_peer", "call_local", "reliable")
func target_registration_succeed(id, list_macs):
	#g_man.reg_login_tabs.get_parent().hide()
	g_man.login_succeed(
		null,
		id, 0, 0,
		0, 0,
		list_macs,
		0, 0, 0,
		true, true, false, false,
		0,
		false,
		[]
	)
	print("confirming registration on client net_node last call")

@rpc("call_local", "any_peer", "reliable")
func target_registration_failed(message: Array):
	if multiplayer.get_remote_sender_id() == 1:
		g_man.mold_window.set_instructions_only(message)
	#endregion end registration
	#region login
@rpc("call_local", "any_peer", "reliable")
func cmd_connect_try_login(enc_username, enc_password, macs):
		#region intro
	var node = login_intro()
	if not node:
		return
		#endregion intro
		#region check reference if exists
	node.registration_time = Time.get_unix_time_from_system() - node.registration_time
	if node.registration_time < 2:
		# it was faster than 2 second
		node.registration_time = Time.get_unix_time_from_system()
	var _encrypted:EncriptData = node.encrypted
	node.username = EncriptData.synchronous_decrypting(enc_username, _encrypted.secret_key)
	if not g_man.server_usernames.has(node.username):
		target_instructions.rpc_id(node.id_net, ["login failed username does not exist:", node.username])
		return
	else:
		var id = g_man.server_usernames[node.username]
		node.client = g_man.savable_server_accounts.get_index_data(id)
		#endregion end check reference if exists
		#region check password
	if (len(enc_password) == 0):
		target_instructions.rpc_id(node.id_net, "you enter password with 0 characters it cannot be")
	else:
		node.password = node.client.load_return_password()
		if node.password == null:
			target_instructions.rpc_id(node.id_net, ["ERROR", "client's password does not exist"])
			return
		if node.password != EncriptData.synchronous_decrypting(enc_password, _encrypted.secret_key):
			target_instructions.rpc_id(node.id_net, ["you enter wrong password"])
			return
		#endregion check password
		#region check macs
		macs = EncriptData.synchronous_decrypting(macs, _encrypted.secret_key)
		node._macs = [macs]
		if ! node.client.try_log_in([macs]):
			return
		#endregion check macs
		#region login succeed
	srv_established_connection(node)
		#endregion login succeed
#endregion login
	#region intro
func login_intro():
	if get_multiplayer_authority() != 1:
		return
	var node:NetworkNode = g_man.dict_id_unique__connected_node[multiplayer.get_remote_sender_id()]
	if not node.secure_connection:
		target_instructions.rpc_id(node.id_net, ["your connection isn't secure"])
		return
	if node.hacker_alert and randf_range(0, 1) > 0.3:
		# he is trying to access us and hack again
		# random access so that he won't really know what's going on
		# sometimes he's passed sometimes he's not
		return
	return node
	#endregion intro
	#region login with ref
@rpc("call_local", "any_peer", "reliable")
func cmd_connect_try_login_with_ref(id:int, enc_key, paramMacs):
	var node = login_intro()
	if node:
	#region check reference if exists and is ture
		if enc_key:
			var _client:Client = g_man.savable_server_accounts.get_index_data(id, true)
			if _client:
				var key = _client.load_return_secret()
				var client_key = EncriptData.synchronous_decrypting_int(enc_key, node.encrypted.secret_key)
				if key != 0 && key == client_key:
					node.client = _client
				else:
					_client.save_secret_key(0)
					return
	#endregion check reference if exists and is ture
				paramMacs = EncriptData.synchronous_decrypting(paramMacs, node.encrypted.secret_key)
				node._macs = [paramMacs]
				if not _client.try_log_in([paramMacs]):
					#push_warning("Failed to login not correct MAC address")
					#for mac in [paramMacs]:
						#push_warning("potentially wrong mac: ", mac)
					return
				srv_established_connection(node)
	#endregion login with ref
	#region login with succeed
func srv_established_connection(node: NetworkNode):
	if node.client.partly_loaded < 2:
		node.client.fully_load()
	node.client.id_net = node.id_net
	
	var referrer = node.client.referrer
	
	var list_macs = g_man.savable_multi_server_client__mac.get_all(node.client.id, 0)
	
	var enc_key
	var secret_key = node.client.load_return_secret()
	if secret_key == null || secret_key == 0:
		srv_get_secret_key_from_beginning(node)
	else:
		enc_key = EncriptData.synchronous_encrypting_int(secret_key, node.encrypted.secret_key)
	
	srv_login_succseed(node)
	
	var array_macs = Serializable.serialize(list_macs)
	
	var employed_at = g_man.multi_server_worker__corg.select(node.client.id, 0)
	var employed_at_corg = 0
	if employed_at:
		employed_at = employed_at[0]
	else:
		employed_at = 0
	
	var corgs = g_man.multi_server_worker__corg.select(node.client.id, 0)
	if corgs:
		employed_at_corg = corgs[0]
		var accs = g_man.savable_multi_account__corg.select(0, corgs[0])
		if accs:
			employed_at = accs[0]
		else:
			employed_at = 0
	else:
		employed_at = 0
	var enc_username = EncriptData.synchronous_encrypting(node.client._username, node.encrypted.secret_key)
	
	var law_array = []
	var law = node.client.load_return_id_active_law_suggested()
	law = g_man.savable_multi_law_type__law.get_index_data(law)
	if law:
		law_array = Serializable.serialize([law])
	
	if node.client.user_level == Client.ADMIN_USER_LEVEL:
		g_man.set_admin_unique_id(node.id_net)
	
	target_connection_established.rpc_id(node.id_net,
		enc_username,
		node.client.id, employed_at, employed_at_corg,
		node.client.reputation, referrer,
		array_macs,
		node.client.user_level, node.client.verified_corg, node.client.honor,
		node.client.other_client_can_get_in,
		node.client.other_computers_can_get_in,
		node.client.came_in_with_other_computer,
		node.client.corg_verified_person,
		enc_key,
		node.client.send_picture,
		law_array
	)

@rpc("call_local", "any_peer", "reliable")
func target_connection_established(
		enc_username,
		id:int, employed_at:int, employed_at_corg,
		reputation: int, referrer:int,
		array_macs,
		user_level:int, verified_corg, honor:int,
		can_come_in_with_other_client:bool,
		can_come_in_with_other_computer:bool,
		came_in_with_other_computer:bool,
		corg_verified_person:bool,
		enc_key,
		send_picture,
		suggested_law_array
	):
		client.id_net = multiplayer.get_unique_id()
		print("is client id ", client.id, " == ", id)
		print("established connection")
		g_man.login_succeed(
			enc_username, 
			id, employed_at, employed_at_corg,
			reputation, referrer,
			array_macs,
			user_level, verified_corg, honor,
			can_come_in_with_other_client,
			can_come_in_with_other_computer,
			came_in_with_other_computer,
			corg_verified_person,
			enc_key,
			send_picture,
			suggested_law_array
		)
#endregion end login with sucseed
#endregion register longins
#region create net managers
func srv_login_succseed(node:NetworkNode):
	node.change_button_name.emit(node.client._username)
	g_man.send_admin_name(node.id_net, node.client._username)
	#region net custom
@rpc("call_local", "any_peer", "reliable")
func add_net_custom(index):
	var unique = multiplayer.get_unique_id()
	# create first on server
	if unique == 1:
		#create on server
		if index == 1:
			if not net_social(unique):
				return
		if index == 2:
			#if not create_custom_net_node(unique, net_corg_node, g_man.local_server_network_node.net_corg_node, CORG_NODE, g_man.corg.start):
			if not net_corg(unique):
				return
		else:
			return
		#send to create on client
		add_net_custom.rpc_id(multiplayer.get_remote_sender_id(), index)
	# create on client
	if multiplayer.get_remote_sender_id() == 1:
		if index == 1:
			net_social(unique)
		if index == 2:
			#create_custom_net_node(unique, net_corg_node, g_man.local_server_network_node.net_corg_node, CORG_NODE, g_man.corg.start)
			net_corg(unique)
		else:
			return
		

## custom dp node
func config_net_custom(id, node):
	g_man.map.add_child(node)
	if multiplayer.get_unique_id() == 1:
		node._name = String("server: {id}").format({id = id})
	else:
		node._name = String("client: {id}").format({id = id})
		g_man.dict_id_unique__dp_node[id] = node
	node.set_multiplayer_authority(id)
	
	#endregion net custom
	#region net_social
func net_social(id):
	# net_socail_node - dif
	if net_social_node:
		if multiplayer.get_unique_id() == 1 && not g_man.self_send:
			return true
		return false
	# SOCIAL_NODE - dif
	var node = SOCIAL_NODE.instantiate()
	config_net_custom(id, node)
	# net_social_node - dif
	net_social_node = node
	if multiplayer.get_unique_id() == 1:
		# net_socail_node - dif
		g_man.local_server_network_node.net_social_node = node
	if multiplayer.get_unique_id() != 1 || g_man.self_send:
		# social.start() - dif
		g_man.social.start()
	return true
	#endregion net_social
	#region net corg
func net_corg(id):
	if net_corg_node:
		if multiplayer.get_unique_id() == 1 && not g_man.self_send:
			return true
		return false
	var node = CORG_NODE.instantiate()
	config_net_custom(id, node)
	net_corg_node = node
	if multiplayer.get_unique_id() == 1:
		g_man.local_server_network_node.net_corg_node = node
	if multiplayer.get_unique_id() != 1 || g_man.self_send:
		g_man.corg.start()
	return true
	#endregion net corg
	##region create custom net node - does not work
#func create_custom_net_node(id, custom_net_node, server_net_node, CUSTOM_NET_NODE, callable:Callable):
	#if custom_net_node:
		#if multiplayer.get_unique_id() == 1 && not g_man.self_send:
			#return true
		#return false
	#var node = CUSTOM_NET_NODE.instantiate()
	#config_net_custom(id, node)
	#custom_net_node = node
	#if multiplayer.get_unique_id() == 1:
		#server_net_node = node
	#if multiplayer.get_unique_id() != 1 || g_man.self_send:
		#callable.call()
	#return true
	##endregion create custom net node
	#region remove net managers
func destroy_me(server):
	if net_social_node:
		net_social_node.queue_free()
	if net_corg_node:
		net_corg_node.queue_free()
	net_social_node = null
	net_corg_node = null
	#endregion remove net managers
#endregion end create net managers
#region remove peers
@rpc("call_local", "any_peer", "reliable")
func rpc_disconnect_peer(id):
	pass

func clean_yourself():
	pass

@rpc("call_local", "any_peer", "reliable")
func cmd_disconnect_all_players():
	var node = login_intro()
	if node:
		if node.client.user_level == Client.ADMIN_USER_LEVEL:
			multiplayer.multiplayer_peer.disconnect_peer(1)
			multiplayer.multiplayer_peer.close()
			await get_tree().create_timer(16).timeout
			get_tree().quit()
		else:
			node.client.make_fraud()
#endregion remove peers
#region security
	#region macs
@rpc("call_local", "any_peer", "reliable")
func cmd_check_id_mac(id, id_mac):
	var node = login_intro()
	#var unwelcome_mac = g_man.savable_multi_server_client__mac.get_all(node.client.id, id)
	var mac:Mac = Mac.get_index_data(id_mac)
	target_refresh_id_mac.rpc_id(node.id_net, id, mac._str_mac)

@rpc("call_local", "any_peer", "reliable")
func target_refresh_id_mac(id, mac):
	if multiplayer.get_remote_sender_id() == 1:
		g_man.welcome_unwelcome_window.container[id].refresh(mac)

@rpc("call_local", "any_peer", "reliable")
func cmd_change_mac_status(ser_mac):
	var node = login_intro()
	if node:
		var mac:UnwelcomeMac = Serializable.deserialize(UnwelcomeMac.new(), ser_mac)
		if node.client.came_in_with_other_computer:
			target_instructions.rpc_id(node.id_net, ["you are trying access macs that aint yours", "you cannot do"])
			g_man.savable_permanent_unwelcome_mac.get_index_data(mac.id_mac)
			#node.client.MakeFraud()
			return
		var m:Mac = Mac.get_index_data(mac.id_mac)
		if node._macs[0] == m._str_mac:
			target_instructions.rpc_id(node.id_net, ["you are trying to ban your self", "you cannot do"])
			g_man.savable_permanent_unwelcome_mac.get_index_data(mac.id_mac)
			#node.client.MakeFraud()
			return
		var unwelcome:UnwelcomeMac = g_man.savable_multi_server_client__mac.get_all(node.client.id, mac.id_mac)
		unwelcome.change_status(mac.approved, true)

@rpc("call_local", "any_peer", "reliable")
func cmd_change_mac_to_approved(id_mac):
	var node = login_intro()
	if node:
		var unwelcome:UnwelcomeMac = g_man.savable_multi_server_client__mac.get_all(node.client.id, id_mac)
		if unwelcome.wait_time and unwelcome.wait_time < Time.get_unix_time_from_system():
			unwelcome.change_status(UnwelcomeMac.approving.APPROVED, false)
		else:
			unwelcome.make_wait_time()
		var ser_mac = Serializable.serialize([unwelcome])
		target_add_changed_mac.rpc_id(node.id_net, ser_mac)

@rpc("call_local", "any_peer", "reliable")
func target_add_changed_mac(ser_mac):
	g_man.welcome_unwelcome_window.add_macs(ser_mac)
	#endregion macs
	#region passwords and how to get in
@rpc("call_local", "any_peer", "reliable")
func cmd_change_security(
	clientCanGetIn,
	computerCanGetIn,
	old_encrypted_password,
	new_encrypted_password,
):
	var node = login_intro()
	if node:
		if node.client.came_in_with_other_computer:
			target_instructions.rpc_id(node.id_net, ["you cannot change security settings", "it is not your owned account"])
			return
		var encrypt:EncriptData = node.encrypted
		var old_pass = EncriptData.synchronous_decrypting(old_encrypted_password, encrypt.secret_key)
		if node.client.load_return_password() != old_pass:
			target_instructions.rpc_id(node.id_net, ["you cannot change security settings", "old password is not correct"])
			return
		
		node.client.other_client_can_get_in = clientCanGetIn
		node.client.other_computers_can_get_in = computerCanGetIn
		node.client.save_security_protocol()
		var array
		if new_encrypted_password:
			node.client._password = EncriptData.synchronous_decrypting(new_encrypted_password, encrypt.secret_key)
			node.client.save_password()
			node.client.save_secret_key(0)
			array = ["you have sucessfuly updated", "security protocol", "password"]
		else:
			array = ["you have sucessfuly updated", "security protocol"]
		target_instructions.rpc_id(node.id_net, array)
	#endregion passwords and how to get in
#endregion security
#region get client
@rpc("call_local", "any_peer", "reliable")
func get_client_data(id_server):
	var node = login_intro()
	if node:
		var _client = g_man.savable_server_accounts.get_index_data(id_server)
		if _client:
			var array_client = Serializable.serialize([_client])
			target_return_client_data.rpc_id(node.id_net, array_client)

@rpc("call_local", "any_peer", "reliable")
func target_return_client_data(array_client):
	var clients = Serializable.deserialize(Client.new(), array_client)
	var client_client = Client.construct_for_client_new_id(clients[0].id_server, clients[0]._username)
	g_man.client_signal.emit(client_client)
	for item in g_man.client_signal.get_connections():
		g_man.client_signal.disconnect(item.callable)
#endregion get client
#region corg
@rpc("call_local", "any_peer", "reliable")
func cmd_send_id_picture_to_server(raw_face, raw_id, emso):
	var node = login_intro()
	if node:
		var pic_set = node.client.set_picture_raw_datas(raw_face, raw_id, emso)
		if pic_set is bool:
			if pic_set:
				g_man.local_server_network_node.net_corg_node.target_confirm_picture_received.rpc_id(node.id_net)
			else:
				g_man.local_server_network_node.target_instructions.rpc_id(node.id_net, ["picture size is too large"])
			return
		g_man.local_server_network_node.target_instructions.rpc_id(node.id_net, ["please wait patiently", "your proposal is being unwer carefull eye"])
		g_man.local_server_network_node.net_corg_node.add_id(node, emso)

@rpc("call_local", "any_peer", "reliable")
func cmd_delete_id_active_law_suggested():
	var node = login_intro()
	if node:
		var id = node.client.load_return_id_active_law_suggested()
		if id:
			var law:Law = g_man.savable_multi_law_type__law.get_index_data(id)
			if law:
				if law.id_poster == node.client.id:
					g_man.savable_multi_law_type__law.delete_id_row(id)
		node.client.save_id_active_law_suggested(0)
#endregion corg
#region admin
@rpc("call_local", "any_peer", "reliable")
func target_change_id_name(array___id__username):
	for id_username in array___id__username:
		g_man.admin_manager.change_id_name(id_username)

@rpc("call_local", "any_peer", "reliable")
func target_add_players(ids):
	if multiplayer.get_remote_sender_id() == 1:
		g_man.admin_manager.add_ids_player(ids)
#endregion admin
