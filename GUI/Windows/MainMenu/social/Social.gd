class_name Social extends Control

func _ready():
	g_man.social = self
	forum_button_tool = ButtonTool.new(FORUM, null, forum_clicked, cmd_get_forum, forum_container)
	post_button_tool = ButtonTool.new(POST, null, post_clicked, cmd_get_post, null)
	comment_button_tool = ButtonTool.new(COMMENT, null, comment_clicked, cmd_get_comment, null)
	comment_comment_button_tool = ButtonTool.new(COMMENT, null, comment_comment_clicked, cmd_get_comment_comment, forum_container)

const FORUM = preload("res://GUI/Windows/MainMenu/social/forum/forum/Forum.tscn")
const POST = preload("res://GUI/Windows/MainMenu/social/forum/post/Post.tscn")
const COMMENT = preload("res://GUI/Windows/MainMenu/social/forum/comment/comment.tscn")

@onready var forum_container = $forum/MarginContainer/forum


var forum_button_tool:ButtonTool
var post_button_tool:ButtonTool
var comment_button_tool:ButtonTool
var comment_comment_button_tool:ButtonTool

enum type{
	THREAD = 1,
	POST = 2,
	COMMENT = 3
}

#func make_forum_button(id_father, ids):
	#forum_button_tool.add_buttons(ids, id_father)
func send():
	if not g_man.local_network_node.net_social_node:
		g_man.local_network_node.add_net_custom.rpc_id(1, 1)

func start():
	g_man.local_network_node.net_social_node.cmd_get_forums.rpc_id(1, 0)

#region forum
func forum_add_buttons(ids, id_father):
	forum_button_tool.add_buttons(ids, id_father)
	
func forum_clicked(id):
	g_man.local_network_node.net_social_node.cmd_get_forums.rpc_id(1, id)
	g_man.local_network_node.net_social_node.cmd_get_posts.rpc_id(1, id)
	printerr("forum clicked", id, " ", forum_button_tool.get_t_class(id).get_text())

func cmd_get_forum(id):
	#forum_button_tool.get_button(id).hide()
	g_man.local_network_node.net_social_node.cmd_get_forum.rpc_id(1, id)

func create_forum(id, text):
	g_man.local_network_node.net_social_node.cmd_create_forum.rpc_id(1, id, text, "some body", type.THREAD)
#endregion forum
#region post
func post_add_buttons(ids, id_father):
	var content = forum_button_tool.get_button(id_father).get_post_container()
	post_button_tool.add_buttons_at_content(content, ids)
	for id in ids:
		g_man.local_network_node.net_social_node.cmd_get_comments.rpc_id(1, id)
	
func create_post(id_father, header, body):
	g_man.local_network_node.net_social_node.cmd_create_post.rpc_id(1, id_father, header, body)

func post_clicked(_id):
	pass

func cmd_get_post(id):
	g_man.local_network_node.net_social_node.cmd_get_post.rpc_id(1, id)
#endregion post
#region comment
func comment_add_buttons(ids, id_father):
	var content = post_button_tool.get_button(id_father).get_comment_container()
	comment_button_tool.add_buttons_at_content(content, ids)

func create_comment(id_father, body):
	g_man.local_network_node.net_social_node.cmd_create_comment.rpc_id(1, id_father, body)

func comment_clicked(id):
	print("click on comment ", id)

func cmd_get_comment(id):
	g_man.local_network_node.net_social_node.cmd_get_comment.rpc_id(1, id)
#endregion comment
#region comment comment
func comment_comment_add_buttons(ids, _id_father):
	#var content = comment_button_tool.get_button(id_father).get_comment_container()
	comment_comment_button_tool.add_buttons(ids)

func create_comment_comment(_id_father, _body, _comment_of_comments):
	#g_man.local_network_node.net_social_node.cmd_create_comment_comment.rpc_id(1, id_father, body)
	pass

func comment_comment_clicked(id):
	print("click on comment comment ", id)

func cmd_get_comment_comment(_id):
	#g_man.local_network_node.net_social_node.cmd_get_comment_comment.rpc_id(1, id)
	pass
#endregion comment comment
