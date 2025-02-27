class_name MaterialObject extends Resource


@export var type_material: Enums.material
@export var liquid_border: float
## at what temperature it starts burning
@export var burn_start: float
## how fast is weight lost per k
@export var burn_speed: float
## how much heat does it produce per k
@export var burn_strength: float
## at what temperature does it start cooking
@export var cooking_border: float = 75
## at what temperature meal is burned
@export var cooking_burn: float = 300
## how much energy can be taken out for digesting
@export var energy: float = 1
