extends CharacterBody2D

const SPEED = 1.0
const JUMP_VELOCITY = -400.0

var drill_area: Vector2 = Vector2(24,24)

@onready var drill: Area2D = $Drill

func _ready() -> void:
	drill.body_entered.connect(_drill_area)

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("ui_up"):
		global_position += global_position.direction_to(get_global_mouse_position()) * SPEED
	
	look_at(get_global_mouse_position())
	
	move_and_slide()
	
	if drill.has_overlapping_bodies():
		for body in drill.get_overlapping_bodies():
			if body is TileMapLayer:
				_drill_area(body)

func _drill_area(body: Node2D) -> void:
	if body.has_method("erase_cell"):
		for x_pos in drill_area.x/2:
			for y_pos in drill_area.y/2:
				var q1: Vector2 = Vector2(drill.global_position.x - x_pos, drill.global_position.y - y_pos)
				var q2: Vector2 = Vector2(drill.global_position.x + x_pos, drill.global_position.y + y_pos)
				var q3: Vector2 = Vector2(drill.global_position.x - x_pos, drill.global_position.y + y_pos)
				var q4: Vector2 = Vector2(drill.global_position.x + x_pos, drill.global_position.y - y_pos)
				body.erase_cell(body.local_to_map(q1))
				body.erase_cell(body.local_to_map(q2))
				body.erase_cell(body.local_to_map(q3))
				body.erase_cell(body.local_to_map(q4))
