extends Node

signal item_spending_needed(item_data: ItemData, quantity: int)
signal interaction_finished

func apply_interaction(interacting_entity: Node, interacted_entity: Node, interaction: InteractionData):
	var interacted_entity_data: EntityData = interacted_entity.get("entity_data")
	
	UIService.request_hide_interaction_hint()
	
	if not interaction.narration_on_action.is_empty():
		for line in interaction.narration_on_action:
			var portrait_texture = interacted_entity_data.portraits[line.mood]
			
			UIService.request_display_dialogue_line(self, line.text, portrait_texture)
			
			await UIService.dialogue_line_finished
			
	if not interaction.item_cost.is_empty():
		for item in interaction.item_cost:
			var item_data = item
			var quantity = interaction.item_cost[item]
			
			# Apply chance later here serving as condition to emit the signal
			
			emit_signal("item_spending_needed", item_data, quantity)
	
	if not interaction.item_result.is_empty():
		for item in interaction.item_result:
			var quantity = interaction.item_result[item]
			
			for item_unit in range(quantity):
				print("trying to spawn item_result as dropped items")
				SpawnService.request_spawn_dropped_item(item, interacted_entity.global_position)
				
	if interaction.result_entity:
		var position = interacted_entity.global_position
		interacted_entity.queue_free()
		SpawnService.request_spawn_entity(interaction.result_entity, position)
	
	emit_signal("interaction_finished")
		
