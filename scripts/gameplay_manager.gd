extends Node

@export var gameplay: Node2D
@export var level_manager: Node

enum GameplayState {
	NONE = -1,
	PRE_DAY,
	IN_LEVEL,
	IN_INTERFACE,
	PAUSED,
	POST_DAY
}

var current_state: GameplayState = -1 as GameplayState
var previous_state: GameplayState

signal entered_gameplay_state(new_state: GameplayState)
#signal save_progress_requested

func _ready() -> void:
	_set_gameplay_state(GameplayState.PRE_DAY)

func _set_gameplay_state(new_gameplay_state: GameplayState):
	if current_state == new_gameplay_state:
		return
	
	previous_state = current_state
	_exit_gameplay_state(current_state)
	
	current_state = new_gameplay_state
	_enter_gameplay_state(current_state)

func _enter_gameplay_state(new_gameplay_state: GameplayState):
	match new_gameplay_state:
		GameplayState.PRE_DAY:
			level_manager.start()
		
		GameplayState.IN_LEVEL:
			pass
			
		GameplayState.IN_INTERFACE:
			level_manager.toggle_player_movement_lock()
			
		GameplayState.PAUSED:
			emit_signal("pause_screen_toggle_needed")
			gameplay.paused = true
			
		GameplayState.POST_DAY:
			pass
	
	emit_signal("entered_gameplay_state", current_state)

func _exit_gameplay_state(old_gameplay_state: GameplayState):
	match old_gameplay_state:
		GameplayState.PRE_DAY:
			pass
		
		GameplayState.IN_LEVEL:
			pass
			
		GameplayState.IN_INTERFACE:
			level_manager.toggle_player_movement_lock()
			
		GameplayState.PAUSED:
			emit_signal("pause_screen_toggle_needed")
			gameplay.paused = false
			
		GameplayState.POST_DAY:
			GameManager.pass_day(1)
			pass

func _process_gameplay_state(_delta) -> void:
	match current_state:
		GameplayState.PRE_DAY:
			pass
		
		GameplayState.IN_LEVEL:
			pass
			
		GameplayState.IN_INTERFACE:
			pass
			
		GameplayState.PAUSED:
			pass
			
		GameplayState.POST_DAY:
			pass

func finish_gameplay(save_progress: bool):
	if save_progress:
		#SaveService.request_progress_save()
		#await  SaveService.progress_saved
		
		emit_signal("gameplay_ready_to_queue_free")
	
	
