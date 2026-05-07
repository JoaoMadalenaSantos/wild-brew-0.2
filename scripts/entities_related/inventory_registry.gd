extends Node

class_name InventoryRegistry

@export var slot_quantity: int = 4
@export var starting_inventory_data: InventoryData
var current_inventory_data: InventoryData
var current_selected_slot: int = 0
var current_selected_item: ItemData = null

var inventory_locked: bool = false

signal current_selected_item_changed(item: ItemData)

func _ready() -> void:
	refresh_inventory()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("select_slot_1") and not inventory_locked:
		select_slot(0)
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("select_slot_2") and not inventory_locked:
		select_slot(1)
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("select_slot_3") and not inventory_locked:
		select_slot(2)
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("select_slot_4") and not inventory_locked:
		select_slot(3)
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("select_previous_slot") and not inventory_locked:
		select_previous_slot()
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("select_next_slot") and not inventory_locked:
		select_next_slot()
		get_viewport().set_input_as_handled()
		
func select_previous_slot():
	current_selected_slot -= 1
	
	if current_selected_slot < 0:
		current_selected_slot = slot_quantity - 1
	
	select_slot(current_selected_slot)

func select_next_slot():
	current_selected_slot += 1
	
	if current_selected_slot > slot_quantity - 1:
		current_selected_slot = 0
	
	select_slot(current_selected_slot)
		
func select_slot(slot_idx: int):
	current_selected_slot = slot_idx
	print("InventoryRegistry: current_selected_slot is ", current_selected_slot)
	
	refresh_inventory()

func find_slot_for_item(item: ItemData, quantity: int) -> int:
	var slot_for_item
	
	for slot in range(current_inventory_data.slots.size()):
		var slot_data = current_inventory_data.slots[slot]
		
		if slot_data.item != item:
			continue
		
		if slot_data.quantity == item.max_quantity_in_stack:
			continue
			
		slot_for_item = slot
		return slot_for_item
	
	for slot in range(current_inventory_data.slots.size()):
		var slot_data = current_inventory_data.slots[slot]
		
		if slot_data.item != null:
			continue
		else:
			slot_for_item = slot
			return slot_for_item
	
	return -1

func check_if_has_item(item: ItemData, quantity: int) -> bool:
	var remaining_quantity = quantity
	
	for slot in range(current_inventory_data.slots.size()):
		var slot_data = current_inventory_data.slots[slot]
		
		if slot_data.item == item and slot_data.quantity >= 0:
			remaining_quantity -= slot_data.quantity
	
	if remaining_quantity == 0:
		return true
	
	return false

func try_adding_item(item: ItemData, quantity: int) -> bool:
	var slot_for_item = find_slot_for_item(item, quantity)
	
	if slot_for_item == -1:
		print("InventoryRegistry: No space for item in inventory.")
		return false
	
	current_inventory_data.slots[slot_for_item].item = item
	current_inventory_data.slots[slot_for_item].quantity += quantity
	
	refresh_inventory()
	return true

func try_subtracting_item(item: ItemData, quantity: int) -> bool:
	var has_item = check_if_has_item(item, quantity)
	var remaining_quantity = quantity
	
	if not has_item:
		return false
	
	for slot in range(current_inventory_data.slots.size()):
		var slot_data = current_inventory_data.slots[slot]
		
		if slot_data.item == item:
			slot_data.quantity -= remaining_quantity
			
			if slot_data.quantity < 0:
				remaining_quantity = -slot_data.quantity
				slot_data.quantity = 0
				
			if slot_data.quantity >= 0:
				remaining_quantity = 0
		
	if remaining_quantity == 0:
		return true
	else:
		push_error(self, ": Quantity in inventory of item being subtracted was altered between check_if_has_item and subtraction.")
		return false
			
			
		

func refresh_inventory():
	if not current_inventory_data:
		if starting_inventory_data:
			current_inventory_data = starting_inventory_data.duplicate()
			
			while current_inventory_data.slots.size() > slot_quantity:
				current_inventory_data.slots.pop_back()
			
			while current_inventory_data.slots.size() < slot_quantity:
				var slot: SlotData = SlotData.new()
				current_inventory_data.slots.append(slot)
			
		else:
			current_inventory_data = InventoryData.new()
			
			while current_inventory_data.slots.size() < slot_quantity:
				var slot: SlotData = SlotData.new()
				current_inventory_data.slots.append(slot)
	
	for slot in range(current_inventory_data.slots.size()):
		var slot_data = current_inventory_data.slots[slot]
		
		if slot_data.item != null and slot_data.quantity <= 0:
			slot_data.item = null
	
	var inventory_dict: Dictionary
	
	for slot_idx in range(current_inventory_data.slots.size()):
		var slot = current_inventory_data.slots[slot_idx]
		var slot_dict = {"item": slot.item, "quantity": slot.quantity}
		
		inventory_dict[slot_idx] = slot_dict
	
	print("InventoryRegistry: inventory_data is ", inventory_dict)
	
	update_current_selected_item()
	UIService.request_inventory_update(current_inventory_data, current_selected_slot)

func update_current_selected_item():
	var item_in_selected_slot = current_inventory_data.slots[current_selected_slot].item
	
	if item_in_selected_slot:
		current_selected_item = item_in_selected_slot
	else:
		current_selected_item = null
	
	emit_signal("current_selected_item_changed", item_in_selected_slot)
