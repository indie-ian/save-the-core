extends Control

@onready var start: Button = $start

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://sandbox/layers_test.tscn")
