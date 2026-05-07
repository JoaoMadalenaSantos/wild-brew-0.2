extends Control

@onready var interaction_hint: MarginContainer = $InteractionHint
@onready var inventory: MarginContainer = $Inventory

var current_inventory_data: InventoryData
var current_selected_slot
var slot_list: Array[Button]

func _ready() -> void:
	setup_inventory_slots()

#region InteractionHint

func display_interaction_hint(hint_text: String):
	var label_node = interaction_hint.find_child("TextHint",true)
	
	if label_node:
		label_node.text = hint_text
	
	#for child in self.get_children():
		#if child is MarginContainer:
			#child.queue_sort()
	
	interaction_hint.visible = true

func hide_interaction_hint():
	interaction_hint.visible = false

#endregion

#region Inventory

func setup_inventory_slots():
	var slots_container = inventory.get_child(0, true).get_child(0, true).get_child(0, true)
	var slots_container_children = slots_container.get_children()
	
	for child in slots_container_children:
		if child is Button:
			slot_list.append(child)

func update_inventory(inventory_data: InventoryData, selected_slot: int):
	change_inventory_data(inventory_data)
	change_selected_slot(selected_slot)

func change_inventory_data(inventory_data: InventoryData):
	var inventory_dict: Dictionary
	for slot_idx in range(inventory_data.slots.size()):
		var slot = inventory_data.slots[slot_idx]
		var slot_dict = {"item": slot.item, "quantity": slot.quantity}
		inventory_dict[slot_idx] = slot_dict
	print("HUDScreen: inventory_data is ", inventory_dict)
	
	#if current_inventory_data == inventory_data:
		#return
	
	current_inventory_data = inventory_data
	
	#var inventory_dict: Dictionary
	#for slot_idx in range(current_inventory_data.slots.size()):
		#var slot = current_inventory_data.slots[slot_idx]
		#var slot_dict = {"item": slot.item, "quantity": slot.quantity}
		#inventory_dict[slot_idx] = slot_dict
	#print("HUDScreen: inventory_data is ", inventory_dict)
	
	
	for slot in range(slot_list.size()):
		var slot_button = slot_list[slot] 
		var quantity_label = slot_button.find_child("ItemQuantity", false).get_child(0)
		
		if current_inventory_data.slots[slot].item and current_inventory_data.slots[slot].quantity > 0:
			slot_button.icon = current_inventory_data.slots[slot].item.sprite
			
			if quantity_label is Label:
				quantity_label.text = str(current_inventory_data.slots[slot].quantity)
		
		else:
			slot_button.icon = null
			quantity_label.text = ""

func change_selected_slot(slot_index: int):
	if current_selected_slot == slot_index:
		return
	
	current_selected_slot = slot_index
	
	for slot in range(slot_list.size()):
		if slot != current_selected_slot:
			slot_list[slot].toggle_mode = true
			slot_list[slot].button_pressed = false
			slot_list[slot].custom_minimum_size = Vector2(22.0, 22.0)
		else:
			slot_list[slot].toggle_mode = false
			slot_list[slot].custom_minimum_size = Vector2(26.0, 26.0)

#endregion
