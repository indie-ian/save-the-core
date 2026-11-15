extends Control

@onready var main_button: Button = $ButtonMargin/MainButton

func _ready() -> void:
	main_button.pressed.connect(Global.manager.update_ui_tree.bind(Library.MAIN_MENU_SCENE))
