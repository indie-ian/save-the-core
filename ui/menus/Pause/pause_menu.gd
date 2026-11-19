extends Control

@onready var resume_button: Button = $Resume
@onready var main_menu_button: Button = $MainButton

func _ready() -> void:
	get_tree().paused = true
	
	resume_button.pressed.connect(_on_resume_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") || Input.is_action_pressed("p"):
		_on_resume_pressed()

func _on_resume_pressed() -> void:
	get_tree().paused = false
	Global.manager.current_pause = null
	queue_free()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	
	Global.manager.current_pause = null
	queue_free()
	
	if is_instance_valid(Global.manager.current_node2d):
		Global.manager.current_node2d.queue_free()
	Global.manager.current_node2d = null
	
	Global.manager.update_ui_tree(Library.MAIN_MENU_SCENE)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") || Input.is_action_pressed("p") :
		get_viewport().set_input_as_handled()
		_on_resume_pressed()
