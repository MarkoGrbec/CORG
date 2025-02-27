class_name NetSocial extends Node

@warning_ignore("unused_private_class_variable")
var _name

#region intero
func intro():
	if get_multiplayer_authority() != 1:
		push_warning("is not server")
		return
	var node:NetworkNode = g_man.dict_id_unique__connected_node[multiplayer.get_remote_sender_id()]
	if not node.secure_connection:
		push_warning("connection failed it's not secure")
		node.target_instructions.rpc_id(node.id_net, ["your connection isn't secure"])
		return
	return node
#region intro
#region Forum
	#region Make
@rpc("call_local", "any_peer", "reliable")
func cmd_create_forum(id_father, thread_name, _body, _type):
	printerr("server net social")
	var node = intro()
	if node:
		if id_father == 0:
			var forum = g_man.savable_multi_forum__forum_threads.get_all(1, 1)
			target_returns_threads.rpc_id(node.id_net, 1, 1)
			push_warning("father: ", id_father)
			return
		var new_forum:Forum = g_man.savable_multi_forum__forum_threads.new_data(id_father, 0)
		new_forum.id_father = id_father
		new_forum.id_client = node.client.id
		new_forum.thread_name = thread_name
		new_forum.fully_save()
		target_returns_threads.rpc_id(node.id_net, id_father, new_forum.id)

#endregion endMake
	#region forum

@rpc("call_local", "any_peer", "reliable")
func cmd_get_forums(id_father, _start_at = 0):
	var node = intro()
	if node:
		var thread
		if id_father == 0:
			target_returns_threads.rpc_id(node.id_net, [1], 1)
		else:
			thread = g_man.savable_multi_forum__forum_threads.get_all(id_father, 0)
			var ids = Serializable.serialize_ids(thread)
			target_returns_threads.rpc_id(node.id_net, ids, id_father)

@rpc("call_local", "any_peer", "reliable")
func target_returns_threads(ids:Array, id_father):
	g_man.social.forum_add_buttons(ids, id_father)

@rpc("call_local", "any_peer", "reliable")
func cmd_get_forum(id_thread):
	var node = intro()
	if node:
		var thread = g_man.savable_multi_forum__forum_threads.get_index_data(id_thread)
		if thread:
			#push_error("thread", thread.type, " ", thread.id);
			var array = Serializable.serialize([thread])
			target_returns_thread.rpc_id(node.id_net, array);
		# only 1 can be first father
		elif id_thread == 1:
			var forum = g_man.savable_multi_forum__forum_threads.new_data(1, 1)
			forum.id_father = 1
			forum.id_client = node.client.id
			forum.thread_name = "thread_name"
			forum.fully_save()
			var array = Serializable.serialize([forum])
			target_returns_thread.rpc_id(node.id_net, array);

@rpc("call_local", "any_peer", "reliable")
func target_returns_thread(thread:Array):
	var forum = Serializable.deserialize(Forum.new(), thread)
	forum = forum[0]
	#push_error("load thread", forum.id, " ", forum.body, " ", forum.type, " ", forum.id_father)
	g_man.social.forum_button_tool.refresh_t(forum.id, forum, forum.id_father)
	#endregion forum
	#region post

@rpc("call_local", "any_peer", "reliable")
func cmd_create_post(id_father, header_text, body_text):
	var node = intro()
	if node:
		var forum_post = g_man.savable_multi_forum__post.new_data(id_father, 0)
		forum_post.id_father = id_father
		forum_post.id_client = node.client.id
		forum_post.thread_name = header_text
		forum_post.body = body_text
		forum_post.fully_save()
		printerr("forum post made", forum_post.id)
		target_returns_posts.rpc_id(node.id_net, [forum_post.id], id_father)

@rpc("call_local", "any_peer", "reliable")
func cmd_get_posts(id_father):
	var node = intro()
	if node:
		var posts = g_man.savable_multi_forum__post.get_all(id_father, 0)
		var ids = Serializable.serialize_ids(posts)
		target_returns_posts.rpc_id(node.id_net, ids, id_father);

@rpc("call_local", "any_peer", "reliable")
func target_returns_posts(ids, id_father = 0):
	g_man.social.post_add_buttons(ids, id_father)

