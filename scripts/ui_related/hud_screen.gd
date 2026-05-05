extends Control

@onready var interaction_hint: MarginContainer = $InteractionHint

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
