extends Resource

class_name EntityData

@export var display_name: String
@export var scene_path: String

@export var portraits: Dictionary [UIService.DialogueLineMood, Texture2D] = {UIService.DialogueLineMood.NONE: null}

@export var interactions: Array[InteractionData]
#@export var automatic_changes: Array[EntityAutomaticChangeData]
