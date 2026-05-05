extends Node

@export var boot_sequence_scene: PackedScene
@export var main_menu_scene: PackedScene
@export var gameplay_scene: PackedScene = load("res://scenes/gameplay_root.tscn")
@export var credits_scene: PackedScene

@onready var main_node = get_tree().current_scene

var loaded_game_data: GameData
var current_game_data: GameData

enum GameState {
	NONE,
	BOOT_SEQUENCE,
	MAIN_MENU,
	GAMEPLAY,
	CREDITS
}

var current_game_state: GameState = GameState.NONE
var previous_game_state: GameState

signal entered_game_state(game_state: GameState)

func _ready() -> void:
	# Making the game set first game data and goind to gameplay on ready before making other states logic
	if loaded_game_data == null:
		loaded_game_data = load("res://resources/custom_resources/game_data/starting_game_data.tres")
		current_game_data = loaded_game_data.duplicate()
		
	_set_game_state(GameState.GAMEPLAY)

func _process(delta: float) -> void:
	_process_game_state(delta)

func _set_game_state(new_game_state: GameState):
	if current_game_state == new_game_state:
		return
	
	previous_game_state = current_game_state
	_exit_game_state(current_game_state)
	current_game_state = new_game_state
	_enter_game_state(current_game_state)

func _enter_game_state(new_game_state: GameState):
	match new_game_state:
		GameState.NONE:
			pass
		
		GameState.BOOT_SEQUENCE:
			pass
			
		GameState.MAIN_MENU:
			pass
			
		GameState.GAMEPLAY:
			var gameplay_node = gameplay_scene.instantiate()
			main_node.add_child(gameplay_node)
			
		GameState.CREDITS:
			pass
	
	emit_signal("entered_game_state", current_game_state, current_game_data)

func _exit_game_state(old_game_state: GameState):
	match old_game_state:
		GameState.NONE:
			pass
		
		GameState.BOOT_SEQUENCE:
			pass
			
		GameState.MAIN_MENU:
			pass
			
		GameState.GAMEPLAY:
			pass
			
		GameState.CREDITS:
			pass

func _process_game_state(_delta) -> void:
	match current_game_state:
		GameState.NONE:
			pass
		
		GameState.BOOT_SEQUENCE:
			pass
			
		GameState.MAIN_MENU:
			pass
			
		GameState.GAMEPLAY:
			pass
			
		GameState.CREDITS:
			pass

func request_current_game_data() -> GameData:
	return current_game_data

func request_level_state(level: LevelData) -> LevelStateData:
	var level_state_idx = current_game_data.level_state_list.find_custom(
		func(level_state: LevelStateData):
			return level_state.level_data == level 
	)
	
	if level_state_idx == -1:
		return null
	
	var level_state_data = current_game_data.level_state_list[level_state_idx]
	
	return level_state_data

func _on_level_exited(level_state_data: LevelStateData, player_state_data: EntityStateData):
	add_or_update_level_state_data(level_state_data)
	set_player_state_data(player_state_data)

func add_or_update_level_state_data(new_level_state_data: LevelStateData):
	if not new_level_state_data.level_data:
		return
	
	var level_state_data_idx = current_game_data.level_state_list.find_custom(
		func(level_state_data: LevelStateData):
			return level_state_data.level_data == new_level_state_data.level_data
	)
	
	if level_state_data_idx == -1:
		current_game_data.level_state_list.append(new_level_state_data)
	else:
		current_game_data.level_state_list[level_state_data_idx] = new_level_state_data

func set_player_state_data(new_player_state_data: EntityStateData):
	current_game_data.current_player_state = new_player_state_data

func pass_day(quantity: int):
	current_game_data.current_in_game_day += quantity
