extends Node
class_name GameState


var start_time_msec: int
var current_time_sec: int
var current_time_min: int
var end_time_sec: int
var end_time_min: int

var msec_string: String
var sec_string: String
var min_string: String

var track_time: bool = false


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	if track_time:
		@warning_ignore("integer_division")
		current_time_sec = int((Time.get_ticks_msec() - start_time_msec) / 1000) % 60
		@warning_ignore("integer_division")
		current_time_min = int((Time.get_ticks_msec() - start_time_msec) / 60000)


func start_time() -> void:
	start_time_msec = Time.get_ticks_msec()
	track_time = true


func end_time() -> void:
	end_time_sec = current_time_sec
	end_time_min = current_time_min
	track_time = false
