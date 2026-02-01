extends Node2D

# TODO:
# 1. spawn shard and enemy
const shard = preload("res://Scene/mask_shard.tscn")
const enemy = preload("res://Scene/enemy.tscn")

class ShardPool:
	var capacity : int = 30
	var size : int = 0
	var shards : Array[Area2D]

class EnemyPool:
	var capacity : int = 10
	var size : int = 5
	var enemies : Array[Area2D]

var sprite_index: int = 0
var shard_pool = ShardPool.new()
var enemy_pool = EnemyPool.new()

func _ready() -> void:
	for i in range(shard_pool.capacity):
		var new_shard = shard.instantiate()
		new_shard.position = $PurplePlayer.position + Vector2(30+i*150, 300)
		new_shard.shard_type = randi_range(Player.MaskType.ROCK, Player.MaskType.SCISSOR)
		new_shard.disable_shard()
		shard_pool.shards.append(new_shard)
		add_child(new_shard)

	var spawn_count : int = enemy_pool.size
	for i in range(enemy_pool.capacity+1):
		print("Spawn ", i, " enemies")
		var new_enemy = enemy.instantiate()
		var rad = randf_range(0, PI*2)
		new_enemy.position = $PurplePlayer.position + Vector2(cos(rad), sin(rad)) * randi_range(300, 550)
		if spawn_count == 0:
			new_enemy.call_deferred("disable_enemy")
		else:
			new_enemy.enable_enemy()
			spawn_count -= 1
		enemy_pool.enemies.append(new_enemy)
		add_child(new_enemy)

	$EnemySpawnTimer.start()
	$PurplePlayer.connect("player_dead", _on_player_dead)

func _on_player_dead(is_dead: bool):
	if is_dead:
		get_tree().change_scene_to_file("res://Scene/lose_scene.tscn")

func _physics_process(_delta: float) -> void:
	pass

func _on_enemy_spawn_timer_timeout() -> void:
	if enemy_pool.size < enemy_pool.capacity:
		print("Spawn enemy", enemy_pool.size)
		enemy_pool.size += 1
		enemy_pool.enemies.get(enemy_pool.size).enable_enemy()

func _on_enemy_dead(target: Area2D) -> void:
	var last_enemy = enemy_pool.enemies.get(enemy_pool.size)
	for i in range(enemy_pool.size):
		if enemy_pool.enemies[i] == target:
			print("swap to last enemy")
			var tmp = enemy_pool.enemies[i]
			enemy_pool.enemies[i] = last_enemy
			last_enemy = tmp
			enemy_pool.size -= 1
