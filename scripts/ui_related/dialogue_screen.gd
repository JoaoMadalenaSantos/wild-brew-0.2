extends Control

@export var portrait: TextureRect
@export var text_label: RichTextLabel
@export var input_hint: MarginContainer
@export var timer: Timer

@export var writing_tick_duration: float

var is_active: bool = false
var is_writing: bool = false

signal finish_writing_requested
signal writing_finished
signal finish_line_requested
signal line_finished

func _ready() -> void:
	timer.wait_time = writing_tick_duration
	
	line_finished.connect(UIService._on_dialogue_line_finished)

func _unhandled_input(event: InputEvent) -> void:
	if not is_writing:
		if event.is_action_pressed("interact") and is_active:
			emit_signal("finish_line_requested")
			get_viewport().set_input_as_handled()
	else:
		if event.is_action_pressed("interact") and is_active:
			emit_signal("finish_writing_requested")
			get_viewport().set_input_as_handled()
		

func _process(_delta: float) -> void:
	pass

func display_dialogue(line_text: String, portrait_texture: Texture2D = null):
	if portrait_texture == null:
		portrait.visible = false
	
	text_label.text = ""
	
	is_active = true
	is_writing = true
	
	self.visible = true
	
	if portrait_texture != null:
		portrait.texture = portrait_texture
	
	finish_writing_requested.connect(func(): text_label.text = line_text, CONNECT_ONE_SHOT)
	timer.start()
	
	for character in line_text:
		await timer.timeout
		
		if text_label.text != line_text:
			text_label.text += character
		else:
			break
	
	timer.stop()
	is_writing = false
	emit_signal("writing_finished")
	
	await finish_line_requested
	finish_dialogue()

func finish_dialogue():
	is_active = false
	
	text_label.text = ""
	portrait.texture = null
	self.visible = false
	
	emit_signal("line_finished")
