class_name QuestObject extends Resource

# Define an enum for TypeActivated
enum TypeActivated {
	ALIVE,
	DEAD,
	DEACTIVATE,
	ACTIVATED
}
@export var quest_name: String
@export var position: Vector3
@export var quest_body_type: Enums.Esprite = Enums.Esprite.empty_visual
@export var equipment: Enums.Esprite = Enums.Esprite.nul
@export var activated: bool = false
var quest_index
@export var list_quest_basis: Array[QuestBasis]

#region open ai
#var api_key: String = ""
#var url: String = "https://api.openai.com/v1/chat/completions"
#var temperature: float = 0.5
#var max_tokens: int = 1024
#var headers = ["content-type: application/json", "Authorization: Bearer " + api_key]
#var model: String = "gpt-3.5-turbo"
#var messages = []
#var request: HTTPRequest
#
#func set_request(setting_request):
	#request = setting_request
	#request.request_completed.connect(on_request_completed)
	#
	#dialog_request("how to fuck")
#
#func dialog_request(player_dialogue):
	#messages.push_back(
		#{
			#"role": "user",
			#"content": player_dialogue
		#}
	#)
	#var body = JSON.new().stringify({
		#"messages": messages,
		#"temperature": temperature,
		#"max_tokens": max_tokens,
		#"model": model
	#})
	#var send_request = request.request(url, headers, HTTPClient.METHOD_POST)
	#print("does it even get here")
	#if send_request != OK:
		#push_error("there was an error sending message")
		#printerr("there was an error sending message")
#
#func on_request_completed(_result, _response_code, _headers, body):
	#var json:JSON = JSON.new()
	#json.parse(body.get_string_from_utf8())
	#var response = json.get_data()
	#var message = response["choices"][0]["message"]["content"]
	#
	#print(message)
#endregion open ai

# Create NPC on server-side
func generate_npc(index: int) -> void:
	quest_index = index

# Create NPC on server for client
func create_npc_with_avatar(id_avatar: int):
	var server_quest: ServerQuest = g_man.savable_multi_avatar__quest_data.new_data(id_avatar, quest_index, 0)
	server_quest._quest_index = quest_index
	server_quest.fully_load()
	if server_quest.activated:
		return server_quest
	
	config(server_quest)
	if server_quest.activated:
		return server_quest

# Configure the NPC
func config(server_quest: ServerQuest) -> void:
	if not server_quest.initialized:
		server_quest.position = position
		server_quest.activated = activated
		server_quest.load_inventory()

# Get a quest question based on basis and text input
func get_quest_question(basis: int, text: String):
	if list_quest_basis.size() <= basis or basis < 0:
		push_error("NO quests for " + quest_name + ": " + str(basis) + ", count: " + str(list_quest_basis.size()))
		return null
	
	var q_basis = list_quest_basis[basis]
	potential_load_basis(basis)
	
	var qqs = q_basis.list_quest_questions
	

	# Iterate over each item in the qq array
	for qq: QuestQuestion in qqs:
		# Check if any of the list_avatar_dialog items match the text
		if qq.list_avatar_dialog.any(
			func(sentence):
				return all_words_match(sentence, text)
		):
			return qq
	return null

# Check if all words match between two strings
func all_words_match(dialog_text: String, input_text: String) -> bool:
	var all_words: PackedStringArray = dialog_text.split(" ", true)
	var all_words_text = input_text.split(" ", true)
	
	##TODO work around a bug (function doesn't exist in PackedStringArray)
	var _all_words: Array[String]
	for word in all_words:
		_all_words.push_back(word)
	
	var count = all_words.size()
	
	for word in all_words_text:
		# check if any all_words are same as all_words_text
		if _all_words.any(
			func(a_word):
				return a_word == word
		):
			count -= 1
	return count == 0


# Potentially load basis questions
func potential_load_basis(basis: int) -> void:
	if list_quest_basis[basis].dict_quest_questions.size() == 0:
		list_quest_basis[basis].update_basis()
