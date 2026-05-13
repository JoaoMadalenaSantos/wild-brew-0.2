extends Node2D

class_name AreasConnection

@onready var area_a_entrance: Area2D = $AreaAEntrance
@onready var area_b_entrance: Area2D = $AreaBEntrance

@export var area_a: LevelArea
@export var area_b: LevelArea

var area_detection_order: Array[Area2D] = []

signal level_area_entered_by_entity(entity: Node2D,level_area: LevelArea)

func _on_area_entered_in_area_a_entrance(area: Area2D):
	if area_detection_order.size() >= 2:
		area_detection_order = []
		area_detection_order.append(area_a_entrance)
	
	if area_detection_order.size() <= 1:
		area_detection_order.append(area_a_entrance)
		
func _on_area_entered_in_area_b_entrance(area: Area2D):
	if area_detection_order.size() >= 2:
		area_detection_order = []
		area_detection_order.append(area_b_entrance)
	
	if area_detection_order.size() <= 1:
		area_detection_order.append(area_b_entrance)

func _on_area_exited_area_a_entrance(area: Area2D):
	if area_detection_order.size() == 2:
		var entity_node = area.get_parent().get_parent()
		emit_signal("level_area_entered_by_entity", entity_node, area_a)

func _on_area_exited_area_b_entrance(area: Area2D):
	if area_detection_order.size() == 2:
		var entity_node = area.get_parent().get_parent()
		emit_signal("level_area_entered_by_entity", entity_node, area_b)
