class_name EncriptData extends Node

const keyNumbers = 16

const LARGE_P: int = 15269
const P: int = 127
const GROUND: int = 7
var privateKey: Array = []
var publicKey: Array = []
var secret_key: Array = []
var biggestPrivateKey: int = 10
var verificationPrivate: int = 0  # for getting inside without using password
var verificationPublic: int = 0  # for getting inside without using password
var raw_verification_secret: int = 0  # for getting inside without using password

var _rsa_private_key: CryptoKey

var random = RandomNumberGenerator.new()

func _init():
	privateKey.resize(keyNumbers)
	publicKey.resize(keyNumbers)
	secret_key.resize(keyNumbers)

func reset_me():
	pass

func Pow(bas: int, power: int, devide: int):
	var result: int = bas
	for i in range(1, power):
		result = (result * bas) % devide
	return result

#region asinhron encription
	#region first call
## start Getting public keys
## create public keys from 0 first call
func get_public_keys_first_call():
	for i in range(len(publicKey)):
		random.randomize()
		privateKey[i] = random.randi_range(2, biggestPrivateKey)
		publicKey[i] = Pow(GROUND, privateKey[i], P)
	return publicKey

## create public key from 0 first call, server calls
func get_public_key_first_call():
	random.randomize()
	verificationPrivate = random.randi_range(2, biggestPrivateKey)
	verificationPublic = Pow(GROUND, verificationPrivate, LARGE_P)
	return verificationPublic
	#endregion end first call
	#region second call make keys from public keys
## make public keys and secret keys
## create public from public keys and secret keys
func get_public_keys_second_call(client_public_keys: Array):
	for i in range(len(publicKey)):
		random.randomize()
		privateKey[i] = random.randi_range(2, biggestPrivateKey)
		publicKey[i] = Pow(GROUND, privateKey[i], P)
		secret_key[i] = Pow(client_public_keys[i], privateKey[i], P)
	return publicKey

## create public key from public key and secret key, client calls
func get_public_key_second_call(server_public_key: int):
	random.randomize()
	verificationPrivate = random.randi_range(2, biggestPrivateKey)
	verificationPublic = Pow(GROUND, verificationPrivate, LARGE_P)
	raw_verification_secret = Pow(server_public_key, verificationPrivate, LARGE_P)
	return verificationPublic
	#endregion end second call make keys from public keys
	#region make secret keys from public keys last call
## last getting security keys
## fetch public keys and make last secret keys
func make_client_secret_keys(server_public_keys: Array):
	for i in range(len(publicKey)):
		secret_key[i] = Pow(server_public_keys[i], privateKey[i], P)

## fetch public key and make last secret key, server calls and stops
func make_server_secret_key(client_public_key: int):
	raw_verification_secret = Pow(client_public_key, verificationPrivate, LARGE_P)
	return raw_verification_secret
	#endregion end make secret keys from public keys last call
#endregion end asinhron encription
#region RSA GoDot encryption
func get_rsa_encrypted_private_string():
	if(len(secret_key) != keyNumbers):
		return []
	var crypto = Crypto.new()
	_rsa_private_key = crypto.generate_rsa(4096)
	var raw_private_string = _rsa_private_key.save_to_string(false)
	return EncriptData.synchronous_encrypting(raw_private_string, secret_key)
	
func rsa_decrypt_private_string(encrypted_rsa):
	var private_string = EncriptData.synchronous_decrypting(encrypted_rsa, secret_key)
	_rsa_private_key = CryptoKey.new()
	_rsa_private_key.load_from_string(private_string, false)

func rsa_encrypt_data(data):
	var c = Crypto.new()
	return c.encrypt(_rsa_private_key, data.to_utf8_buffer())

func rsa_decrypt_data(data):
	var c = Crypto.new()
	return c.decrypt(_rsa_private_key, data)

func save_rsa(server: bool, idClient: int):
	DataBase.insert(server, "DBMS", "person", "rsa private", idClient, _rsa_private_key.save_to_string(false), "equals")
#endregion RSA GoDot encryption
#region sinhron encryption
# all secret keys are unique untill the linear starts
# multi are 5 keys that combines secret keys
# start is making multis from beginning
	#region combined keys
static func combined_key(secret_keys: Array, mk: Array, start: bool, devide: int):
	if start:
		mk = multi_key_reset(mk)
		start = false
	mk = multi_key_plus_plus(mk, len(secret_keys))

	var result: int = 1
	for i in range(len(mk)):
		result = (result * secret_keys[mk[i]]) % devide
	return [result, mk, start]
	#endregion combined keys
	#region synchronous encrypting
static func synchronous_encrypting(text: String, sec_key: Array):
	if text == "" or sec_key == null:
		return []
	var encript: Array = []
	var multi: Array = [0, 0, 0, 0, 0, 0, 0]
	var start: bool = true
	var unique_key: int
	for i in range(len(text)):
		var data = combined_key(sec_key, multi, start, 97)#97
		unique_key = data[0]
		multi = data[1]
		start = data[2]
		var i_data: int = text[i].to_utf8_buffer()[0]
		encript.push_back(i_data + unique_key)
	return encript
	#endregion sinhronous encrypting
	#region synchronous decrypting
static func synchronous_decrypting(decript: Array, sec_key: Array):
	if decript == null or sec_key == null:
		return ""
	var c = ""
	var multi: Array = [0, 0, 0, 0, 0, 0, 0]
	var start: bool = true
	var unique_key: int
	for i in range(len(decript)):
		var data = combined_key(sec_key, multi, start, 97)#97
		unique_key = data[0]
		multi = data[1]
		start = data[2]
		decript[i] = decript[i] - unique_key
		c = String("{c}{add}").format({c = c, add = char(decript[i])})
	return c
	#endregion synchronous decrypting
	#region synchronous encrypting int
static func synchronous_encrypting_int(data: int, secret_keys):
	for i in 4:
		data *= secret_keys[i]
	return data
	#endregion synchronous encrypting int
	#region synchronous decrypting int
static func synchronous_decrypting_int(data: int, secret_keys):
	for i in 4:
		data /= secret_keys[i]
	return data
#endregion synchronous decrypting int
	#region next unique key of combined multi keys
static func multi_key_plus_plus(mk: Array, wall: int):
	for i in range(len(mk)):
		if i + 1 == len(mk):
			mk = multi_key_reset(mk)
			return mk
		if mk[i] != wall - i - 1:
			mk[i] += 1
			return mk
		elif(mk[i + 1] != wall - i - 2):
			mk[i + 1] += 1
			for x in range(i, -1, -1):
				mk[x] = mk[x + 1] + 1
			return mk
	#endregion next unique key of combined multi keys
	#region reset multi keys to linear stairs 1 - 2 - 3, ...
static func multi_key_reset(mk: Array):
	## for debugging
	reset = true
	## end debugging
	
	for i in range(len(mk)):
		mk[i] = len(mk) - 1 - i
	return mk
	#endregion reset multi keys to linear stairs 1 - 2 - 3, ...
#endregion sinhron encryption
#region debugging
# on 7 kmulti keys there's 19448 differen't combinations of 16 byte keys
static var keys_count = 0
static var reset = false

static func debug_encrypt_keys_count():
	var mk = [0, 0, 0, 0, 0, 0, 0]
	mk = multi_key_reset(mk)
	reset = false

	for x in range(20000):
		if not reset:
			keys_count += 1
		mk = multi_key_plus_plus(mk, 16)

	for i in range(len(mk)):
		print(mk[i])
	print(keys_count)
#endregion debugging
