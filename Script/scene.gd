extends Node2D

var sprites = [
	preload("res://Sprite/shape/PNG/Double/blue_hand_open.png"),
	preload("res://Sprite/shape/PNG/Double/blue_hand_rock.png"),
	preload("res://Sprite/shape/PNG/Double/blue_hand_peace.png")
]

var sprite_index: int = 0
var sprite_nodes = []

func _ready() -> void:
	for i in sprites.size():
		var sprite = Sprite2D.new()
		sprite.texture = sprites[i]
		sprite.position = Vector2(200, 200)
		sprite.visible = false
		add_child(sprite)
		sprite_nodes.append(sprite)
		# sprite_nodes[0].visible = true

# func _input(event: InputEvent) -> void:
# 	if event.is_action_pressed("ui_accept"):
# 		sprite_nodes.get(sprite_index).visible = false
# 		sprite_index = (sprite_index+1) % sprites.size()
# 		sprite_nodes.get(sprite_index).visible = true

func _process(_delta: float) -> void:
	pass
