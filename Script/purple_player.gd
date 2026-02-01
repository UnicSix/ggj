class_name Player
extends Node2D

signal mask_level_change(level: int, mask_type: int)
signal mask_index_change(index: int)
signal enemy_combat_result(result: CombatResult, tartet: Node2D)
signal player_dead(is_dead: bool)

enum MaskType {ROCK, PAPER, SCISSOR, NONE}
enum CombatResult {WIN, LOSE, DRAW}
enum MaskCounter {WIN, LOSE, DRAW}

var velocity : float = 500
var chosen_mask : MaskType = MaskType.ROCK
var mask_level : Array[int] = [0, 0, 0]
var health : int = 10
const MASK_COUNT : int = 3
const MAX_LEVEL : int = 3

# y axis is pointing down
func _ready() -> void:
	position = Vector2(500, -100)

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
	# trigger level-up event with other condition
	# if event.is_action_pressed("ui_accept"):
	# 	if mask_level[chosen_mask]+1 < MAX_LEVEL:
	# 		mask_level[chosen_mask] += 1
	# 	mask_level_change.emit(mask_level[chosen_mask], chosen_mask)

func player_input() -> Vector2:
	var direction = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	return direction * velocity
	
func _physics_process(delta: float) -> void:
	if $CollisionShape2D.disabled:
		return
	var delta_pos = player_input() * delta
	position += delta_pos
	$AnimatedSprite2D.flip_h = delta_pos.x < 0
	if health <= 0:
		player_dead.emit(true)

func _on_area_entered(_area: Area2D) -> void:
	if _area.is_in_group("Shard"):
		# distinguish the shard type
		if _area.shard_type == MaskType.ROCK :
			print("ROCK SHARDDDDDDDD")
		elif _area.shard_type == MaskType.PAPER :
			print("PAPER SHARDDDDDDDD")
		elif _area.shard_type == MaskType.SCISSOR :
			print("SCISSOR SHARDDDDDDDD")
	elif _area.is_in_group("Enemy"):
		print("Meet enemy!!!!!")
		var result = combat(_area.current_mask_type, _area.current_mask_level)
		match result:
			CombatResult.WIN:
				print("Player Winnnnn")
				enemy_combat_result.emit(CombatResult.LOSE, _area)
			CombatResult.LOSE:
				print("Player Loseeeee")
				call_deferred("toggle_player", false)
				$AnimatedSprite2D.play("lose")
				await $AnimatedSprite2D.animation_finished
				call_deferred("toggle_player", true)
				$AnimatedSprite2D.play("default")
				enemy_combat_result.emit(CombatResult.WIN, _area)
			CombatResult.DRAW:
				print("Player Drawwww")
				enemy_combat_result.emit(CombatResult.DRAW, _area)
		print("Player level: ", mask_level[chosen_mask])

func counterd(player: MaskType, enemy: MaskType) -> MaskCounter :
	if player == MaskType.ROCK && enemy == MaskType.ROCK:
		return MaskCounter.DRAW
	elif player == MaskType.ROCK && enemy == MaskType.PAPER:
		return MaskCounter.LOSE
	elif player == MaskType.ROCK && enemy == MaskType.SCISSOR:
		return MaskCounter.WIN
	elif player == MaskType.PAPER && enemy == MaskType.ROCK:
		return MaskCounter.WIN
	elif player == MaskType.PAPER && enemy == MaskType.PAPER:
		return MaskCounter.DRAW
	elif player == MaskType.PAPER && enemy == MaskType.SCISSOR:
		return MaskCounter.LOSE
	elif player == MaskType.SCISSOR && enemy == MaskType.ROCK:
		return MaskCounter.LOSE
	elif player == MaskType.SCISSOR && enemy == MaskType.PAPER:
		return MaskCounter.WIN
	elif player == MaskType.SCISSOR && enemy == MaskType.SCISSOR:
		return MaskCounter.DRAW
	else:
		return MaskCounter.DRAW

func combat(_mask : int, _level : int) -> CombatResult:
	var combat_result : Player.CombatResult
	var current_mask_level = mask_level[chosen_mask]

	var counter_result = counterd(chosen_mask, _mask)
	if counter_result == MaskCounter.WIN:
		if _level > current_mask_level:
			combat_result = CombatResult.WIN
		elif _level == current_mask_level:
			combat_result = CombatResult.WIN
		else:
			combat_result = CombatResult.DRAW
	elif counter_result == MaskCounter.DRAW:
		if _level > current_mask_level:
			combat_result = CombatResult.LOSE
		elif _level == current_mask_level:
			combat_result = CombatResult.LOSE
		else:
			combat_result = CombatResult.DRAW
	else:
		if _level > current_mask_level:
			combat_result = CombatResult.LOSE
		elif _level == current_mask_level:
			combat_result = CombatResult.LOSE
		else:
			combat_result = CombatResult.DRAW
	if combat_result == CombatResult.WIN:
		var new_level = mask_level[chosen_mask] + 1
		if new_level > 2: new_level = 2
		mask_level_change.emit(new_level, chosen_mask)
	elif combat_result == CombatResult.LOSE:
		health -= 1

	return combat_result

func toggle_player(on : bool):
	$CollisionShape2D.disabled = !on
