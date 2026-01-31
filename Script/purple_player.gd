extends Node2D

var velocity : float = 500

# y axis is pointing down
func _ready() -> void:
	position = Vector2(500, 100)


func _process(_delta: float) -> void:
	pass

func player_input() -> Vector2:
	var direction = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	return direction * velocity
	
func _physics_process(delta: float) -> void:
	position += player_input() * delta
