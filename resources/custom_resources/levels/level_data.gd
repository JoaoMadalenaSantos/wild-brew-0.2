extends Resource

class_name LevelData

@export var display_name: String
@export var always_display_name: bool = false

@export var scene: PackedScene
#@export var starting_state: LevelStateData
#var current_state: LevelStateData

@export var starting_movement_data_list: Array[StartingMovementStateData]
