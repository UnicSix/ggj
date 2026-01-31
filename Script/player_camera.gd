extends Camera2D

@export var player: Node2D

const view_constraint : float = 200.0
var prev_player_pos : Vector2

func _ready() -> void:
	prev_player_pos = player.position
	position = player.position

func _physics_process(_delta: float) -> void:
	var distance : float = position.distance_to(player.position)
	if distance > view_constraint:
		var direction = (player.position - position).normalized()
		position = player.position - direction * view_constraint
	prev_player_pos = player.position

# 	queue_redraw()  # Request redraw every frame
#
# func _draw() -> void:
# 	# Draw circle at camera position
# 	draw_arc(Vector2.ZERO, view_constraint, 0, TAU, 64, Color.RED, 2.0)
#
# 	# Draw line to player
# 	var to_player = player.position - position
# 	draw_line(Vector2.ZERO, to_player, Color.YELLOW, 1.0)
