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
	var capacity : int = 30
	var size : int = 5
	var enemies : Array[Area2D]

var sprite_index: int = 0
var shard_pool = ShardPool.new()
var enemy_pool = EnemyPool.new()

func _ready() -> void:
	for i in range(shard_pool.capacity):
		var new_shard = shard.instantiate()
		new_shard.position = $PurplePlayer.position + Vector2(30+i*15, 30)
		new_shard.shard_type = randi_range(Player.MaskType.ROCK, Player.MaskType.SCISSOR)
		print("CreateNewShard: ", new_shard.shard_type)
		new_shard.disable_shard()
		shard_pool.shards.append(new_shard)
		add_child(new_shard)

	var spawn_count : int = enemy_pool.size
	for i in range(enemy_pool.capacity):
		var new_enemy = enemy.instantiate()
		var rad = randf_range(0, PI*2)
		new_enemy.position = $PurplePlayer.position + Vector2(cos(rad), sin(rad)) * randi_range(10, 15)
		if spawn_count == 0:
			new_enemy.disable_enemy()
		else:
			new_enemy.enable_enemy()
			spawn_count -= 1


	return

func _physics_process(_delta: float) -> void:
	pass


func _on_enemy_spawn_timer_timeout() -> void:
	# if enemy pool not full, spawn new enemy
	return
