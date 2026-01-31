extends Node2D

@export var player : Node2D

var rocks : Array[Sprite2D]
var papers : Array[Sprite2D]
var scissors : Array[Sprite2D]

var mask_sprites
var mask_level = [0, 0, 0]
var current_mask_type : int = 0

func get_sprites_from_node(node: Node) -> Array[Sprite2D]:
	var sprites: Array[Sprite2D] = []
	for child in node.get_children():
		if child is Sprite2D:
			child.visible = false
			sprites.append(child)
	return sprites

func _ready() -> void:
	rocks = get_sprites_from_node($Rocks)
	papers = get_sprites_from_node($Papers)
	scissors = get_sprites_from_node($Scissors)
	mask_sprites = [rocks, papers, scissors]
	rocks[0].visible = true
	papers[0].visible = true
	scissors[0].visible = true
	player.mask_level_change.connect(_on_mask_level_changed)
	player.mask_index_change.connect(_on_mask_index_changed)

func _input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if event.is_action_pressed("rock"):
		mask_pressed($Rocks, true)
	elif event.is_action_pressed("paper"):
		mask_pressed($Papers, true)
	elif event.is_action_pressed("scissor"):
		mask_pressed($Scissors, true)
	elif event.is_action_released("rock"):
		mask_pressed($Rocks, false)
	elif event.is_action_released("paper"):
		mask_pressed($Papers, false)
	elif event.is_action_released("scissor"):
		mask_pressed($Scissors, false)

func mask_pressed(mask: Node2D, is_down: bool):
	if is_down:
		mask.position.x += 20
		mask.position.y += 20
	else:
		mask.position.x -= 20
		mask.position.y -= 20

func update_mask_sprites():
	return

func _on_mask_level_changed(level: int, mask_type: int):
	print("Signal Level changed to: ", level)
	print("Signal mask index is: ", mask_type)
	if mask_level[mask_type] != level:
		mask_sprites[mask_type][level].visible = true
		mask_sprites[mask_type][mask_level[mask_type]].visible = false
		mask_level[mask_type] = level

func _on_mask_index_changed(index: int) -> void:
	print("Signal Mask index: ", index)
	current_mask_type = index

func _process(_delta: float) -> void:
	pass
