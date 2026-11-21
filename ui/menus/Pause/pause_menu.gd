extends Control

@onready var resume_button: Button = $Resume
@onready var main_menu_button: Button = $MainButton

@onready var master_h_slider: HSlider = $GridContainer/MasterHSlider
@onready var music_h_slider: HSlider = $GridContainer/MusicHSlider
@onready var sfxh_slider: HSlider = $GridContainer/SFXHSlider

var master_bus_index: int = AudioServer.get_bus_index("Master")
var music_bus_index: int = AudioServer.get_bus_index("Music")
var sfx_bus_index: int = AudioServer.get_bus_index("SFX")


func _ready() -> void:
	get_tree().paused = true

	_sync_sliders_from_audio_server()

	resume_button.pressed.connect(_on_resume_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	master_h_slider.value_changed.connect(_slider_value_changed.bind(master_h_slider))
	music_h_slider.value_changed.connect(_slider_value_changed.bind(music_h_slider))
	sfxh_slider.value_changed.connect(_slider_value_changed.bind(sfxh_slider))


func _sync_sliders_from_audio_server() -> void:
	if master_bus_index != -1:
		master_h_slider.value = db_to_linear(AudioServer.get_bus_volume_db(master_bus_index))
	if music_bus_index != -1:
		music_h_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus_index))
	if sfx_bus_index != -1:
		sfxh_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus_index))

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
	if event.is_action_pressed("ui_cancel") || Input.is_action_pressed("p"):
		get_viewport().set_input_as_handled()
		_on_resume_pressed()


func _slider_value_changed(value: float, slider: HSlider) -> void:
	var value_to_decibel: float = linear_to_db(value)

	match slider:
		master_h_slider:
			if master_bus_index != -1:
				AudioServer.set_bus_volume_db(master_bus_index, value_to_decibel)
		music_h_slider:
			if music_bus_index != -1:
				AudioServer.set_bus_volume_db(music_bus_index, value_to_decibel)
		sfxh_slider:
			if sfx_bus_index != -1:
				AudioServer.set_bus_volume_db(sfx_bus_index, value_to_decibel)
