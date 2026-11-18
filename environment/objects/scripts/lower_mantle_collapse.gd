extends Area2D

const COLLAPSE_SPEED: float = 100.0

var collapsing: bool = true

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	body_entered.connect(_collapse_death)
	
func _process(delta: float) -> void:
	if collapsing:
		global_position.y += COLLAPSE_SPEED * delta


# Player dies from death area
func _collapse_death(_body: Node2D) -> void:
	pass


func stop_collapsing() -> void:
	collapsing = false
	animation_player.stop()
