class_name SpenderTab extends Node

func _ready() -> void:
	g_man.spender_tab = self
	spender_button_tool = ButtonTool.new(preload("res://GUI/Windows/MainMenu/Spender/Spender.tscn"), null, on_spender_click, cmd_refresh_spender, applied_container)

#region input
var spender_button_tool: ButtonTool
#endregion input
#region tab
func on_tab_pressed(tab):
	tab += 1
	g_man.local_network_node.net_corg_node.cmd_get_spenders.rpc_id(1, tab, 0)

#endregion tab
#region buttons

func apply_for_spender():
	g_man.mold_window.set_add_submit_text([
		"Spenders",
		"do you want to become spender of CORG taxes?",
		"please note all details for what and why would you spend plants for.",
		"be aware if you aren't chosen to do it you will never be able to do it in future"
		], "enter your spending ideas", submit_apply_for_spender)

func submit_apply_for_spender(text):
	g_man.local_network_node.net_corg_node.cmd_add_spender.rpc_id(1, text)
#endregion buttons
#region button tool
@onready var applied_container: VBoxContainer = $"applied/VBoxContainer/ScrollContainer/applied container"
@onready var confirmed_container: VBoxContainer = $"confirmed/VBoxContainer/ScrollContainer/confirmed container"
@onready var banned_container: VBoxContainer = $"banned/VBoxContainer/ScrollContainer/banned container"

var refresh_spenders = {}

func add_buttons_spenders(type, ids):
	if type:
		if type == 1:
			spender_button_tool.add_buttons_at_content(applied_container, ids)
		elif type == 2:
			spender_button_tool.add_buttons_at_content(confirmed_container, ids)
		elif type == 3:
			spender_button_tool.add_buttons_at_content(banned_container, ids)

func on_spender_click(id, vote_toggle):
	g_man.local_network_node.net_corg_node.cmd_vote_spender.rpc_id(1, id, vote_toggle)

func cmd_refresh_spender(id):
	g_man.local_network_node.net_corg_node.cmd_refresh_spender.rpc_id(1, id)

func refresh_spender(type, spender:Spender):
	var client:Client = Client.construct_for_client_new_id(spender.id_client, "")
	if not client._username:
		refresh_spenders[spender.id_client] = [type, spender]
		g_man.client_signal.connect(refresh_spender)
		g_man.local_network_node.get_client_data.rpc_id(1, spender.id_client)
		
	spender_button_tool.refresh_t(spender.id, spender)
	reparent_spender(type, [spender.id])

func reparent_spender(type, ids):
	if type == 1:
		spender_button_tool.reparent_buttons(ids, applied_container)
	elif type == 2:
		spender_button_tool.reparent_buttons(ids, confirmed_container)
	elif type == 3:
		spender_button_tool.reparent_buttons(ids, banned_container)

func refresh_client(client:Client):
	if refresh_spenders.has(client.id_server):
		var type_spender = refresh_spenders[client.id_server]
		refresh_spender(type_spender[0], type_spender[1])
