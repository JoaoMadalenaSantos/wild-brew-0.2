extends Node

class_name EntityManager

@export var world_y_sort_container: Node2D
@onready var areas_connection: AreasConnection = $"../AreasConnection"

func _ready() -> void:
	areas_connection.level_area_entered_by_entity.connect(request_add_entity_to_area)

func request_add_entity_to_area(entity: Node2D, area: LevelArea):
	call_deferred("add_entity_to_area", entity, area)

func add_entity_to_area(entity: Node2D, area: LevelArea):
	var area_y_sort_node = area.y_sort_node
	
	entity.reparent(area_y_sort_node, true)
	
	if not entity.is_in_group("player"):
		area_y_sort_node.move_child(entity, 0)

func subtract_entity_from_area(entity: Node2D, area: LevelArea):
	var parent_area: LevelArea = area.get_parent().get_parent()
	var parent_area_y_sort_node = parent_area.y_sort_node
	
	entity.reparent(parent_area_y_sort_node, true)
	
	if not entity.is_in_group("player"):
		parent_area_y_sort_node.move_child(entity, 0)
