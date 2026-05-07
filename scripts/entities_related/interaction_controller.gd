extends Node2D

class_name InteractionController

@onready var raycast: RayCast2D = $RayCast2D

var current_dir: Vector2
var current_targeted_entity: Node
var current_interaction: InteractionData

var interaction_locked: bool = false

signal check_item_in_inventory_needed(item_data: ItemData, quantity: int)
signal check_space_in_inventory_needed(item_data: ItemData, quantity: int)

func _ready() -> void:
	InteractionSystem.interaction_finished.connect(_on_interaction_finished)

func _physics_process(delta: float) -> void:
	
	if raycast.is_colliding() and not current_targeted_entity:
		_on_raycast_colliding()
	elif not raycast.is_colliding():
		current_targeted_entity = null
		current_interaction = null
		UIService.request_hide_interaction_hint()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and current_targeted_entity and not interaction_locked:
		interaction_locked = true
		InteractionSystem.apply_interaction(get_parent(), current_targeted_entity, current_interaction)
		get_parent().request_movement_lock_toggle()
		get_viewport().set_input_as_handled()

func _is_facing_interactable() -> bool:
	if raycast.get_collider():
		return true
	else:
		return false

func get_facing_interactable() -> Node:
	var facing_body = raycast.get_collider()
	
	if facing_body != null:
		var interactable_entity = facing_body.get_parent()
		if interactable_entity.get("entity_data") != null:
			return interactable_entity
		else:
			push_error("No entity_data found in facing entity.")
			return null
	
	else:
		print(self, ": Facing no interactable entity.")
		return null
	

func get_next_valid_interaction(entity: Node) -> InteractionData:
	var entity_data = entity.get("entity_data")
	
	if not entity_data:
		return null
	
	if entity_data.interactions.is_empty():
		return null
	
	for interaction in entity_data.interactions:
		if interaction.item_cost.is_empty():
			UIService.request_display_interaction_hint(interaction.action_hint)
			return interaction
		
		var exit_loop: bool = false
		
		for item in interaction.item_cost:
			if exit_loop:
				break
			
			var quantity = interaction.item_cost[item]
			
			if quantity <= 0:
				continue
			
			if quantity > 0:
				emit_signal("check_item_in_inventory_needed", item, quantity)
				
				var has_item: bool = await get_parent().check_item_in_inventory_answered
				
				if not has_item:
					exit_loop = true
			
		if exit_loop:
			continue
		else:
			UIService.request_display_interaction_hint(interaction.action_hint)
			return interaction
	
	UIService.request_hide_interaction_hint()
	return null

func update_facing_direction(dir: Vector2):
	current_dir = dir
	raycast.target_position = dir * 16
	
func _on_raycast_colliding():
	current_targeted_entity = get_facing_interactable()
	
	if _is_facing_interactable():
		if current_targeted_entity.get("entity_data"):
			current_interaction = await get_next_valid_interaction(current_targeted_entity)
			#print("current_interaction is ", current_interaction)

func _on_interaction_finished():
	_on_raycast_colliding()
	
	get_parent().request_movement_lock_toggle()
	
	interaction_locked = false
