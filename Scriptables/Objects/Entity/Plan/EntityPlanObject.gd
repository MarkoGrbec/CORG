class_name EntityPlanObject extends Resource

@export var entity_num: Enums.Esprite

## where's my position to attach
@export var i_attach_from: Vector3

## size that I need to be attached
@export var my_size: float

## my rotation to attach
@export var direction: Vector3

## what objects can attach to me
@export var attach: Array[AttachedObject]
