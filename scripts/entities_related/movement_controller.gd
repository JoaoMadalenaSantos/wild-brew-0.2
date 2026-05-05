extends Node2D

class_name MovementController

@export var raycast_up: RayCast2D
@export var raycast_down: RayCast2D
@export var raycast_left: RayCast2D
@export var raycast_right: RayCast2D
@export var floor_detector: Area2D

var current_dir: Vector2
var target_pos: Vector2 = Vector2.ZERO

const STEP_DISTANCE: float = 16.0
const SPEED: float = 75.0

var is_movement_locked: bool = false

enum MovementControllerState {
	NONE = -1,
	IDLE,
	WALKING
}

var current_state: MovementControllerState = -1 as MovementControllerState
var previous_state: MovementControllerState

signal movement_state_entered(state: MovementControllerState, dir: Vector2)

func _ready() -> void:
	_set_state(MovementControllerState.IDLE)

func _unhandled_input(event: InputEvent) -> void:
	if not is_movement_locked:
		
		if event.is_action_pressed("walk_up"):
			current_dir = Vector2.UP
			_set_state(MovementControllerState.WALKING)
		
		if event.is_action_pressed("walk_down"):
			current_dir = Vector2.DOWN
			_set_state(MovementControllerState.WALKING)
		
		if event.is_action_pressed("walk_left"):
			current_dir = Vector2.LEFT
			_set_state(MovementControllerState.WALKING)
		
		if event.is_action_pressed("walk_right"):
			current_dir = Vector2.RIGHT
			_set_state(MovementControllerState.WALKING)

func _process(delta: float) -> void:
	_process_state(delta)
	
	#print("current_dir: ", current_dir)
	#print("current_pos: ", get_parent().global_position)
	#print("target_pos: ",target_pos)
	#print("current_state: ", current_state)

func _set_state(new_state: MovementControllerState):
	if new_state == current_state:
		return
	
	previous_state = current_state
	_exit_state(current_state)
	
	current_state = new_state
	_enter_state(current_state)

func _enter_state(new_state: MovementControllerState):
	match new_state:
		MovementControllerState.IDLE:
			turn(current_dir)
				
			if _is_on_stairs() and _can_go_in_dir(current_dir):
				_set_state(MovementControllerState.WALKING)
				
		MovementControllerState.WALKING:
			turn_and_move(current_dir)
	
	emit_signal("movement_state_entered", current_state, current_dir)

func _exit_state(old_state: MovementControllerState):
	match old_state:
		MovementControllerState.IDLE:
			pass
		
		MovementControllerState.WALKING:
			pass

func _process_state(_delta):
	match current_state:
		MovementControllerState.IDLE:
			pass
		
		MovementControllerState.WALKING:
			if get_parent().global_position == target_pos:
				match current_dir:
					Vector2.UP:
						if Input.is_action_pressed("walk_up") and _can_go_in_dir(Vector2.UP):
							turn_and_move(current_dir)
						else:
							_set_state(MovementControllerState.IDLE)
					Vector2.DOWN:
						if Input.is_action_pressed("walk_down") and _can_go_in_dir(Vector2.DOWN):
							turn_and_move(current_dir)
						else:
							_set_state(MovementControllerState.IDLE)
					Vector2.LEFT:
						if Input.is_action_pressed("walk_left") and _can_go_in_dir(Vector2.LEFT):
							turn_and_move(current_dir)
						else:
							_set_state(MovementControllerState.IDLE)
					Vector2.RIGHT:
						if Input.is_action_pressed("walk_right") and _can_go_in_dir(Vector2.RIGHT):
							turn_and_move(current_dir)
						else:
							_set_state(MovementControllerState.IDLE)

func _get_ground_tile() -> TileMapLayer:
	var overlaping_body_list : Array = floor_detector.get_overlapping_bodies()
	
	if overlaping_body_list:
		if overlaping_body_list.size() > 1:
			push_error("Player.MovementController: Standing in more than one special body so can't decide which obey. Check level design.")
			return null
		else:
			return overlaping_body_list[0]
	
	return null

func _is_on_stairs() -> bool:
	var ground_tile = _get_ground_tile()
	
	if ground_tile != null:
		if ground_tile.tile_set.get_physics_layer_collision_layer(0) == 2:
			return true
	
	return false

func _can_go_in_dir(dir: Vector2) -> bool:
	match dir:
		Vector2.UP:
			if raycast_up.is_colliding():
				return false
			
		Vector2.DOWN:
			if raycast_down.is_colliding():
				return false
			
		Vector2.LEFT:
			if raycast_left.is_colliding():
				return false
			
		Vector2.RIGHT:
			if raycast_right.is_colliding():
				return false
				
	return true

func turn(dir: Vector2):
	current_dir = dir

func turn_and_move(dir: Vector2):
	if not _can_go_in_dir(dir):
		turn(dir)
	
	else:
		emit_signal("movement_state_entered", current_state, current_dir)
		
		#var footstep_pitch = randf_range(0.6, 1.0)
		#var footstep_volume = randf_range(-21, -19)
		#emit_signal("audio_play_requested", "Footstep", footstep_pitch, footstep_volume)
	
		target_pos = get_parent().global_position + current_dir * STEP_DISTANCE
		var mov_duration = STEP_DISTANCE / SPEED
		
		var tween = create_tween()
		tween.tween_property(get_parent(), "global_position", target_pos, mov_duration)

func toggle_movement_lock():
	if is_movement_locked:
		unlock_movement()
	elif not is_movement_locked:
		lock_movement()

func lock_movement():
	is_movement_locked = true
	print("Player.MovementController: Player movement lock set to ", is_movement_locked)
	
func unlock_movement():
	is_movement_locked = false
	print("Player.MovementController: Player movement lock set to ", is_movement_locked)
