extends Resource

class_name ItemData

@export var display_name: String
@export var description: String
@export var sprite: Texture2D

@export var max_quantity_in_stack: int
#enum ItemType {IINGREDIENT, TEA, OTHER}
#@export var item_type: ItemType
#@export var composition: Array[ItemData]

#@export var interaction: ItemInteractionData
#@export var automatic_changes: Array[ItemAutomaticChangeData]
