extends Control

@onready var timer: Timer = $Timer
@onready var main_button: Button = $MainButton

func _ready() -> void:
	timer.timeout.connect(_skip_intro)
	main_button.pressed.connect(Global.manager.update_ui_tree.bind(Library.MAIN_MENU_SCENE))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_skip_intro()


func _skip_intro() -> void:
	Global.manager.update_ui_tree(Library.MAIN_MENU_SCENE, false)
