extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.animation_finished.connect(_skip_intro.unbind(1))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_skip_intro()

func _skip_intro() -> void:
	Global.manager.update_ui_tree(Library.MAIN_MENU_SCENE, false)
