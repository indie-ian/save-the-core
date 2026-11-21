extends Control

@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.timeout.connect(_skip_intro)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_skip_intro()


func _skip_intro() -> void:
	Global.manager.update_ui_tree(Library.MAIN_MENU_SCENE, false)
