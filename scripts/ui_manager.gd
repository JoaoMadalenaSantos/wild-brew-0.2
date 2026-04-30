extends Node

@export var pause_screen: Control
@export var transition_screen: Control
@export var level_title_screen: Control
@export var dialogue_screen: Control
@export var hud_screen: Control

func _ready() -> void:
	UIService.close_transition_needed.connect(close_transition_screen)
	UIService.open_transition_needed.connect(open_transition_screen)
	
func close_transition_screen():
	transition_screen.close()

func open_transition_screen():
	transition_screen.open()
