extends Node2D

signal enemy_dead(target: Area2D)

enum MinionState {RANDOM, CHASE, IDLE, DEAD}
enum MinionLevel {LV1, LV2, LV3, BOSS}

@onready var player : Node2D = get_parent().get_node("PurplePlayer")
@onready var camera : Camera2D = get_parent().get_node("PlayerCamera")

var mask_index : int = 0
var current_mask_type : Player.MaskType = Player.MaskType.ROCK
var current_mask_level : int = 0
var mask_levels : Array[int] = [1, 0, 2]
var enemy_level : MinionLevel = MinionLevel.LV1

var state : MinionState = MinionState.RANDOM
var x_bound : Array[float]
var y_bound : Array[float]

const strafe_scaler : float = 10
var delta_pos : Vector2 = Vector2(0,0)
var next_random_delta_pos : Vector2 = Vector2(0,0)
var action_cooldown_timer : float = 0
var enable : bool = false

@onready var mask_node_ref : Array[Node2D] = [$Rocks, $Papers, $Scissors]

func _ready() -> void:
	player.enemy_combat_result.connect(_on_enemy_combat_result)
	# set movement constraint
	x_bound.append(0)
	x_bound.append(get_window().size.x)
	y_bound.append(0)
	y_bound.append(get_window().size.y)

	# select a init mask
	current_mask_type = randi_range(Player.MaskType.ROCK, Player.MaskType.SCISSOR) as Player.MaskType
	await get_tree().process_frame
	for i in range(mask_node_ref.size()):
		# Disable mask parent
		mask_node_ref[i].visible = false
		# Disable mask sprites at different levels
		for child in mask_node_ref[i].get_children():
			if child is Sprite2D:
				child.visible = false

func random_strafe():
	if action_cooldown_timer > 0:
		delta_pos = next_random_delta_pos
	else:
		# if cool down to 0, stop strafe and reset a strafe direction(vec2)
		var direction := randf() * 2 * PI
		var scaler := randf_range(2.0, 3.5)
		next_random_delta_pos = Vector2(cos(direction), sin(direction)) * scaler
		delta_pos = Vector2(0,0)

func idle():
	delta_pos = Vector2(0,0)

func chase_player(scaler : float):
	if action_cooldown_timer > 0:
		delta_pos = - (position - player.position) / scaler
	return

func update_bounds():
	var viewport_size = get_viewport_rect().size
	var cam_pos = camera.global_position
	
	x_bound[0] = cam_pos.x - viewport_size.x
	x_bound[1] = cam_pos.x + viewport_size.x
	y_bound[0] = cam_pos.y - viewport_size.y
	y_bound[1] = cam_pos.y + viewport_size.y

func position_valid(pos: Vector2) -> bool:
	# print("Position: ", position)
	# print("X bound: ", x_bound)
	# print("Y bound: ", y_bound)
	if pos.x < x_bound[0]:
		return false
	elif pos.x > x_bound[1]:
		return false
	if pos.y < y_bound[0]:
		return false
	elif pos.y > y_bound[1]:
		return false
	# print("Valid position")
	return true

func _physics_process(_delta: float) -> void:
	if enable == false:
		return
	# print("State", state)
	# print("Cooler", action_cooldown_timer)
	update_bounds()
	match state:
		MinionState.DEAD:
			pass
		MinionState.RANDOM:
			# print("Random")
			random_strafe()
		MinionState.IDLE:
			pass
		MinionState.CHASE:
			chase_player(randf_range(100,200))

	if action_cooldown_timer > 0:
		action_cooldown_timer -= _delta
	else:
		var chase_rate: int = 50
		match state:
			MinionState.RANDOM:
				var next_move : int = randi_range(0, 100)
				if next_move > chase_rate:
					state = MinionState.CHASE
				action_cooldown_timer = randf_range(1.5, 5.0)
			MinionState.CHASE:
				if position_valid(position):
					state = MinionState.RANDOM

	if !position_valid(position + delta_pos):
		# print("invalid position!!!")
		state = MinionState.CHASE
	position += delta_pos
	$Animation.flip_h = delta_pos.x < 0

func disable_enemy() -> void:
	visible = false
	# disable currently enabled mask
	mask_node_ref[current_mask_type].visible = false
	mask_node_ref[current_mask_type].get_child(mask_levels[current_mask_type]).visible = false
	call_deferred("defer_disable")

func defer_disable() -> void:
	$Collider.disabled = true

func enable_enemy() -> void:
	print("Enabled enemy")
	visible = true
	enable = true
	call_deferred("defer_enable")

func defer_enable() -> void:
	$Collider.disabled = false

func _on_area_entered(_area: Area2D) -> void:
	if !$Collider.disabled && _area.is_in_group("Player"):
		print("Area entered")
		toggle_mask_display(true)
		redraw_enemy(false)

func toggle_mask_display(on: bool) -> void:
	if on:
		mask_node_ref[current_mask_type].visible = true
		mask_node_ref[current_mask_type].get_child(mask_levels[current_mask_type]).visible = true
	else:
		mask_node_ref[current_mask_type].visible = false
		for child in mask_node_ref[current_mask_type].get_children():
			child.visible = false

func redraw_enemy(level_change: bool = false) -> void:
	if !level_change:
		current_mask_type = randi_range(Player.MaskType.ROCK, Player.MaskType.SCISSOR) as Player.MaskType
		return
	var min_level : int = 0
	var max_level : int = 0
	enemy_level = randi_range(MinionLevel.LV1, MinionLevel.LV3) as MinionLevel
	match enemy_level:
		MinionLevel.LV1:
			$Animation.play("lvevl1")
			pass
		MinionLevel.LV2:
			max_level = 1
			$Animation.play("level2")
		MinionLevel.LV3:
			min_level = 1
			max_level = 2
			$Animation.play("level3")
		MinionLevel.BOSS:
			$Animation.play("boss")
			min_level = 2
			max_level = 2
	current_mask_type = randi_range(Player.MaskType.ROCK, Player.MaskType.SCISSOR) as Player.MaskType
	mask_levels[current_mask_type] = randi_range(min_level, max_level) as MinionLevel

func _on_enemy_combat_result(result: Player.CombatResult, target: Node2D) -> void:
	if target != self:
		return
	call_deferred("defer_disable")
	match result:
		Player.CombatResult.LOSE:
			match enemy_level:
				MinionLevel.LV1:
					$Animation.rotation = -PI / 4
					$Animation.play("lv1_hurt")
				MinionLevel.LV2:
					$Animation.play("lv2_hurt")
				MinionLevel.LV3:
					$Animation.play("lv3_hurt")
				MinionLevel.BOSS:
					$Animation.play("boss_hurt")
					$Animation.play("boss_dead")
			await $Animation.animation_finished
			enable = false
			$Animation.rotation = 0
			redraw_enemy()
			enemy_dead.emit(self)
			disable_enemy()
		Player.CombatResult.DRAW:
			pass
		Player.CombatResult.WIN:
			if enemy_level != MinionLevel.BOSS:
				enemy_level = (enemy_level + 1) as MinionLevel
				redraw_enemy()
		_:
			pass
	toggle_mask_display(false)
	state = MinionState.RANDOM
	call_deferred("defer_disable")
	$CombatCooler.start()

func _on_combat_cooler_timeout() -> void:
	if enable:
		call_deferred("defer_enable")
	toggle_mask_display(false)
