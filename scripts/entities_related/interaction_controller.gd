extends Node2D

@onready var raycast: RayCast2D = $RayCast2D

var current_dir: Vector2

func update_facing_direction(dir: Vector2):
	current_dir = dir
	raycast.target_position = dir * 16
