extends Node2D

class_name InteractionController

@onready var raycast: RayCast2D = $RayCast2D

var current_dir: Vector2
var current_targeted_entity: EntityData
var current_interaction: InteractionData

var interaction_locked: bool = false

signal interactable_detected(entity_targeted: EntityData)

func _ready() -> void:
	
	interactable_detected.connect(InteractionSystem.get_interaction)
	
	InteractionSystem.interaction_finished.connect(_on_interaction_finished)

func _physics_process(delta: float) -> void:
	if raycast.is_colliding() and not current_targeted_entity:
		_on_raycast_colliding()
	elif not raycast.is_colliding():
		current_targeted_entity = null
		UIService.request_hide_interaction_hint()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and current_targeted_entity and not interaction_locked:
		InteractionSystem.apply_interaction(current_targeted_entity)
		interaction_locked = true
		get_parent().request_movement_lock_toggle()
		get_viewport().set_input_as_handled()

func _is_facing_interactable() -> bool:
	if raycast.get_collider():
		return true
	else:
		return false

func get_interacted_entity() -> EntityData:
	var interacted_entity_data = EntityData
	var facing_body = raycast.get_collider()
	
	if facing_body != null:
		var interacted_entity = facing_body.get_parent()
		if interacted_entity.get("entity_data") != null:
			interacted_entity_data = interacted_entity.get("entity_data").duplicate()
			return interacted_entity_data
		else:
			push_error("No entity_data found in facing entity.")
			return null
	
	else:
		print(self, ": Facing no interactable entity.")
		return null
	

func update_facing_direction(dir: Vector2):
	current_dir = dir
	raycast.target_position = dir * 16
	
func _on_raycast_colliding():
	current_targeted_entity = get_interacted_entity()
	
	if current_targeted_entity.interactions:
		current_interaction = InteractionSystem.get_interaction(current_targeted_entity)

func _on_interaction_finished():
	interaction_locked = false
	get_parent().request_movement_lock_toggle()
