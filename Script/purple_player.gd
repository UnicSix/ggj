extends Node2D

signal mask_level_change(level: int, mask_type: int)
signal mask_index_change(index: int)

enum MaskType {ROCK, PAPER, SCISSOR}

var velocity : float = 500
var chosen_mask : int = 0
var mask_level : Array[int] = [0, 0, 0]
const MASK_COUNT : int = 3
const MAX_LEVEL : int = 3

# y axis is pointing down
func _ready() -> void:
	position = Vector2(500, 100)

func _input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if event.is_action_pressed("rock"):
		print("Signal Pressed Rock")
		chosen_mask = MaskType.ROCK
		mask_index_change.emit(chosen_mask)
	elif event.is_action_pressed("paper"):
		print("Signal Pressed Paper")
		chosen_mask = MaskType.PAPER
		mask_index_change.emit(chosen_mask)
	elif event.is_action_pressed("scissor"):
		print("Signal Pressed Scissor")
		chosen_mask = MaskType.SCISSOR
		mask_index_change.emit(chosen_mask)
	if event.is_action_pressed("ui_accept"):
		if mask_level[chosen_mask]+1 < MAX_LEVEL:
			mask_level[chosen_mask] += 1
		mask_level_change.emit(mask_level[chosen_mask], chosen_mask)

func player_input() -> Vector2:
	var direction = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	return direction * velocity
	
func _physics_process(delta: float) -> void:
	position += player_input() * delta
