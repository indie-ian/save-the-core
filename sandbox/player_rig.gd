extends CharacterBody2D

const SPEED = 50.0
const MIN_LAUNCH_SPEED = 200.0
const MAX_LAUNCH_SPEED = 600.0
const SWEET_SPOT_SPEED = 800.0 
const OVERCHARGE_SPEED = 300.0  

const MAX_CHARGE_TIME = 0.7
const SWEET_SPOT_MIN = 0.80 
const SWEET_SPOT_MAX = 0.95 

const FRICTION = 800.0
const BAR_OFFSET = Vector2(0, -45) 
const POINTER_START_Y = -25.0 
const POINTER_END_Y = -70.0    


var drill_area: Vector2 = Vector2(24, 24)
var is_charging: bool = false
var current_charge: float = 0.0
var overcharged: bool = false 
var shake_strength: float = 0.0

@onready var drill: Area2D = $Drill
@onready var charge_ui: Node2D = $chargeUI
@onready var bar_sprite: Sprite2D = $chargeUI/BarSprite
@onready var pointer: Sprite2D = $chargeUI/Pointer
@onready var camera: Camera2D = $Camera2D



func _ready() -> void:
	drill.body_entered.connect(_drill_area)
	$AnimatedSprite2D.play()
	charge_ui.hide()

func _physics_process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	look_at(mouse_pos)
	charge_ui.global_position = global_position + BAR_OFFSET
	charge_ui.global_rotation = 0.0
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if not overcharged:
			is_charging = true
			charge_ui.show() 
			
			current_charge += delta
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			
			#pointer movement
			var charge_ratio = clamp(current_charge / MAX_CHARGE_TIME, 0.0, 1.0)
			pointer.position.y = lerp(POINTER_START_Y, POINTER_END_Y, charge_ratio)
			if charge_ratio >= SWEET_SPOT_MIN and charge_ratio <= SWEET_SPOT_MAX:
				pointer.modulate = Color.GREEN 
			else:
				pointer.modulate = Color.WHITE
			
			# Overcharge 
			if current_charge >= MAX_CHARGE_TIME:
				_launch(mouse_pos, OVERCHARGE_SPEED)
				overcharged = true
				print("OVERCHARGED")
		else:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			
	else:
		overcharged = false
		
		if is_charging:
			var charge_ratio = current_charge / MAX_CHARGE_TIME
			var launch_power: float
			
			if charge_ratio >= SWEET_SPOT_MIN and charge_ratio <= SWEET_SPOT_MAX:
				launch_power = SWEET_SPOT_SPEED
				shake_strength = 20
			else:
				launch_power = lerp(MIN_LAUNCH_SPEED, MAX_LAUNCH_SPEED, charge_ratio)
				shake_strength = 10
				
			_launch(mouse_pos, launch_power)
			
		elif Input.is_action_pressed("ui_up"):
			velocity = global_position.direction_to(mouse_pos) * SPEED
		else:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	if shake_strength > 0:
		shake_strength = lerp(shake_strength, 0.0, 10.0 * delta)
		camera.offset = Vector2(randf_range(-shake_strength, shake_strength),randf_range(-shake_strength, shake_strength))
	

	move_and_slide()
	
	if drill.has_overlapping_bodies():
		for body in drill.get_overlapping_bodies():
			if body is TileMapLayer:
				_drill_area(body)

func _launch(target_pos: Vector2, power: float) -> void:
	velocity = global_position.direction_to(target_pos) * power
	is_charging = false
	current_charge = 0.0
	charge_ui.hide()
	pointer.position.y = POINTER_START_Y 

func _drill_area(body: Node2D) -> void:
	if body.has_method("erase_cell"):
		for x_pos in drill_area.x / 2:
			for y_pos in drill_area.y / 2:
				var q1: Vector2 = Vector2(drill.global_position.x - x_pos, drill.global_position.y - y_pos)
				var q2: Vector2 = Vector2(drill.global_position.x + x_pos, drill.global_position.y + y_pos)
				var q3: Vector2 = Vector2(drill.global_position.x - x_pos, drill.global_position.y + y_pos)
				var q4: Vector2 = Vector2(drill.global_position.x + x_pos, drill.global_position.y - y_pos)
				body.erase_cell(body.local_to_map(q1))
				body.erase_cell(body.local_to_map(q2))
				body.erase_cell(body.local_to_map(q3))
				body.erase_cell(body.local_to_map(q4))
