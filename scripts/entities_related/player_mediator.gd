extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var movement_controller: Node2D = $MovementController
@onready var interaction_controller: Node2D = $InteractionController

@export var entity_data: EntityData
@export var current_entity_state_data: EntityStateData

func _ready() -> void:
	if movement_controller:
		movement_controller.movement_state_entered.connect(_on_movement_state_entered)

func _process(delta: float) -> void:
	pass

func _on_movement_state_entered(state: MovementController.MovementControllerState, dir: Vector2):
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
	movement_controller.toggle_movement_lock()

func set_entity_state(new_entity_state: EntityStateData):
	current_entity_state_data = new_entity_state
	
	global_position = new_entity_state.movement.position
	movement_controller.turn(new_entity_state.movement.direction)
	#new_entity_state.inventory = inventory_registry.current_inventory_data
	#new_entity_state.effects = effects_registry.current_effects_data

func update_entity_state():
	var new_entity_state: EntityStateData
	
	if current_entity_state_data != null:
		new_entity_state = current_entity_state_data.duplicate()
	else:
		new_entity_state = EntityStateData.new()
	
	# Todo: Understand if scene need to be overwritten too, if so, how
	new_entity_state.movement.position = global_position
	new_entity_state.movement.direction = movement_controller.current_dir
	#new_entity_state.inventory = inventory_registry.current_inventory_data
	#new_entity_state.effects = effects_registry.current_effects_data
	
	current_entity_state_data = new_entity_state
