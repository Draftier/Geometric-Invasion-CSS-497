extends Resource
class_name EnemyMovementData

# Dictionary that stores movement string and distance to travel
@export var movement_dict : Dictionary[String, float] = {}

# String that stores what function the enemy will path the distance with
@export var function : String

# Var to check if we want movement to loop
@export var wrap : bool
@export var leave_screen : bool
