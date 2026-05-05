extends Node

@export var level_container: Node2D
var player_entity_data = load("res://resources/custom_resources/entities/player.tres")

var current_level_node: Node

var current_level_data: LevelData
var previous_level_data: LevelData

var current_level_state_data: LevelStateData
var next_level_state_data: LevelStateData
var current_player_state_data: EntityStateData

enum LevelManagerState {
	NONE = -1,
	ENTERING_LEVEL,
	IN_LEVEL,
}

var current_state: LevelManagerState = -1 as LevelManagerState
var previous_state: LevelManagerState

signal level_manager_state_entered
signal level_exited(level_state_data: LevelStateData, player_state_data: EntityStateData)

func _ready() -> void:
	level_exited.connect(GameManager._on_level_exited)

func _set_state(new_state: LevelManagerState):
	if new_state == current_state:
		return
	
	previous_state = current_state
	_exit_state(current_state)
	
	current_state = new_state
	_enter_state(current_state)

func _enter_state(new_state: LevelManagerState):
	match new_state:
		LevelManagerState.ENTERING_LEVEL:
			await UIService.transition_close_finished
			
			spawn_level(current_level_data, current_level_state_data)
			UIService.request_open_transition(self)
				
		LevelManagerState.IN_LEVEL:
			pass
	
	emit_signal("level_manager_state_entered", current_state)

func _exit_state(old_state: LevelManagerState):
	match old_state:
		LevelManagerState.ENTERING_LEVEL:
			pass
		
		LevelManagerState.IN_LEVEL:
			var player = current_level_node.find_child("Player", true)
			var player_state = player.get("current_entity_state_data")
			player.queue_free()
			
			emit_signal("level_exited", current_level_state_data, player_state)

func start():
	var first_level = GameManager.request_current_game_data().current_region.central_level
	
	set_level(first_level)

func set_level(new_level_data: LevelData):
	#save_current_level_state(current_level_state_data)
	print("level set to: ", new_level_data)
	
	# Loads new level state data from game data ()
	var new_level_saved_level_state = GameManager.request_level_state(new_level_data)
	
	if new_level_saved_level_state:
		next_level_state_data = new_level_saved_level_state
	else:
		create_level_state_data_for_current_level()
	
	UIService.request_close_transition(self)
	
	previous_level_data = current_level_data
	current_level_data = new_level_data
	
	_set_state(LevelManagerState.ENTERING_LEVEL)

func spawn_level(level_data: LevelData, _level_state_data: LevelStateData):
	if level_container.get_children():
		for child in level_container.get_children():
			child.queue_free()
			
	var new_level_scene = load(level_data.scene_path)
	var new_level_node = new_level_scene.instantiate()
	
	level_container.add_child(new_level_node)
	current_level_node = new_level_node
	
	var player_scene = load(player_entity_data.scene_path)
	var player_node = player_scene.instantiate()
	
	var player_starting_data_idx = level_data.starting_movement_data_list.find_custom(func(starting_movement_data):
		return starting_movement_data.coming_from_level == previous_level_data
	)
	var player_starting_movement_data = level_data.starting_movement_data_list[player_starting_data_idx]
	
	player_node.set_entity_starting_movement_state(player_starting_movement_data)
	
	var entities_container = current_level_node.find_child("Entities", false)
	entities_container.add_child(player_node)
	
	var camera = current_level_node.find_child("Camera2D", false)
	camera.target = player_node
	
	_set_state(LevelManagerState.IN_LEVEL)

func create_level_state_data_for_current_level():
	var new_level_state_data = LevelStateData.new()
	new_level_state_data.level_data = current_level_data
	
	if current_level_node != null:
		var entities_container = current_level_node.find_child("Entities", false)
		
		if entities_container != null:
			var entities_container_children = entities_container.get_children()
			
			if not entities_container_children.is_empty():
				for entity in entities_container_children:
					if "entity_data" in entity and "current_entity_state_data":
						var entity_data = entity.get("entity_data")
						var entity_state_data = entity.get("current_entity_state_data")
						new_level_state_data.entity_state_data_list[entity_data] = entity_state_data
	
	current_level_state_data = new_level_state_data

func toggle_player_movement_lock():
	var player: Node = level_container.find_child("Player", true)
	
	if player and player.has_method("request_movement_lock_toggle"):
		player.request_movement_lock_toggle()

func _on_interaction_with_portal(target_level: LevelData):
	#save_level_state(current_level_data)
	
	current_level_data = target_level