@rpc("call_local", "any_peer", "reliable")
func cmd_get_post(id_post):
	var node = intro()
	if node:
		var post = g_man.savable_multi_forum__post.get_index_data(id_post)
		if post:
			var array = Serializable.serialize([post])
			target_returns_post.rpc_id(node.id_net, array)

@rpc("call_local", "any_peer", "reliable")
func target_returns_post(array_post:Array):
	var post = Serializable.deserialize(Post.new(), array_post)
	post = post[0]
	g_man.social.post_button_tool.refresh_t(post.id, post, post.id_father)
#endregion post
#region comment
@rpc("call_local", "any_peer", "reliable")
func cmd_create_comment(id_father, body):
	var node = intro()
	if node:
		var comment = g_man.savable_multi_post__comment.new_data(id_father, 0)
		comment.id_father = id_father
		comment.id_client = node.client.id
		comment.body = body
		comment.fully_save()
		printerr("forum post made", comment.id)
		target_returns_comments.rpc_id(node.id_net, [comment.id], id_father)

@rpc("call_local", "any_peer", "reliable")
func cmd_get_comments(id_father):
	var node = intro()
	if node:
		var comments = g_man.savable_multi_post__comment.get_all(id_father, 0)
		var ids = Serializable.serialize_ids(comments)
		target_returns_comments.rpc_id(node.id_net, ids, id_father);

@rpc("call_local", "any_peer", "reliable")
func target_returns_comments(ids, id_father):
	g_man.social.comment_add_buttons(ids, id_father)

@rpc("call_local", "any_peer", "reliable")
func cmd_get_comment(id_comment):
	var node = intro()
	if node:
		var comment = g_man.savable_multi_post__comment.get_index_data(id_comment)
		if comment:
			var array = Serializable.serialize([comment])
			target_returns_comment.rpc_id(node.id_net, array)

@rpc("call_local", "any_peer", "reliable")
func target_returns_comment(array_comment:Array):
	var comment = Serializable.deserialize(Comment.new(), array_comment)
	comment = comment[0]
	g_man.social.comment_button_tool.refresh_t(comment.id, comment, comment.id_father)

#public void TargetReturnsComments(NetworkConnection target, long id_father, params long[] ids){
	#try{
		#ForumManager.Sin.ReturnsComments(id_father, ids);
	#}
	#catch (System.Exception e){Debug.LogError(e);}
#}
	
	
	
	
	
	
	
	
	#else if(type == ForumThread.Type.comment){
		#Debug.LogError("comment NOW YESS!!!");
		#ForumComment forumComment = new ForumComment(thread_name, id_father, client.ID, body);
		#ForumManager.Sin.savableForumComments.Set(forumComment);
		#ForumManager.Sin.multiPostComment.AddRow(0, id_father, forumComment.ID);
		#ids = ForumManager.Sin.multiPostComment.Select(id_father, 0);
		#forumComment.type = type;
		#forumComment.Save(); 
		#TargetReturnsComments(client.netId, id_father, ids);
		#
		
		
		
		
	#[ServerRpc]
	#public void cmdGetComments(long idPost){
		#try{
			#long[] ids = ForumManager.Sin.multiPostComment.Select(idPost, 0);
			#//Debug.LogError($"{ids[0]} WTF");
			#TargetReturnsComments(client.netId, idPost, ids);
		#}
		#catch (System.Exception e){Debug.LogError(e);}
	#}
	#[ServerRpc]
	#public void cmdGetComment(long idPost){
		#try{
			#ForumComment comment = ForumManager.Sin.savableForumComments.Get(idPost);
			#Debug.Log($"comment {comment.type} {comment.ID}");
			#TargetReturnsComment(client.netId, comment);
		#}
		#catch (System.Exception e){Debug.LogError(e);}
	#}
	#[TargetRpc]
	#public void TargetReturnsComment(NetworkConnection Target, ForumComment comment){
		#try{
			#Debug.Log($"load thread {comment.ID}, {comment.body} {comment.type}");
			#ForumManager.Sin.RefreshComment(comment);
		#}
		#catch (System.Exception e){Debug.LogError(e);}
	#}
		##endregion end comment
	##endregion end Forum
