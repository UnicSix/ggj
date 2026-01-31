extends Area2D

var shard_type : int = Player.MaskType.ROCK

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		print("Player picked uppppppp")
		call_deferred("disable_shard")

func disable_shard():
	$Sprite.visible = false
	$Collider.disabled = true
