class_name ISavable extends Node

@warning_ignore("unused_private_class_variable")
var _server:bool
@warning_ignore("unused_private_class_variable")
var _path:String
var id:int
## how much it has been loaded
## 0 non
## 1 partly
## 2 fully
var partly_loaded:int
#region savable
func copy():					# copy the class which is used by savable when new needs to be created
	pass # return self.new()
func partly_save():			# only part save
	pass
func fully_save():			# full save
	pass
func partly_load():			# load only critical data
	pass
func fully_load():			# fully load
	pass
func destroy():			# if I'm destroyed call my destroy function
	pass			
#endregion savable


#public long idFather { get; set; }
#public List<long> ThreadsChildren { get; set; }
