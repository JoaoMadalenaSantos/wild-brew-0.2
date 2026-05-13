extends Node2D

@export var y_sort_node: Node2D
@export var camera: Camera2D

@export var level_data: LevelData
var current_level_state_data: LevelStateData

func _ready() -> void:
	update_level_state()

func set_level_state(new_level_state: LevelStateData):
	current_level_state_data = new_level_state
	var current_entity_list = y_sort_node.get_children()
	
	for entity in current_entity_list:
		var entity_data = entity.get("entity_data")
		var new_entity_state = new_level_state.entity_state_data_list[entity_data]
		if new_entity_state == null:
			entity.queue_free()
		else:
			entity.set_entity_state(new_entity_state)
	
	for entity in new_level_state.entity_state_data_list:
		if current_entity_list.find_custom(
			func(entity):
				var entity_data = entity.get("entity_data")
				return entity_data == new_level_state.entity_state_data_list[entity]
		):
			pass

func update_level_state():
	var new_level_state: LevelStateData
	
	if current_level_state_data != null:
		new_level_state = current_level_state_data.duplicate()
	else:
		new_level_state = LevelStateData.new()
	
	new_level_state.level_data = level_data
	new_level_state.entity_state_data_list = get_entities_state_list()
	
	current_level_state_data = new_level_state

func get_entities_state_list() -> Dictionary[EntityData, EntityStateData]:
	var entity_state_data_list: Dictionary[EntityData, EntityStateData]
		
	if y_sort_node != null:
		var entities_container_children = y_sort_node.get_children()
			
		if not entities_container_children.is_empty():
			for entity in entities_container_children:
				if "entity_data" in entity and "current_entity_state_data" in entity:
					var entity_data = entity.get("entity_data")
					var entity_state_data = entity.get("current_entity_state_data")
					entity_state_data_list[entity_data] = entity_state_data
	
	return entity_state_data_list