#endregion button tool
#public class SpendersManager : WindowManager
#{
	##region windowConfig
	#public static SpendersManager Sin { get; private set; }
	#public void Awake(){
		#if (Sin == null){
			#Sin = this;
			#SavableSpender = new Savable<Spender>(DataBase.path.Spender, true);
			#containerOfSpenders = new Dictionary<long, Spender>();
			#
			#ButtonsSpender = new ButtonTool<Spender>[3];
			#for (int i = 0; i < ButtonsSpender.Length; i++)
			#{
				#ButtonsSpender[i] =
					#new ButtonTool<Spender>(this,
						#ParentOfAllWindows.Sin.prefabLawSpender.transform);
				#/*, null,
					#OnSpenderClick,
					#CmdNetworkRefreshSpender, RefreshSpender,
					#content
				#);*/
				#ButtonsSpender[i].Set(containerOfSpenders,
					#OnSpenderClick,
					#CmdNetworkRefreshSpender,
					#RefreshSpender,
					#tabContent[i]
				#);
			#}
			#
			#SavableSpender.PartlyLoadAll();
		#}
		#else{
			#Debug.LogError($"DESTROY {gameObject}");
			#Destroy(gameObject);
		#}
	#}
	#public override void Start()
	#{
		#idWindow = 24;
		#base.Start();
		#windowName.text = "spenders";
		#Onoff(false);
	#}
	#public override void Onoff(){
		#base.Onoff();
		#//GetSpenders();
	#}
	##endregion end windowConfig
	##region inputs
	#/// <summary>
	#/// the content where all type spenders will be
	#/// </summary>
	#public Transform[] tabContent = new Transform[3];
	#/// <summary>
	#/// on server
	#/// </summary>
	#public Savable<Spender> SavableSpender;
	#/// <summary>
	#/// buttons of spenders client side
	#/// </summary>
	#public ButtonTool<Spender>[] ButtonsSpender;
	#/// <summary>
	#/// on client
	#/// </summary>
	#public Dictionary<long, Spender> containerOfSpenders;
	##endregion
	##region network
	#/// <summary>
	#/// first call from client to get all possible ids for buttons
	#/// </summary>
	#public void GetSpenders()
	#{
		#Debug.LogError("get spenders");
		#NetMan.sin.Client.gos.netCORG.netC.CmdGetSpenders(Spender.SpenderType.AppliedForSpender, 0);
	#}
	#/// <summary>
	#/// call to the server to get full data for specific id
	#/// </summary>
	#/// <param name="id"></param>
	#public void CmdNetworkRefreshSpender(long id)
	#{
		#//Debug.Log("CMD refresh id");
		#NetMan.sin.Client.gos.netCORG.netC.CmdGetSpender(id);
	#}
	#/// <summary>
	#/// when needed the
	#/// ButtonTool sends us the Transform
	#/// with content of Spender's component
	#/// which we manually change it's data which also ButtonTool provide us
	#/// </summary>
	#/// <param name="spender">data</param>
	#/// <param name="tran">component provided</param>
	#public void RefreshSpender(Spender spender, Transform tran)
	#{
		#var beh = tran.GetComponent<LawSpenderComponent>();
		#beh.id = spender.ID;
		#beh.Header = spender.userName;
		#beh.text.text = spender.text;
		#
		#beh.ChangePercent(spender.upVote);
		#//Debug.Log($"people count: {LawManager.Sin.peopleCount} people voted: {spender.peopleVoted}, up: {spender.upVote}");
		#beh.ChangeSlide(LawManager.Sin.peopleCount, spender.peopleVoted, spender.upVote, spender.acceptedSpender);
		#
		#beh.buttonClick = VoteClick;
#
		#beh.debug = spender;
	#}
	##endregion
	##region buttons
#
	#public void OnTabClick(int type)
	#{
		#Debug.Log((Spender.SpenderType)type);
		#NetMan.sin.Client.gos.netCORG.netC.CmdGetSpenders((Spender.SpenderType)type, 0);
	#}
	#/// <summary>
	#/// it's triggered when local button has been clicked
	#/// </summary>
	#public void BecomeSpender()
	#{
		#Debug.Log($"{NetMan.sin.Client.userName} wants to become spender");
		#if(NetMan.sin.Client.userLevel <= Person.BecomeModerator+2)return;
		#MoldWindowManager.sin.SetMoldWindow
		#(
			#NetMan.sin.Client.gos.netCORG.netC.CmdAddSpender,
			#"Spenders",
			#"do you want to become spender of CORG taxes. \nplease note all details for what and why would you spend plants for. \nbeware if you aren't chosen to do it you will never be able to do it in future",
			#false
		#);
	#}
#
	#/// <summary>
	#/// when button spender ahs been clicked
	#/// </summary>
	#/// <param name="idSpender"></param>
	#public void OnSpenderClick(long idSpender)
	#{
		#Debug.Log($"on spender click {idSpender}");
		#var type = containerOfSpenders[idSpender].spenderType;
		#var button = ButtonsSpender[(int)type-1].GetTransform(idSpender);
		#OnOff.OnOffArrayGameObjects(true, button.GetComponent<LawSpenderComponent>().sliderGameObject);
	#}
	#/// <summary>
	#/// when spender vote has been clicked
	#/// </summary>
	#/// <param name="id">id of spender</param>
	#/// <param name="vote">vote yes or vote no</param>
	#public void VoteClick(long id, bool vote)
	#{
		#Debug.Log($"on spender vote click {id} {vote}");
		#NetMan.sin.Client.gos.netCORG.netC.CmdVoteSpender(id, vote);
	#}
	##endregion
#}
