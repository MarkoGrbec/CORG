class_name QuestQuestion extends Resource
## new basis on this qq
@export var new_basis: int
@export_group("add remove basis flags")
@export var add_basis_flags: Array[int]
@export var remove_basis_flags: Array[int]
@export_group("items needed for this quest")
## quest item needed for finishing this quest
@export var quest_item: Enums.Esprite
## minimum quantity of items needed
@export var quantity: int
## minimum ql needed for to hand over
@export var ql: int
@export_group("reward for this quest")
## reward for finishing this quest
@export var reward: Enums.Esprite
@export_group("other npc")
## which npc will be activated - use index + 1
@export var npc_activate: int
## how will it be activated or deactivated
@export var npc_activated: bool
## will the npc be alive or dead after this completed quest
@export var npc_alive: bool
## his npc basis
@export var npc_basis: int
@export_group("dialogs")
## what dialogs are available to choose
@export_multiline var list_avatar_dialog: Array[String]
## what dialog is a response dialog
@export_multiline var response_dialog: String
## what will happen if he fails the quest
@export_multiline var response_failed_dialog: String
