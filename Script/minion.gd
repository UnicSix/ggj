extends Node2D

enum MinionState {RANDOM, CHASE, IDLE, DEAD}

@export var player : Node2D
@export var camera : Camera2D

var masks : Array[Node2D] = []
var mask_index : int = 0
var state : MinionState = MinionState.RANDOM
var x_bound : Array[float]
var y_bound : Array[float]

const strafe_scaler : float = 10
var delta_pos : Vector2 = Vector2(0,0)
var next_random_delta_pos : Vector2 = Vector2(0,0)
var action_cooldown_timer : float = 0
var enable : bool = true

func _ready() -> void:
	# set movement constraint
	x_bound.append(0)
	x_bound.append(get_window().size.x)
	y_bound.append(0)
	y_bound.append(get_window().size.y)

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

func random_strafe():
	if action_cooldown_timer > 0:
		delta_pos = next_random_delta_pos
	else:
		# if cool down to 0, stop strafe and reset a strafe direction(vec2)
		var direction := randf() * 2 * PI
		var scaler := randf_range(2.0, 3.5)
		next_random_delta_pos = Vector2(cos(direction), sin(direction)) * scaler
		print("next random direction: ", next_random_delta_pos)
		delta_pos = Vector2(0,0)

func dead():
	pass

func idle():
	delta_pos = Vector2(0,0)

func chase_player(scaler : float):
	if action_cooldown_timer > 0:
		print("Player position: ", player.position)
		print("Position: ", position)
		delta_pos = - (position - player.position) / scaler
		print("Delta pos chase ", delta_pos)
	return

func update_bounds():
	var viewport_size = get_viewport_rect().size
	var cam_pos = camera.global_position
	
	x_bound[0] = cam_pos.x - viewport_size.x
	x_bound[1] = cam_pos.x + viewport_size.x
	y_bound[0] = cam_pos.y - viewport_size.y
	y_bound[1] = cam_pos.y + viewport_size.y

func position_valid(pos: Vector2) -> bool:
	print("Position: ", position)
	print("X bound: ", x_bound)
	print("Y bound: ", y_bound)
	if pos.x < x_bound[0]:
		return false
	elif pos.x > x_bound[1]:
		return false
	if pos.y < y_bound[0]:
		return false
	elif pos.y > y_bound[1]:
		return false
	print("Valid position")
	return true

func _physics_process(_delta: float) -> void:
	if enable == false:
		return
	print("State", state)
	print("Cooler", action_cooldown_timer)
	update_bounds()
	match state:
		MinionState.DEAD:
			pass
		MinionState.RANDOM:
			print("Random")
			random_strafe()
		MinionState.IDLE:
			pass
		MinionState.CHASE:
			chase_player(randf_range(30,50))

	if action_cooldown_timer > 0:
		action_cooldown_timer -= _delta
	else:
		var chase_rate: int = 70
		match state:
			MinionState.RANDOM:
				var next_move : int = randi_range(0, 100)
				print("Next move: ", next_move)
				if next_move > chase_rate:
					state = MinionState.CHASE
				action_cooldown_timer = randf_range(1.5, 5.0)
			MinionState.CHASE:
				if position_valid(position):
					state = MinionState.RANDOM

	if !position_valid(position + delta_pos):
		print("invalid position!!!")
		print("State ", state)
		state = MinionState.CHASE
	position += delta_pos

func disable_enemy() -> void:
	visible = false
	call_deferred("defer_disable")

func defer_disable() -> void:
	$CollisionShape2D.disabled = true

func enable_enemy() -> void:
	visible = true
	call_deferred("defer_enable")

func defer_enable() -> void:
	$CollisionShape2D.disabled = false
