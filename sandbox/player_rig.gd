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

@onready var damage_bar: TextureProgressBar = $stats/DamageBar

@onready var switch: AnimatedSprite2D = $stats/switch
@onready var green_light: Sprite2D = $stats/greenLight
@onready var redlight: Sprite2D = $stats/redlight

@onready var liquid: TextureProgressBar = $stats/liquid
@onready var coolingtubes: AnimatedSprite2D = $stats/coolingtubes
@onready var green_pointer: Sprite2D = $stats/clockgreen/greenPointer
@onready var clockred: Sprite2D = $stats/clockred
@onready var red_pointer: Sprite2D = $stats/clockred/redPointer
@onready var clockgreen: Sprite2D = $stats/clockgreen

@onready var dash_cool_down: Sprite2D = $stats/DashCoolDown
@onready var timer_dash: TextureProgressBar = $stats/timerDash


#for temperature
#how cooling works
#when you overcharge temperature goes up for the top clock
#when you hit a wall temperature goes up for the bottom clock
#how cooling tubes work
#by default it cools the bottom clock so every time you hit some liquid leaves
#to switch the tubes you hover the switch and press a
#then it cools the top clok
#if you change anything be carefull it work by prayers and pure luck

const MAX_TEMP_DEGREES: float = 350.0 # max turn
const WARNING_DEGREES: float = 260.0  # blink effect trigger
const COOL_DROP_DEGREES: float = 80.0 # rotation 
const COOL_LIQUID_COST: float = 15.0  # liquid from cooling

const MAX_LIQUID: float = 100.0
const LIQUID_LOSS_OVERCHARGE: float = 5.0  # liquid Overcharge loss
const LIQUID_LOSS_WEAK_CHARGE: float = 2.5 # if you let mouse to early liquid loss 60%
var current_liquid: float = MAX_LIQUID
const LIQUID_PER_DEGREE: float = 0.25

var green_temp_deg: float = 0.0
var red_temp_deg: float = 0.0

var green_warn_tween: Tween
var red_warn_tween: Tween



#for the light switch
var is_switching: bool = false
var is_mouse_on_switch: bool = false

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

#dash cooldown
#how it works
#when you do a sweet spot no dash cooldown
#when you overcharge you get 3 seconds cooldown
#when you do ealy it calculates the cooldown like this 
# cooldown = 3 - complition of bar% so the closer u are to sweet spot less panishment
const MAX_DASH_COOLDOWN: float = 3.0

var dash_cooldown_timer: float = 0.0
var dash_cooldown_max: float = 0.0


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
	redlight.show()
	green_light.hide()
	coolingtubes.play("coolingRed")
	
	#liquid bar
	liquid.max_value = MAX_LIQUID
	liquid.step = 0.01 
	liquid.value = current_liquid
	
	
	timer_dash.max_value = 100.0
	timer_dash.step = 0.01
	timer_dash.value = 0 
	
	timer_dash.max_value = 100.0
	timer_dash.step = 0.01
	timer_dash.value = 0
	dash_cool_down.hide()
	timer_dash.hide()
	

