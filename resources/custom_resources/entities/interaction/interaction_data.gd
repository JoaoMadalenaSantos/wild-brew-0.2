extends Resource

class_name InteractionData

@export var action_hint: String = "Interact"
#@export var needs_confirmation: bool = false # Shows a dialog pop up with standard text to confirm action before procceding

# Before item change narration
@export var narration_on_action: Array[DialogueLineData] # Can have portrait if entity is an NPC

# Item cost
@export var item_cost: Dictionary [ItemData, int]
#@export var item_spending_chance: float = 1.0
#@export var sound_on_item_spent: AudioStream
#@export var narration_on_item_spent: Array[DialogueLineData]

# Interaction result
#@export var success_chance: float = 1.0

#@export var sound_on_success: AudioStream
#@export var narration_on_success: Array[DialogueLineData]

#@export var sound_on_fail: AudioStream
#@export var narration_on_fail: Array[DialogueLineData]

# Item result
@export var item_result: Dictionary [ItemData, int]
#@export var item_gaining_chance: float = 1.0
#@export var sound_on_item_gained: AudioStream
#@export var narration_on_item_gained: Array[DialogueLineData]
