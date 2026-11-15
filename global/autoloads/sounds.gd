extends Node

@onready var music: AudioStreamPlayer = $Music

func _ready() -> void:
	music.play()
