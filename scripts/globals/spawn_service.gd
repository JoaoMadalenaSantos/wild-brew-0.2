extends Node

var dropped_item_entity_scene: PackedScene = load("res://scenes/entities/dropped_item.tscn")

signal spawn_entity_needed(entity: Node2D, position: Vector2)

func request_spawn_dropped_item(item: ItemData, global_position: Vector2):
	var dropped_item_entity_node = dropped_item_entity_scene.instantiate()
	dropped_item_entity_node.item_data = item
	
	emit_signal("spawn_entity_needed", dropped_item_entity_node, global_position)

func request_spawn_entity(entity: EntityData, global_position):
	var entity_scene = load(entity.scene_path)
	var entity_node = entity_scene.instantiate()
	
	emit_signal("spawn_entity_needed", entity_node, global_position)
