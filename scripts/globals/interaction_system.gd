extends Node

signal interaction_finished

func apply_interaction(entity_data: EntityData):
	var interaction_data = get_interaction(entity_data)
	UIService.request_hide_interaction_hint()
	
	if not interaction_data.narration_on_action.is_empty():
		for line in interaction_data.narration_on_action:
			var portrait_texture = entity_data.portraits[line.mood]
			
			UIService.request_display_dialogue_line(self, line.text, portrait_texture)
			
			await UIService.dialogue_line_finished
	
	emit_signal("interaction_finished")

func get_interaction(entity_data: EntityData) -> InteractionData:
	var interaction = entity_data.interactions[0]
	
	if interaction:
		UIService.request_display_interaction_hint(interaction.action_hint)
	else:
		UIService.request_hide_interaction_hint()
	
	return interaction
	
	# Todo: Add loop to manage entities with more than one interaction
	#for interaction_data in entity_data.interactions:
		# Todo: Logic to check if context meet interaction conditions (inventory)
		
