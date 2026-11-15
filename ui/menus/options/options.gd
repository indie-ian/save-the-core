extends Control

var master_bus_index = AudioServer.get_bus_index("Master")
var music_bus_index = AudioServer.get_bus_index("Music")
var sfx_bus_index = AudioServer.get_bus_index("SFX")

@onready var main_button: Button = $ButtonMargin/MainButton
@onready var master_h_slider: HSlider = $OptionsHBox/AudioPanel/AudioSliderVBox/GridContainer/MasterHSlider
@onready var music_h_slider: HSlider = $OptionsHBox/AudioPanel/AudioSliderVBox/GridContainer/MusicHSlider
@onready var sfx_h_slider: HSlider = $OptionsHBox/AudioPanel/AudioSliderVBox/GridContainer/SFXHSlider

func _ready() -> void:
	main_button.pressed.connect(Global.manager.update_ui_tree.bind(Library.MAIN_MENU_SCENE))
	master_h_slider.value_changed.connect(_slider_value_changed.bind(master_h_slider))
	music_h_slider.value_changed.connect(_slider_value_changed.bind(music_h_slider))
	sfx_h_slider.value_changed.connect(_slider_value_changed.bind(sfx_h_slider))

func _slider_value_changed(value: float, slider: HSlider) -> void:
	var value_to_decibel: float = linear_to_db(value)
	
	match slider:
		master_h_slider:
			AudioServer.set_bus_volume_db(master_bus_index, value_to_decibel)
		music_h_slider:
			AudioServer.set_bus_volume_db(music_bus_index, value_to_decibel)
		sfx_h_slider:
			AudioServer.set_bus_volume_db(sfx_bus_index, value_to_decibel)
	
	
