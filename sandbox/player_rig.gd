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

const MAX_LIQUID: float = 100.0
const LIQUID_LOSS_OVERCHARGE: float = 25.0  # liquid Overcharge loss
const LIQUID_LOSS_WEAK_CHARGE: float = 15.0 # if you let mouse to early liquid loss 60%
var current_liquid: float = MAX_LIQUID

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

@onready var damage_bar: TextureProgressBar = $stats/DamageBar

@onready var switch: AnimatedSprite2D = $stats/switch
@onready var green_light: Sprite2D = $stats/greenLight
@onready var redlight: Sprite2D = $stats/redlight

@onready var liquid: TextureProgressBar = $stats/liquid

#for the light switch
var is_switching: bool = false

var is_turbo_active: bool = false

const MAX_DAMAGE: float = 100.0
const DAMAGE_PER_HIT: float = 2.0 
const DAMAGE_BREAKABLE: float = 0.5     
const DAMAGE_UNBREAKABLE: float = 15.0  

var current_damage: float = 0.0
var hit_cooldown: float = 0.0
var is_dashing: bool = false
var danger_tween: Tween
var stats_offset: Vector2
var initial_stats_scale: Vector2


func _ready() -> void:
	drill.body_entered.connect(_drill_area)
	$AnimatedSprite2D.play()
	charge_ui.hide()
	effects.hide()
	max_charge_sprite.hide()
	failed.hide()
	#stats ui drill damage
	damage_bar.max_value = MAX_DAMAGE
	damage_bar.value = current_damage
	
	initial_stats_scale = stats.scale
	initial_stats_scale = stats.global_scale
	stats_offset = stats.global_position - global_position
	
	#lights and switch to indicate the part you are cooling by default it cools the engine
	#so thats why only the green light is on
	redlight.hide()
	
	#liquid bar
	liquid.max_value = MAX_LIQUID
	liquid.step = 0.01 
	liquid.value = current_liquid
	

func _physics_process(delta: float) -> void:
	if hit_cooldown > 0:
		hit_cooldown -= delta
	var mouse_pos = get_global_mouse_position()
	look_at(mouse_pos)
	charge_ui.global_position = global_position + BAR_OFFSET
	charge_ui.global_rotation = 0.0
	failed.global_position = global_position + Vector2(0, -90) 
	failed.global_rotation = 0.0
	max_charge_sprite.global_position = global_position + Vector2(0, -90) 
	max_charge_sprite.global_rotation = 0.0
	stats.global_position = global_position + stats_offset
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
				_consume_liquid(LIQUID_LOSS_OVERCHARGE)
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
				if charge_ratio >= 0.60:
					pass
				else:
					_consume_liquid(LIQUID_LOSS_WEAK_CHARGE)
			_launch(mouse_pos, launch_power)
			
		elif Input.is_action_pressed("ui_up"):
			velocity = global_position.direction_to(mouse_pos) * SPEED
		else:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	if shake_strength > 0:
		shake_strength = lerp(shake_strength, 0.0, 10.0 * delta)
		camera.offset = Vector2(randf_range(-shake_strength, shake_strength),randf_range(-shake_strength, shake_strength))
	
	move_and_slide()
	
	
	if is_dashing:
		# here we calculate how fast it was the dash
		var actual_speed = get_real_velocity().length()
		# here how fast should have been
		var expected_speed = velocity.length()
		
		# if the actual speed was smaller than the expected the that mean it hit a wall and it will add some damage
		if actual_speed < expected_speed * 0.3:
			is_dashing = false
			_apply_hard_hit()
			
		# if its normal we continue
		elif expected_speed <= SPEED:
			is_dashing = false
	
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
	if power > OVERCHARGE_SPEED:
		is_dashing = true

