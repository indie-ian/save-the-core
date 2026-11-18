extends Node2D

const LOWER_MANTLE_COLLAPSE = preload("uid://de5q2735ykcit")

var collapse: Node2D

@onready var collapse_spawn: Marker2D = $CollapseSpawn
@onready var collapse_trigger: Area2D = $CollapseTrigger
@onready var collapse_stop: Area2D = $CollapseStop


func _ready() -> void:
	collapse_trigger.body_entered.connect(_start_collapse)
	collapse_stop.area_entered.connect(_stop_collapse)


func _start_collapse(body: Node2D) -> void:
	if body.has_method("_launch"):
		collapse = LOWER_MANTLE_COLLAPSE.instantiate()
		_add_collapse.call_deferred(collapse)

func _add_collapse(new_collapse: Area2D) -> void:
	add_child(new_collapse)
	new_collapse.global_position = collapse_spawn.global_position


func _stop_collapse(area: Area2D) -> void:
	if area.has_method("stop_collapsing"):
		area.stop_collapsing()
