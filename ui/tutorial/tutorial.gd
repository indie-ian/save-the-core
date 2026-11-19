extends Control

@onready var start: Button = $start

func _on_start_pressed() -> void:
	Global.manager.current_ui = null
	queue_free()
	
	Global.manager.update_node2d_tree("res://sandbox/layers_test.tscn")
