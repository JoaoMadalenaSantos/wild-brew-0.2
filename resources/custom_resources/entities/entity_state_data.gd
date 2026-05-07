extends Resource

class_name EntityStateData

@export var movement: MovementStateData
#@export var inventory: InventoryData
#@export var interaction: InteractionState
#@export var effects: EffectsState

func set_entity_state(new_entity_state: EntityStateData):
	movement.position = new_entity_state.movement.position
	movement.dir = new_entity_state.movement.direction
	#inventory = new_entity_state.inventory
	#effects = new_entity_state.effects
