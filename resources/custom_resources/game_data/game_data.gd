extends Resource

class_name GameData

@export var current_in_game_day: int = 0
@export var current_region: RegionData
@export var shop_set_to_open: bool

@export var current_player_state: EntityStateData

#var known_items: Array[ItemData]
#var known_recipes: Array[RecipeData]
#
var level_state_list: Array[LevelStateData]
