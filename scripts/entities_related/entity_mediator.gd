extends Node2D

class_name EntityMediator

@export var animated_sprite_2d: AnimatedSprite2D
@export var movement_controller: MovementController
@export var interaction_controller: InteractionController
@export var inventory_component: InventoryComponent

@export var entity_data: EntityData
var entity_starting_movement_state: StartingMovementStateData
@export var current_entity_state_data: EntityStateData

var post_ready_global_vars: Dictionary = {}

signal check_item_in_inventory_answered(answer: bool)
signal check_space_in_inventory_answered(answer: bool)

func _ready() -> void:
	update_entity_state()
	
	if movement_controller:
		movement_controller.movement_state_entered.connect(_on_movement_state_entered)
		apply_entity_starting_movement_state()
		
	if interaction_controller:
		interaction_controller.check_item_in_inventory_needed.connect(_on_check_item_in_inventory_needed)
		interaction_controller.check_space_in_inventory_needed.connect(_on_check_space_in_inventory_needed)
	
	if inventory_component:
		post_ready_global_vars["is_holding_item"] = false
		inventory_component.holding_item_detected.connect(_on_holding_item_detected)
		inventory_component.not_holding_item_detected.connect(_on_not_holding_item_detected)

func _process(_delta: float) -> void:
	pass

func _on_movement_state_entered(state: MovementController.MovementControllerState, dir: Vector2):
	post_ready_global_vars["last_movement_state"] = {"state": state, "dir": dir}
	
	if not movement_controller:
		push_error(self, ".EntityMediator: No movement_controller found in entity.")
		return
	
	interaction_controller.update_facing_direction(dir)
	print("on movement state entered is_holding_item is ", post_ready_global_vars["is_holding_item"])
	if post_ready_global_vars.has("is_holding_item") and post_ready_global_vars["is_holding_item"] == true:
		match state:
			MovementController.MovementControllerState.IDLE:
				match dir:
					Vector2.UP:
						animated_sprite_2d.play("holding_idle_up")
					
					Vector2.DOWN:
						animated_sprite_2d.play("holding_idle_down")
					
					Vector2.LEFT:
						animated_sprite_2d.play("holding_idle_side")
						animated_sprite_2d.flip_h = true
					
					Vector2.RIGHT:
						animated_sprite_2d.play("holding_idle_side")
						animated_sprite_2d.flip_h = false
						
			MovementController.MovementControllerState.WALKING:
				match dir:
					Vector2.UP:
						animated_sprite_2d.play("holding_walking_up")
					
					Vector2.DOWN:
						animated_sprite_2d.play("holding_walking_down")
					
					Vector2.LEFT:
						animated_sprite_2d.play("holding_walking_side")
						animated_sprite_2d.flip_h = true
					
					Vector2.RIGHT:
						animated_sprite_2d.play("holding_walking_side")
						animated_sprite_2d.flip_h = false
	else:
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

func _on_check_item_in_inventory_needed(item_data: ItemData, quantity: int):
	if not inventory_component:
		emit_signal("check_item_in_inventory_answered", false)
		return
	
	var answer = inventory_component.check_if_has_item(item_data, quantity)
	emit_signal("check_item_in_inventory_answered", answer)

func _on_check_space_in_inventory_needed(item_data: ItemData, quantity: int):
	if not inventory_component:
		emit_signal("check_space_in_inventory_answered", false)
		return
	
	var answer: bool = true
	if inventory_component.find_slot_for_item(item_data, quantity) == -1:
		answer = false
	
	emit_signal("check_space_in_inventory_answered", answer)

func _on_holding_item_detected():
	if not inventory_component:
		return
	
	if not post_ready_global_vars.has("is_holding_item"):
		return
	
	post_ready_global_vars["is_holding_item"] = true
	print("is_holding_item set to true")
	
	if post_ready_global_vars.has("last_movement_state"):
		var last_movement_state = post_ready_global_vars["last_movement_state"]["state"]
		var last_dir = post_ready_global_vars["last_movement_state"]["dir"]
		_on_movement_state_entered(last_movement_state, last_dir)

func _on_not_holding_item_detected():
	if not inventory_component:
		return
	
	if not post_ready_global_vars.has("is_holding_item"):
		return
	
	post_ready_global_vars["is_holding_item"] = false
	print("is_holding_item set to false")
	
	if post_ready_global_vars.has("last_movement_state"):
		var last_movement_state = post_ready_global_vars["last_movement_state"]["state"]
		var last_dir = post_ready_global_vars["last_movement_state"]["dir"]
		_on_movement_state_entered(last_movement_state, last_dir)
