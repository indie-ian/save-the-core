extends Control

@onready var start: Button = $start

func _on_start_pressed() -> void:
	Global.manager.update_node2d_tree(Library.GAME_SCENE)
	Global.manager.update_ui_tree(Library.GAME_UI_SCENE)
