extends Node2D

enum MinionState {RANDOM, CHASE, IDLE, DEAD}

@export var player : Node2D

var masks : Array[Node2D] = []
var mask_index : int = 0
var state : MinionState = MinionState.DEAD

const strafe_scaler : float = 10
var strafe_vec : Vector2 = Vector2(0,0)
var strafe_cooldown_timer : float = 10

func _ready() -> void:
	masks.append(get_node("RockMask"))
	masks.append(get_node("PaperMask"))
	masks.append(get_node("ScissorMask"))
	masks.append(get_node("BaseMask"))

	for m in masks:
		m.visible = false
	masks.get(0).visible = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		masks.get(mask_index).visible = false
		mask_index = (mask_index+1) % masks.size()
		masks.get(mask_index).visible = true
		state = MinionState.RANDOM
	if event.is_action_pressed("ui_cancel"):
		if state == MinionState.DEAD:
			state = MinionState.IDLE
			visible = true
		else:
			state = MinionState.DEAD
			visible = false

func random_strafe() -> Vector2:
	if strafe_cooldown_timer <= 0:
		# pick a direction, then pick a scaler
		var direction := randf()
		var scaler := randf_range(50.0, 300.0)
		# print("Direction: ", cos(direction), ", ", sin(direction))
		strafe_cooldown_timer = randf_range(3.0, 5.0)
		print("Strafe time: ", strafe_cooldown_timer)
		return Vector2(cos(direction), sin(direction)) * scaler
	else:
		return Vector2(0,0)

func chase_player() -> Vector2:
	return Vector2(1,1)

func _physics_process(_delta: float) -> void:
	if strafe_cooldown_timer > 0:
		strafe_cooldown_timer -= _delta
	print("State", state)
	match state:
		MinionState.DEAD:
			pass
		MinionState.RANDOM:
			print("Random")
			position += random_strafe()
		MinionState.IDLE:
			pass
		MinionState.CHASE:
			position += chase_player()
