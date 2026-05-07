extends Node2D

@export var attraction_delay_timer: Timer
@export var item_sprite: Sprite2D

var item_data: ItemData

var starting_random_position := Vector2.ZERO

var target: Node2D = null
var attraction_locked = true

func _ready() -> void:
	if attraction_delay_timer:
		attraction_delay_timer.timeout.connect(_on_attraction_delay_finished)
	else:
		attraction_locked = false
	
	starting_random_position = Vector2(
			randf_range(global_position.x - 10, global_position.x + 10),
			randf_range(global_position.y - 10, global_position.y + 10)
		)
	
	item_sprite.texture = item_data.sprite

func _process(delta: float) -> void:
	if attraction_locked:
		global_position = lerp(global_position, starting_random_position, delta * 1)
	
	if target:
		var distance = global_position.distance_to(target.global_position)
		var t = 1.0 - clamp(distance / 100.0, 0.0, 1.0)
		var speed = lerp(0.0, 100.0, t)
		
		global_position = global_position.move_toward(target.global_position + Vector2(-8.0, 0.0), delta * speed)

func set_target(new_target: Node2D):
	if attraction_locked:
		return
	
	target = new_target

func get_collected():
	queue_free()

func _on_attraction_delay_finished():
	attraction_locked = false
