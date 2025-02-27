class_name Law extends ISavable
#region inputs
@onready var header_button: Button = $"header button"
@onready var law_body: Label = $"law body"
@onready var vote_check_box: CheckBox = $vote
@onready var voted_container: HBoxContainer = $"voted container"
@onready var total_voted_container: HBoxContainer = $"total voted container"
@onready var voted_progress_bar: ProgressBar = $"voted container/voted progress bar"
@onready var total_voted_progress_bar: ProgressBar = $"total voted container/total voted progress bar"

var law_type
var header_text
var body_text = ""
var id_poster

var up_vote = 0
var people_voted

var deleted
var accepted_law

var id_people_voted
#endregion
#region buttons tool
# custom how to set text by data provided
func set_text(text):
	if text is Law:
		header_text = text.get_text()
		header_button.text = str(text.header_text)
		law_body.text = text.body_text
		up_vote = text.up_vote
		people_voted = text.people_voted
		deleted = text.deleted
		accepted_law = text.accepted_law
		if people_voted:
			voted_progress_bar.value = text.up_vote / float(people_voted) * 100
		else:
			voted_progress_bar.value = 0
		total_voted_progress_bar.value = people_voted / float(g_man.client_total_persons_on_corg_count) * 100
	else:
		header_text = text

func get_text():
	return header_text

func on_click_add_listener(on_button_click:Callable):
	vote_check_box.pressed.connect(
		func():
			on_button_click.call(id, vote_check_box.button_pressed)
	)
#endregion buttons tool
#region buttons work
func on_header_button_pressed(button):
	if button:
		law_body.show()
		vote_check_box.show()
		voted_container.show()
		total_voted_container.show()
	else:
		law_body.hide()
		vote_check_box.hide()
		voted_container.hide()
		total_voted_container.hide()
#endregion buttons work
#region vote system
func add_vote(id_voter, vote):
	if deleted:
		return
	var vote_system = g_man.savable_multi_law__voter.new_data(id, id_voter)
	if vote_system.change_vote(vote):
		id_people_voted = g_man.savable_multi_law__voter.get_right_rows()
		people_voted = len(id_people_voted)
		var people_count = g_man.stat_total_persons_on_corg_count + 0.0001
		if vote:
			up_vote += 1
			# milestone
			if up_vote / people_count > 0.65:
				if ! accepted_law:
					add_remove_honor()
					# inform the poster
					mark_law_to_inform_the_poster(false)
					# move it to approved
					g_man.savable_multi_law_type__law.move_data(law_type, 0, self)
		else:
			up_vote -= 1
			# how many have down voted
			var down_vote = people_voted - up_vote
			# milestone
			# more than 50% people don't agree with this law delete it and downgrade the poster
			# more than 65% people doesn't agree with already accepted law delete it and downgrade poster
			var mile_stone = 0.5
			if accepted_law:
				mile_stone = 0.65
			if down_vote / people_count > mile_stone:
				add_remove_honor()
				# inform the poster
				mark_law_to_inform_the_poster(true)
				# if it was already informed just delete it
				delete_law()
				# delete all voters from law
				g_man.savable_multi_law__voter.delete_p_s(id, 0)
		DataBase.insert(_server, g_man.dbms, _path, "up", id, up_vote)



func add_remove_honor():
	var honor = up_vote - (people_voted - up_vote) * 1.5
	var client:Client = g_man.savable_server_accounts.get_index_data(id_poster)
	client.add_save_honor(honor)

func mark_law_to_inform_the_poster(delete):
	deleted = delete
	accepted_law = !delete
	save_deleted()
	DataBase.insert(_server, g_man.dbms, _path, "accepted", id, accepted_law)

func delete_law():
	var client:Client = g_man.savable_server_accounts.get_index_data(id_poster)
	if client:
		if client.load_return_id_active_law_suggested() != id:
			deleted = true
			save_deleted()
			g_man.savable_multi_law_type__law.delete_id_row(id)

#endregion vote system
#region savable
func copy():
	return Law.new()

func save_deleted():
	DataBase.insert(_server, g_man.dbms, _path, "deleted", id, deleted)

func fully_save():
	DataBase.insert(_server, g_man.dbms, _path, "header", id, header_text)
	DataBase.insert(_server, g_man.dbms, _path, "text", id, body_text)
	DataBase.insert(_server, g_man.dbms, _path, "type", id, law_type)
	DataBase.insert(_server, g_man.dbms, _path, "id_poster", id, id_poster)
	DataBase.insert(_server, g_man.dbms, _path, "up", id, up_vote)
	DataBase.insert(_server, g_man.dbms, _path, "accepted", id, accepted_law)
	save_deleted()
	
func fully_load():
	header_text = DataBase.select(_server, g_man.dbms, _path, "header", id)
	body_text = DataBase.select(_server, g_man.dbms, _path, "text", id)
	law_type = DataBase.select(_server, g_man.dbms, _path, "type", id)
	id_poster = DataBase.select(_server, g_man.dbms, _path, "id_poster", id)
	up_vote = DataBase.select(_server, g_man.dbms, _path, "up", id)
	accepted_law = DataBase.select(_server, g_man.dbms, _path, "accepted", id)
	deleted = DataBase.select(_server, g_man.dbms, _path, "deleted", id)
#endregion savable
#region serialize
func serialize():
	var data = []
	data.push_back(id)
	data.push_back(header_text)
	data.push_back(body_text)
	data.push_back(law_type)
	data.push_back(id_poster)
	data.push_back(up_vote)
	data.push_back(accepted_law)
	data.push_back(deleted)
	id_people_voted = g_man.savable_multi_law__voter.get_right_rows()
	data.push_back(len(id_people_voted))
	return data
	
func deserialize(data:Array):
	people_voted = data.pop_back()
	deleted = data.pop_back()
	accepted_law = data.pop_back()
	up_vote = data.pop_back()
	id_poster = data.pop_back()
	law_type = data.pop_back()
	body_text = data.pop_back()
	header_text = data.pop_back()
	id = data.pop_back()
	return data
#endregion serialize
