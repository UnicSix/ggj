extends Node2D

@onready var stbtn = $stbtn
@onready var qubtn = $QuBtn
@onready var hover_sound = $HoverSound   # 記得場景裡要有這個 AudioStreamPlayer

var normal_scale := Vector2.ONE
var hover_scale := Vector2(1.1, 1.1)

func _ready() -> void:
	# 設定 pivot 讓放大從中心開始
	stbtn.pivot_offset = stbtn.size / 2
	qubtn.pivot_offset = qubtn.size / 2
	
	# 連接 hover 訊號
	stbtn.mouse_entered.connect(_on_button_hover.bind(stbtn))
	stbtn.mouse_exited.connect(_on_button_exit.bind(stbtn))
	
	qubtn.mouse_entered.connect(_on_button_hover.bind(qubtn))
	qubtn.mouse_exited.connect(_on_button_exit.bind(qubtn))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://Scene/main.tscn")
	elif event.is_action_pressed("ui_cancel"):
		get_tree().quit()



func _process(_delta: float) -> void:
	pass

# Hover 放大
func _on_button_hover(button):
	var tween = create_tween()
	tween.tween_property(button, "scale", hover_scale, 0.15)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	
	if not hover_sound.playing:
		hover_sound.play()


# Hover 還原
func _on_button_exit(button):
	var tween = create_tween()
	tween.tween_property(button, "scale", normal_scale, 0.15)

func _on_qu_btn_button_down() -> void:
	get_tree().quit()


func _on_stbtn_button_down() -> void:
	get_tree().change_scene_to_file("res://Scene/main.tscn")
