extends CharacterBody2D

const SPEED = 50.0
const MIN_LAUNCH_SPEED = 200.0
const MAX_LAUNCH_SPEED = 600.0
const SWEET_SPOT_SPEED = 800.0 
const OVERCHARGE_SPEED = 300.0  


const MAX_CHARGE_TIME = 0.7 #charge time to get to sweet spot
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
@onready var effects: AnimatedSprite2D = $effects
@onready var max_charge_sprite: Sprite2D = $maxcharge
@onready var failed: Sprite2D = $failed
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var stats: Node2D = $stats


var is_turbo_active: bool = false

func _ready() -> void:
	drill.body_entered.connect(_drill_area)
	$AnimatedSprite2D.play()
	charge_ui.hide()
	effects.hide()
	max_charge_sprite.hide()
	failed.hide()
	

func _physics_process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	look_at(mouse_pos)
	charge_ui.global_position = global_position + BAR_OFFSET
	charge_ui.global_rotation = 0.0
	failed.global_position = global_position + Vector2(0, -90) 
	failed.global_rotation = 0.0
	max_charge_sprite.global_position = global_position + Vector2(0, -90) 
	max_charge_sprite.global_rotation = 0.0
	stats.global_position= global_position 
	stats.global_rotation = 0.0
	
	if max_charge_sprite.visible:
		max_charge_sprite.global_position = global_position + Vector2(0, -65)
		max_charge_sprite.global_rotation = 0.0
	
	if is_turbo_active and velocity.length() < MAX_LAUNCH_SPEED:
		is_turbo_active = false
		effects.stop()
		effects.hide()
	
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
				_trigger_overcharge_effects()
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
				shake_strength = 20 #maximum shake when you achieve max charge
				_trigger_sweet_spot_effects()
			else:
				launch_power = lerp(MIN_LAUNCH_SPEED, MAX_LAUNCH_SPEED, charge_ratio)
				shake_strength = 10 #small shake when you do smaller charge
				
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

func _trigger_sweet_spot_effects() -> void:
	is_turbo_active = true
	effects.show()
	effects.play("turbo")
	
	max_charge_sprite.show()
	max_charge_sprite.scale = Vector2(0.2, 0.2) 
	max_charge_sprite.modulate.a = 1.0          
	
	var tween = create_tween()
	tween.tween_property(max_charge_sprite, "scale", Vector2(1.2, 1.2), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.3)
	tween.tween_property(max_charge_sprite, "modulate:a", 0.0, 0.25)
	tween.tween_callback(max_charge_sprite.hide)

func _trigger_overcharge_effects() -> void:
	animated_sprite.modulate = Color(1.0, 0.2, 0.2) # Έντονο κόκκινο
	var color_tween = create_tween()
	color_tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.6)
	
	failed.show()
	failed.scale = Vector2(0.2, 0.2)
	failed.modulate.a = 1.0
	
	var popup_tween = create_tween()
	popup_tween.tween_property(failed, "scale", Vector2(1.1, 1.1), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	popup_tween.tween_interval(0.35)
	popup_tween.tween_property(failed, "modulate:a", 0.0, 0.25)
	popup_tween.tween_callback(failed.hide)
