extends Sprite2D


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	position += Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * 200 * delta
