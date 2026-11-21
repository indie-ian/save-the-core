extends Control

@onready var layer_label: Label = $LayerMargin/LayerLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var time_label: Label = $TimeMargin/TimeLabel


func _ready() -> void:
	SignalBus.enter_layer.connect(_display_layer)


func _process(_delta: float) -> void:
	time_label.text = "%02d:%02d" % [ Global.manager.game_state.current_time_min, Global.manager.game_state.current_time_sec ]


func _display_layer(layer_name: String) -> void:
	layer_label.text = layer_name
	animation_player.play("display_layer")
