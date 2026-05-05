extends Node

@export var pause_screen: Control
@export var transition_screen: Control
@export var level_title_screen: Control
@export var dialogue_screen: Control
@export var hud_screen: Control

func _ready() -> void:
	UIService.close_transition_needed.connect(close_transition_screen)
	UIService.open_transition_needed.connect(open_transition_screen)
	
	UIService.interaction_hint_needed.connect(display_interaction_hint)
	UIService.interaction_hint_not_needed.connect(hide_interaction_hint)
	
	UIService.display_dialogue_lines_needed.connect(display_dialogue)

#region Transition

func close_transition_screen():
	transition_screen.close()

func open_transition_screen():
	transition_screen.open()

#endregion

#region HUD

func display_interaction_hint(hint_text: String):
	hud_screen.display_interaction_hint(hint_text)
	pass

func hide_interaction_hint():
	hud_screen.hide_interaction_hint()
	pass

#endregion

#region Dialogue

func display_dialogue(line_text: String, portrait: Texture2D = null):
	dialogue_screen.display_dialogue(line_text, portrait)

#endregion
