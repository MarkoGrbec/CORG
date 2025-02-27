class_name Spender extends ISavable
#region input
@onready var spender_username: Button = $"spender username"
@onready var spending_for: Label = $"spending for"
@onready var vote_check_box: CheckBox = $vote
@onready var voted_container: HBoxContainer = $"voted container"
@onready var total_voted_container: HBoxContainer = $"total voted container"
@onready var voted_progress_bar: ProgressBar = $"voted container/voted progress bar"
@onready var total_voted_progress_bar: ProgressBar = $"total voted container/total voted progress bar"

var spending_for_text
var id_client
var up_vote = 0
var people_voted = 0
#endregion input
#region button tool
## custom how to set text by data provided
func set_text(text):
	if text is Spender:
		spending_for_text = text.get_text()
		var client:Client = Client.construct_for_client_new_id(text.id_client, "")
		spender_username.text = client._username
		spending_for.text = str(text.spending_for_text)
		up_vote = text.up_vote
		people_voted = text.people_voted
		if not people_voted:
			people_voted = 0.001
		if people_voted:
			voted_progress_bar.value = text.up_vote / float(people_voted) * 100
		else:
			voted_progress_bar.value = 0
		total_voted_progress_bar.value = people_voted / float(g_man.client_total_persons_on_corg_count) * 100
	else:
		spending_for_text = text

## custom how to return only one text: String
func get_text():
	return spending_for_text

func on_click_add_listener(on_button_click:Callable):
	vote_check_box.pressed.connect(
		func():
			on_button_click.call(id, vote_check_box.button_pressed)
	)
#endregion button tool
#region expand button pressed
func on_spender_button_pressed(button):
	if button:
		spending_for.show()
		vote_check_box.show()
		voted_container.show()
		total_voted_container.show()
	else:
		spending_for.hide()
		vote_check_box.hide()
		voted_container.hide()
		total_voted_container.hide()
#endregion expand button pressed
#region vote system
func add_vote(type, id_voter, vote):
	var vote_system:VoteSystem = g_man.savable_multi_id_client_spender__id_voter_vote_system.new_data(id_client, id_voter)
	vote_system.id_voter = id_voter
	if type == 3:# it's banned voter can't vote up again
		if vote:
			return
	# if it's banned voter can still down vote
	if vote_system.change_vote(vote):
		var id_voters = g_man.savable_multi_id_client_spender__id_voter_vote_system.get_right_rows(id_client)
		people_voted = len(id_voters)
		var people_count = g_man.stat_total_persons_on_corg_count
		if vote:
			up_vote += 1
			# milestone
			if up_vote / float(people_count) > 0.65:
				var accepted_spender = g_man.savable_multi_type__spender.select(0, id_client)
				if accepted_spender[0] != 3 && accepted_spender[0] != 2:
					add_remove_honor()
					#//move it to approved
					g_man.savable_multi_type__spender.move_data(2, id_client, self)
		else:
			up_vote -= 1
			# how many have down voted
			var downVote = people_voted - up_vote
			# milestone
			# more than 50% people don't agree with this spender downgrade the spender forever
			if downVote / float(people_count) > 0.5:
				var accepted_spender = g_man.savable_multi_type__spender.select(0, id_client)
				if accepted_spender[0] != 3:
					add_remove_honor()
					# move it to banned
					g_man.savable_multi_type__spender.move_data(3, id_client, self)
		save_up_vote(up_vote)

func add_remove_honor():
	var honor = up_vote - (people_voted - up_vote) * 1.5
	var client:Client = g_man.savable_server_accounts.get_index_data(id_client)
	if client:
		client.add_save_honor(honor)
#endregion vote system
#region savable
func copy():
	return Spender.new()
	
func partly_save():
	pass
	
func fully_save():
	pass

func save_spending_for_text(_spending_for):
	DataBase.insert(_server, g_man.dbms, _path, "text", id, _spending_for)

func save_id_client(_id_client):
	id_client = _id_client
	DataBase.insert(_server, g_man.dbms, _path, "id_client", id, _id_client)

func save_up_vote(vote):
	DataBase.insert(_server, g_man.dbms, _path, "up_vote", id, vote)


func partly_load():
	pass
	
func fully_load():
	load_id_client()
	load_up_vote()

func load_return_spending_for_text():
	return DataBase.select(_server, g_man.dbms, _path, "text", id)

func load_id_client():
	id_client = DataBase.select(_server, g_man.dbms, _path, "id_client", id)

func load_up_vote():
	up_vote = DataBase.select(_server, g_man.dbms, _path, "up_vote", id)
	if not up_vote:
		up_vote = 0
#endregion savable
#region serialize
func serialize():
	var id_voters = g_man.savable_multi_id_client_spender__id_voter_vote_system.get_right_rows(id_client)
	if id_voters:
		people_voted = len(id_voters)
	else:
		people_voted = 0
	var data = []
	data.push_back(id)
	data.push_back(up_vote)
	data.push_back(id_client)
	data.push_back(people_voted)
	data.push_back(load_return_spending_for_text())
	return data
	
func deserialize(data:Array):
	spending_for_text = data.pop_back()
	people_voted = data.pop_back()
	id_client = data.pop_back()
	up_vote = data.pop_back()
	id = data.pop_back()
	return data
#endregion serialize
