extends Node

var dropped_item_entity_scene: PackedScene

signal spawn_dropped_item_needed(entity: Node2D, position: Vector2)

func request_spawn_dropped_item(item: ItemData, global_position: Vector2):
	var dropped_item_entity = dropped_item_entity_scene.instantiate()
	dropped_item_entity.item_data = item
	
	emit_signal("spawn_dropped_item_needed", dropped_item_entity, global_position)
	
