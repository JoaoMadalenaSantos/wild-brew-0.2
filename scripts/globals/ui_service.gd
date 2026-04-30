extends Node

var current_transition_requester: Node = null

signal close_transition_needed()
signal open_transition_needed()
signal transition_open_finished()
signal transition_close_finished()

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
		print("no current_transition_requester_found")
		return

	if current_transition_requester.has_method("_on_transition_close_finished"):
		transition_close_finished.connect(current_transition_requester._on_transition_close_finished)
	
	emit_signal("transition_close_finished")
	print("transition close finished signaled")
	
	if current_transition_requester.has_method("_on_transition_close_finished"):
		transition_close_finished.disconnect(current_transition_requester._on_transition_close_finished)
	
	current_transition_requester = null
