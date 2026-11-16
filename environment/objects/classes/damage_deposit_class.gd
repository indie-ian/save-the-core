extends CharacterBody2D
class_name DamageDeposit

enum SizeType { LARGE, MEDIUM, SMALL }

const SPEED_MIN: float = 100.0
const SPEED_MAX: float = 125.0

@export var floating: bool = false
@export var size_type: SizeType

var manual_placement: bool = true
var speed: float = 0

@onready var deposit_sprite: Sprite2D = $DepositSprite

func _init(manual_place: bool = true, spawn_floating: bool = false) -> void:
	
	manual_placement = manual_place
	floating = spawn_floating
	speed = randf_range(SPEED_MIN,SPEED_MAX)

func _physics_process(delta: float) -> void:
	if floating:
		global_position.x -= speed * delta
		
		if global_position.x < -100:
			queue_free()
