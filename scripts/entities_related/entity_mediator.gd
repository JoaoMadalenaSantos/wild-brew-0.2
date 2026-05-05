extends Node2D

class_name EntityMediator

@export var animated_sprite_2d: AnimatedSprite2D
@export var movement_controller: MovementController
@export var interaction_controller: InteractionController

@export var entity_data: EntityData
var entity_starting_movement_state: StartingMovementStateData
@export var current_entity_state_data: EntityStateData

func _ready() -> void:
	update_entity_state()
	
	if movement_controller:
		movement_controller.movement_state_entered.connect(_on_movement_state_entered)
		apply_entity_starting_movement_state()

func _process(_delta: float) -> void:
	pass

func _on_movement_state_entered(state: MovementController.MovementControllerState, dir: Vector2):
	if not movement_controller:
		push_error(self, ".EntityMediator: No movement_controller found in entity.")
		return
	
	interaction_controller.update_facing_direction(dir)
	
	match state:
		MovementController.MovementControllerState.IDLE:
			match dir:
				Vector2.UP:
					animated_sprite_2d.play("idle_up")
				
				Vector2.DOWN:
					animated_sprite_2d.play("idle_down")
				
				Vector2.LEFT:
					animated_sprite_2d.play("idle_side")
					animated_sprite_2d.flip_h = true
				
				Vector2.RIGHT:
					animated_sprite_2d.play("idle_side")
					animated_sprite_2d.flip_h = false
					
		MovementController.MovementControllerState.WALKING:
			match dir:
				Vector2.UP:
					animated_sprite_2d.play("walking_up")
				
				Vector2.DOWN:
					animated_sprite_2d.play("walking_down")
				
				Vector2.LEFT:
					animated_sprite_2d.play("walking_side")
					animated_sprite_2d.flip_h = true
				
				Vector2.RIGHT:
					animated_sprite_2d.play("walking_side")
					animated_sprite_2d.flip_h = false
	
	update_entity_state()

func request_movement_lock_toggle():
	if not movement_controller:
		push_error(self, ".EntityMediator: No movement_controller found in entity to toggle movement lock.")
		return
	
	movement_controller.toggle_movement_lock()

func set_entity_starting_movement_state(movement_state: MovementStateData):
	entity_starting_movement_state = movement_state
	
	if movement_controller:
		movement_controller.current_dir = movement_state.direction

func apply_entity_starting_movement_state():
	var movement_state = entity_starting_movement_state
	
	global_position = movement_state.position
	
	if movement_controller:
		#movement_controller.target_dir = movement_state.direction
		movement_controller.turn(movement_state.direction)
	
	update_entity_state()

func set_entity_state(new_entity_state: EntityStateData):
	current_entity_state_data = new_entity_state
	
	global_position = new_entity_state.movement.position
	
	if movement_controller:
		movement_controller.turn(new_entity_state.movement.direction)
	
	#if inventory_registry:
		#new_entity_state.inventory = inventory_registry.current_inventory_data
	
	#if effects_registry:
		#new_entity_state.effects = effects_registry.current_effects_data

func update_entity_state():
	var new_entity_state: EntityStateData
	
	if current_entity_state_data != null:
		new_entity_state = current_entity_state_data.duplicate()
	else:
		new_entity_state = EntityStateData.new()
	
	# Todo: Understand if scene need to be overwritten too, if so, how
	
	new_entity_state.movement = MovementStateData.new()
	new_entity_state.movement.position = global_position
	
	if movement_controller:
		new_entity_state.movement.direction = movement_controller.current_dir
	
	#if inventory_registry:
		#new_entity_state.inventory = inventory_registry.current_inventory_data
	
	#if effects_registry:
		#new_entity_state.effects = effects_registry.current_effects_data
	
	current_entity_state_data = new_entity_state
