extends Resource

class_name InteractionData

@export var action_hint: String = "Interact"
#@export var needs_confirmation: bool = false # Shows a dialog pop up with standard text to confirm action before procceding

# Before item change narration
@export var narration_on_action: Array[DialogueLineData] # Can have portrait if entity is an NPC

# Item change
#@export var item_change: Dictionary {ItemData: int} # List of items changed (consumed or gained) as result of action
#@export var item_change_chance: float = 1.0 # From 0.0 to 1.0, is applied to each unit of item change

# Post item change narration
#@export var narration_on_item_changed: Array[DialogueLineData]
#@export var narration_on_item_unchanged: Array[DialogueLineData]

# Post item change sound
#@export var sound_on_item_changed: AudioStream
#@export var sound_on_item_unchanged: AudioStream