func _physics_process(delta: float) -> void:
	if is_mouse_on_switch and Input.is_action_just_pressed("coolingbutton"):
		_toggle_cooling_switch()
	
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
	
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer = max(0.0, dash_cooldown_timer - delta)
		var progress_ratio: float = 1.0 - (dash_cooldown_timer / dash_cooldown_max)
		timer_dash.value = progress_ratio * 100.0
		
		if dash_cooldown_timer <= 0.0:
			timer_dash.value = 100.0
			_hide_dash_cooldown_ui()
	
	if max_charge_sprite.visible:
		max_charge_sprite.global_position = global_position + Vector2(0, -65)
		max_charge_sprite.global_rotation = 0.0
	
	if is_turbo_active and velocity.length() < MAX_LAUNCH_SPEED:
		is_turbo_active = false
		effects.stop()
		effects.hide()
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and (dash_cooldown_timer <= 0.0 or is_charging or overcharged):
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
				_add_green_temp(20.0)
				_start_dash_cooldown(MAX_DASH_COOLDOWN) 
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
				_trigger_sweet_spot_effects()
				_start_dash_cooldown(0.0) 
			else:
				launch_power = lerp(MIN_LAUNCH_SPEED, MAX_LAUNCH_SPEED, charge_ratio)
				shake_strength = 10
				
				var completion_percent: float = clamp(charge_ratio / SWEET_SPOT_MIN, 0.0, 1.0)
				var calculated_cooldown: float = MAX_DASH_COOLDOWN * (1.0 - completion_percent)
				_start_dash_cooldown(calculated_cooldown)
				
				if charge_ratio < 0.60:
					_consume_liquid(LIQUID_LOSS_WEAK_CHARGE)
			
			_launch(mouse_pos, launch_power) 
			
		elif Input.is_action_pressed("ui_up") || Input.is_action_pressed("slowMoveForward"):
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
			_add_red_temp(5.0)
		if hit_hard_tile:
			_apply_hard_hit()

	# if it is not breakable
	else:
		_apply_hard_hit()


func _apply_hard_hit() -> void:
	if hit_cooldown <= 0:
		_add_red_temp(20.0)
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


func _on_area_2d_mouse_entered() -> void:
	is_mouse_on_switch = true

func _on_area_2d_mouse_exited() -> void:
	is_mouse_on_switch = false


	
func _consume_liquid(amount: float) -> void:
	current_liquid = clamp(current_liquid - amount, 0.0, MAX_LIQUID)
	var bar_tween = create_tween()
	bar_tween.tween_property(liquid, "value", current_liquid, 0.5).set_trans(Tween.TRANS_SINE)
	
	if amount >= 5.0:
		liquid.modulate = Color(1.0, 0.3, 0.3)
		bar_tween.parallel().tween_property(liquid, "modulate", Color.WHITE, 0.5)
		
	if current_liquid <= 0:
		print("no liquid")


func _add_green_temp(degrees: float) -> void:
	if degrees < 0:
		green_temp_deg = clamp(green_temp_deg + degrees, 0.0, MAX_TEMP_DEGREES)
		_update_green_needle()
		return

	if not redlight.visible and current_liquid > 0:
		_consume_liquid(LIQUID_LOSS_OVERCHARGE) 
		return
		
	green_temp_deg = clamp(green_temp_deg + degrees, 0.0, MAX_TEMP_DEGREES)
	_update_green_needle()

func _add_red_temp(degrees: float) -> void:
	if degrees < 0:
		red_temp_deg = clamp(red_temp_deg + degrees, 0.0, MAX_TEMP_DEGREES)
		_update_red_needle()
		return

	if redlight.visible and current_liquid > 0:
		_consume_liquid(LIQUID_LOSS_WEAK_CHARGE) 
		return
		
	red_temp_deg = clamp(red_temp_deg + degrees, 0.0, MAX_TEMP_DEGREES)
	_update_red_needle()

# blinkssss
func _start_clock_warning(clock_sprite: Sprite2D, is_green: bool) -> void:
	if is_green:
		if green_warn_tween and green_warn_tween.is_valid():
			return
		green_warn_tween = create_tween().set_loops()
		green_warn_tween.tween_property(clock_sprite, "modulate", Color(1.0, 0.2, 0.2), 0.2)
		green_warn_tween.tween_property(clock_sprite, "modulate", Color.WHITE, 0.2)
	else:
		if red_warn_tween and red_warn_tween.is_valid():
			return
		red_warn_tween = create_tween().set_loops()
		red_warn_tween.tween_property(clock_sprite, "modulate", Color(1.0, 0.2, 0.2), 0.2)
		red_warn_tween.tween_property(clock_sprite, "modulate", Color.WHITE, 0.2)

