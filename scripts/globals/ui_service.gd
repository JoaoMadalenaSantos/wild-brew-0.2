extends Node

var current_transition_requester: Node = null
var current_dialogue_requester: Node = null

enum DialogueLineMood {
	NONE,
	NEUTRAL,
	HAPPY,
	SAD,
	CONFUSED,
	NERVOUS
}

signal close_transition_needed
signal open_transition_needed
signal transition_open_finished
signal transition_close_finished

signal interaction_hint_needed(hint_text: String)
signal interaction_hint_not_needed
signal inventory_update_needed(inventory_data: InventoryData, selected_slot: int)

signal display_dialogue_lines_needed(line_text: String, portrait: Texture2D)
signal dialogue_line_finished

#region TransitionService
func request_close_transition(requester: Node):
	current_transition_requester = requester
	emit_signal("close_transition_needed")

func request_open_transition(requester: Node):
	current_transition_requester = requester
	emit_signal("open_transition_needed")
	
func _on_transition_open_finished():
	if not current_transition_requester:
		return

	if not current_transition_requester.has_method("_on_transition_open_finished"):
		return
	
	transition_open_finished.connect(current_transition_requester._on_transition_open_finished)
	emit_signal("transition_open_finished")
	
	transition_open_finished.disconnect(current_transition_requester._on_transition_open_finished)
	current_transition_requester = null

func _on_transition_close_finished():
	if not current_transition_requester:
		return

	if current_transition_requester.has_method("_on_transition_close_finished"):
		transition_close_finished.connect(current_transition_requester._on_transition_close_finished)
	
	emit_signal("transition_close_finished")
	
	if current_transition_requester.has_method("_on_transition_close_finished"):
		transition_close_finished.disconnect(current_transition_requester._on_transition_close_finished)
	
	current_transition_requester = null

#endregion

#region HUDService

func request_display_interaction_hint(hint_text: String):
	emit_signal("interaction_hint_needed", hint_text)

func request_hide_interaction_hint():
	emit_signal("interaction_hint_not_needed")

func request_inventory_update(inventory_data: InventoryData, selected_slot: int):
	emit_signal("inventory_update_needed", inventory_data, selected_slot)
	
#endregion

#region DialogueService

func request_display_dialogue_line(requester: Node, line_text: String, portrait: Texture2D = null):
	current_dialogue_requester = requester
	emit_signal("display_dialogue_lines_needed", line_text, portrait)
	
func _on_dialogue_line_finished():
	var requester = current_dialogue_requester
	current_dialogue_requester = null
	
	if requester.has_method("_on_dialogue_line_finished"):
		dialogue_line_finished.connect(requester._on_dialogue_finished)
	
	emit_signal("dialogue_line_finished")
	
	if requester.has_method("_on_dialogue_line_finished"):
		dialogue_line_finished.disconnect(requester._on_dialogue_finished)
	
#endregion
