extends Control

@onready var main_button: Button = $CanvasLayer/MainButton
@onready var retry: Button = $CanvasLayer/Retry

func _ready() -> void:
	main_button.pressed.connect(_on_main_menu_pressed)
	retry.pressed.connect(_on_retry_pressed)

func _on_main_menu_pressed() -> void:
	if is_instance_valid(Global.manager.current_node2d):
		Global.manager.current_node2d.queue_free()
	Global.manager.current_node2d = null
	
	Global.manager.update_ui_tree(Library.MAIN_MENU_SCENE)

func _on_retry_pressed() -> void:
	Global.manager.update_node2d_tree(Library.GAME_SCENE)
	Global.manager.update_ui_tree(Library.GAME_UI_SCENE)
