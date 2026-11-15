extends Control

@onready var start_button: Button = $MainVBox/ButtonVBox/StartButton
@onready var options_button: Button = $MainVBox/ButtonVBox/OptionsButton
@onready var credits_button: Button = $MainVBox/ButtonVBox/CreditsButton
@onready var exit_button: Button = $MainVBox/ButtonVBox/ExitButton

func _ready() -> void:
	start_button.pressed.connect(_start_game.bind(Library.MAIN_MENU_SCENE))
	options_button.pressed.connect(_change_menu.bind(Library.OPTIONS_SCENE))
	credits_button.pressed.connect(_change_menu.bind(Library.CREDITS_SCENE))
	exit_button.pressed.connect(get_tree().quit)


func _start_game(_new_scene: String) -> void:
	pass


func _change_menu(new_menu: String) -> void:
	Global.manager.update_ui_tree(new_menu)