func _stop_clock_warning(clock_sprite: Sprite2D, is_green: bool) -> void:
	if is_green and green_warn_tween and green_warn_tween.is_valid():
		green_warn_tween.kill()
	elif not is_green and red_warn_tween and red_warn_tween.is_valid():
		red_warn_tween.kill()
	clock_sprite.modulate = Color.WHITE

func _toggle_cooling_switch() -> void:
	if is_switching:
		return	
	is_switching = true
	
	if not redlight.visible:
		switch.play("GreenToRed")
		await switch.animation_finished
		redlight.show()
		green_light.hide()
		
		if red_temp_deg > 0 and current_liquid > 0:
			var needed_liquid: float = red_temp_deg * LIQUID_PER_DEGREE
			var liquid_used: float = min(current_liquid, needed_liquid)
			var degrees_cooled: float = liquid_used / LIQUID_PER_DEGREE
			
			_consume_liquid(liquid_used)
			_add_red_temp(-degrees_cooled) 
			
		coolingtubes.play("coolswitchRed")
		await coolingtubes.animation_finished
		coolingtubes.play("coolingRed")
	else:
		switch.play("redToGreen")
		await switch.animation_finished
		green_light.show()
		redlight.hide()
		
		if green_temp_deg > 0 and current_liquid > 0:
			var needed_liquid: float = green_temp_deg * LIQUID_PER_DEGREE
			var liquid_used: float = min(current_liquid, needed_liquid)
			var degrees_cooled: float = liquid_used / LIQUID_PER_DEGREE
			
			_consume_liquid(liquid_used)
			_add_green_temp(-degrees_cooled) 
			
		coolingtubes.play("coolingswitchGreen")
		await coolingtubes.animation_finished
		coolingtubes.play("coolingGreen")
		
	is_switching = false
	
func _update_green_needle() -> void:
	var rot_tween = create_tween()
	rot_tween.tween_property(green_pointer, "rotation_degrees", green_temp_deg, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	if green_temp_deg > WARNING_DEGREES:
		_start_clock_warning(clockgreen, true)
	else:
		_stop_clock_warning(clockgreen, true)

func _update_red_needle() -> void:
	var rot_tween = create_tween()
	rot_tween.tween_property(red_pointer, "rotation_degrees", red_temp_deg, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	if red_temp_deg > WARNING_DEGREES:
		_start_clock_warning(clockred, false)
	else:
		_stop_clock_warning(clockred, false)
		


func _start_dash_cooldown(duration: float) -> void:
	if duration <= 0.05:
		dash_cooldown_timer = 0.0
		dash_cooldown_max = 0.0
		dash_cool_down.hide()
		timer_dash.hide()
		return
		
	dash_cooldown_max = duration
	dash_cooldown_timer = duration
	timer_dash.value = 0.0
	_show_dash_cooldown_ui()

func _show_dash_cooldown_ui() -> void:
	dash_cool_down.show()
	timer_dash.show()
	
	# Pop charge dash
	dash_cool_down.scale = Vector2(0.3, 0.3)
	timer_dash.scale = Vector2(0.3, 0.3)
	dash_cool_down.modulate.a = 1.0
	timer_dash.modulate.a = 1.0
	
	var pop_tween = create_tween().set_parallel(true)
	pop_tween.tween_property(dash_cool_down, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pop_tween.tween_property(timer_dash, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _hide_dash_cooldown_ui() -> void:
	# fade charge dash
	var hide_tween = create_tween().set_parallel(true)
	hide_tween.tween_property(dash_cool_down, "scale", Vector2(1.2, 1.2), 0.15)
	hide_tween.tween_property(timer_dash, "scale", Vector2(1.2, 1.2), 0.15)
	hide_tween.tween_property(dash_cool_down, "modulate:a", 0.0, 0.15)
	hide_tween.tween_property(timer_dash, "modulate:a", 0.0, 0.15)
	
	hide_tween.chain().tween_callback(func():
		dash_cool_down.hide()
		timer_dash.hide()
	)
