extends Node2D

class_name InventoryComponent

@export var holding_item_sprite: Sprite2D
@export var item_eater: Area2D
@export var item_magnet: ItemMagnet
@export var inventory_registry: InventoryRegistry

func _ready() -> void:
	InteractionSystem.item_spending_needed.connect(spend_item)

func _process(delta: float) -> void:
	_process_item_magnet()
	_process_item_eater()
	

func _process_item_magnet():
	if not item_magnet:
		return
	
	if item_magnet.dropped_items_in_range.is_empty():
		return
	
	for dropped_item in item_magnet.dropped_items_in_range:
		var item_data = dropped_item.get("item_data")
		var target = dropped_item.get("target")
		
		if target != null and target != item_eater:
			continue
		
		if target == null or target == item_eater:
			if inventory_registry.find_slot_for_item(item_data, 1) == -1:
				dropped_item.set_target(null)
				continue
			
			dropped_item.set_target(item_eater)

func _process_item_eater():
	if not item_eater:
		return
	
	if item_eater.dropped_items_in_range.is_empty():
		return
	
	for dropped_item in item_eater.dropped_items_in_range:
		var item_data = dropped_item.get("item_data")
		var target = dropped_item.get("target")
		
		if target != null and target != item_eater:
			continue
		
		if target == item_eater:
			var slot_for_item = inventory_registry.find_slot_for_item(item_data, 1)
			
			if slot_for_item == -1:
				dropped_item.set_target(null)
				continue
			
			if inventory_registry.try_adding_item(item_data, 1):
				dropped_item.get_collected()

func spend_item(item: ItemData, quantity: int):
	inventory_registry.try_subtracting_item(item, quantity)
