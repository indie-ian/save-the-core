extends Control

@onready var layer_label: Label = $MarginContainer/LayerLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	SignalBus.enter_layer.connect(_display_layer)


func _display_layer(layer_name: String) -> void:
	layer_label.text = layer_name
	animation_player.play("display_layer")
