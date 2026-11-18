extends Control

@onready var start_button: Button = $ButtonVBox/StartButton
@onready var options_button: Button = $ButtonVBox/OptionsButton
@onready var credits_button: Button = $ButtonVBox/CreditsButton
@onready var exit_button: Button = $ButtonVBox/ExitButton

func _ready() -> void:
	#start_button.pressed.connect(_start_game.bind(Library.MAIN_MENU_SCENE))
	start_button.pressed.connect(_start_game.bind(Library.TUTORIAL_SCENE))
	options_button.pressed.connect(_change_menu.bind(Library.OPTIONS_SCENE))
	credits_button.pressed.connect(_change_menu.bind(Library.CREDITS_SCENE))
	exit_button.pressed.connect(get_tree().quit)
	$background.play("default")


func _start_game(new_scene: String) -> void:
	Global.manager.update_ui_tree(new_scene)


func _change_menu(new_menu: String) -> void:
	Global.manager.update_ui_tree(new_menu)
