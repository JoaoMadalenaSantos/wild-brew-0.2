extends Control

@export var ui_manager: Node

@onready var color_rect: ColorRect = $ColorRect
@onready var timer: Timer = $Timer

@export var transition_duration: float = 0.5

var current_diameter: float
var target_diameter: float

signal open_finished
signal close_finished

func _ready() -> void:
	setup_max_diameter()
	
	open_finished.connect(UIService._on_transition_open_finished)
	close_finished.connect(UIService._on_transition_close_finished)
	
func _process(delta: float) -> void:
	if current_diameter == target_diameter:
		return
	else:
		color_rect.material.set_shader_parameter("circle_diameter", current_diameter)

func setup_max_diameter():
	current_diameter = sqrt(get_viewport().size.x ** 2 + get_viewport().size.y ** 2) + 50
	target_diameter = sqrt(get_viewport().size.x ** 2 + get_viewport().size.y ** 2) + 50
	
	color_rect.material.set_shader_parameter("circle_diameter", current_diameter)

func open(delay: float = 0.1):
	timer.wait_time = delay
	timer.start()
	
	timer.timeout.connect(_on_timer_timeout, CONNECT_ONE_SHOT)
	
func _on_timer_timeout():
	target_diameter = sqrt(get_viewport().size.x ** 2 + get_viewport().size.y ** 2) + 50
	
	var tween = create_tween()
	tween.tween_property(self, "current_diameter", target_diameter, transition_duration)
	
	tween.finished.connect(func():
		emit_signal("open_finished")
		visible = false,
		CONNECT_ONE_SHOT
	)
	
	await tween.finished

func close():
	visible = true
	target_diameter = 0.0
	
	var tween = create_tween()
	tween.tween_property(self, "current_diameter", target_diameter, transition_duration)
	
	tween.finished.connect(func():
		print("close finished signaled")
		emit_signal("close_finished"),
		CONNECT_ONE_SHOT
	)
	
	await tween.finished
