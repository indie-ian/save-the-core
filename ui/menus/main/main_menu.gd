extends Control

@onready var start_button: Button = $ButtonVBox/StartButton
@onready var options_button: Button = $ButtonVBox/OptionsButton
@onready var credits_button: Button = $ButtonVBox/CreditsButton
@onready var exit_button: Button = $ButtonVBox/ExitButton

func _ready() -> void:
	start_button.pressed.connect(_start_game.bind(Library.MAIN_MENU_SCENE))
	options_button.pressed.connect(_change_menu.bind(Library.OPTIONS_SCENE))
	credits_button.pressed.connect(_change_menu.bind(Library.CREDITS_SCENE))
	exit_button.pressed.connect(get_tree().quit)
	$background.play("default")


func _start_game(_new_scene: String) -> void:
	pass


func _change_menu(new_menu: String) -> void:
	Global.manager.update_ui_tree(new_menu)


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://sandbox/layers_test.tscn")
