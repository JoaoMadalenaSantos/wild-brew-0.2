extends Area2D

class_name ItemEater

var dropped_items_in_range: Array[Node2D]

func _on_area_entered(area: Area2D) -> void:
	var dropped_item_node = area.get_parent()
	var item_data = dropped_item_node.get("item_data")
	
	if item_data == null:
		return
	
	if not dropped_item_node.has_method("get_collected"):
		return
	
	dropped_items_in_range.append(dropped_item_node)


func _on_area_exited(area: Area2D) -> void:
	var dropped_item_node = area.get_parent()
	
	if dropped_items_in_range.has(dropped_item_node):
		dropped_items_in_range.erase(dropped_item_node)
