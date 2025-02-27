class_name AttachedObject extends Resource
@export var name_of_attachment: String

## where will be object attached at
@export var attach_to_me_at: Vector3

## rotation where will be object attached at
@export var direction: Vector3

## what type of objects can be attached to this attachment
@export var objects: Array[Enums.Esprite]