func _drill_area(body: Node2D) -> void:
	# ignore drill
	if body == self:
		return

	# if it is breakable
	if body is TileMapLayer and body.has_method("erase_cell") and not body.is_in_group("unbreakable"):
		var broke_tile: bool = false
		var hit_hard_tile: bool = false
		
		for x_pos in drill_area.x / 2:
			for y_pos in drill_area.y / 2:
				var q1: Vector2 = Vector2(drill.global_position.x - x_pos, drill.global_position.y - y_pos)
				var q2: Vector2 = Vector2(drill.global_position.x + x_pos, drill.global_position.y + y_pos)
				var q3: Vector2 = Vector2(drill.global_position.x - x_pos, drill.global_position.y + y_pos)
				var q4: Vector2 = Vector2(drill.global_position.x + x_pos, drill.global_position.y - y_pos)
				
				for point in [q1, q2, q3, q4]:
					var map_pos = body.local_to_map(point)
					if body.get_cell_source_id(map_pos) != -1:
						var tile_data = body.get_cell_tile_data(map_pos)
						if tile_data and tile_data.get_custom_data("unbreakable") == true:
							hit_hard_tile = true
						else:
							body.erase_cell(map_pos)
							broke_tile = true
							
		if broke_tile:
			_add_damage(DAMAGE_BREAKABLE)
		if hit_hard_tile:
			_apply_hard_hit()

	# if it is not breakable
	else:
		_apply_hard_hit()

func _apply_hard_hit() -> void:
	if hit_cooldown <= 0:
		_add_damage(DAMAGE_UNBREAKABLE)
		hit_cooldown = 0.4 
		velocity = -velocity * 0.4
		animated_sprite.modulate = Color(1.0, 0.2, 0.2) 
		var hit_tween = create_tween()
		hit_tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.3)
		shake_strength = 8.0




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
	animated_sprite.modulate = Color(1.0, 0.2, 0.2) 
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




func _add_damage(amount: float) -> void:
	current_damage = clamp(current_damage + amount, 0.0, MAX_DAMAGE)
	damage_bar.value = current_damage
	
	# if damage above 80% it start red party
	if current_damage >= MAX_DAMAGE * 0.8:
		_start_danger_pulse()
	else:
		_stop_danger_pulse()
		if current_damage >= MAX_DAMAGE * 0.5:
			damage_bar.modulate = Color.ORANGE
		else:
			damage_bar.modulate = Color.WHITE
			
	if current_damage >= MAX_DAMAGE:
		print("DRILL BROKEN / MAX DAMAGE!")
		# here we will add a game over
		
#red and shake alarm
func _start_danger_pulse() -> void:
	if danger_tween and danger_tween.is_valid():
		return
		
	danger_tween = create_tween().set_loops()
	
	danger_tween.tween_property(stats, "global_scale", initial_stats_scale * 1.02, 0.25).set_trans(Tween.TRANS_SINE)
	danger_tween.parallel().tween_property(stats, "modulate", Color(1.0, 0.25, 0.25), 0.25)
	
	danger_tween.tween_property(stats, "global_scale", initial_stats_scale, 0.25).set_trans(Tween.TRANS_SINE)
	danger_tween.parallel().tween_property(stats, "modulate", Color.WHITE, 0.25)

func _stop_danger_pulse() -> void:
	if danger_tween and danger_tween.is_valid():
		danger_tween.kill()
	stats.global_scale = initial_stats_scale
	stats.modulate = Color.WHITE


# when the mouse enters the area switch change 
func _on_area_2d_mouse_entered() -> void:
	if is_switching:
		return	
	is_switching = true
	if not redlight.visible:
		switch.play("GreenToRed")
		await switch.animation_finished
		redlight.show()
		green_light.hide()
	else:
		switch.play("redToGreen")
		await switch.animation_finished
		green_light.show()
		redlight.hide()
	is_switching = false
	
func _consume_liquid(amount: float) -> void:
	current_liquid = clamp(current_liquid - amount, 0.0, MAX_LIQUID)
	liquid.value = current_liquid
	
	if amount >= 5.0:
		liquid.modulate = Color(1.0, 0.3, 0.3)
		var bar_tween = create_tween()
		bar_tween.tween_property(liquid, "modulate", Color.WHITE, 0.35)
		
	if current_liquid <= 0:
		print("no liquid")
