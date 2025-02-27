class_name VoteSystem extends ISavable

#region inputs
var vote = false
var id_voter = false
#endregion
#region change vote
func change_vote(new_vote):
	if new_vote == vote:
		return false
	vote = new_vote
	save_vote()
	return true

#endregion change vote
#region savable
func copy():
	return VoteSystem.new()

func save_vote():
	DataBase.insert(_server, g_man.dbms, _path, "vote", id, vote)

func fully_save():
	DataBase.insert(_server, g_man.dbms, _path, "id_client", id, id_voter)
	save_vote()

func fully_load():
	vote = DataBase.select(_server, g_man.dbms, _path, "vote", id)
	id_voter = DataBase.select(_server, g_man.dbms, _path, "id_client", id)
#endregion Savable
