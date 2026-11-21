extends Area2D

var turbo_drilling: bool = false
var is_drilling_now: bool = false

@export var drill_area: Vector2 = Vector2(24, 24)
@export var rig: CharacterBody2D # Player mining rig

#rig update
#The damage becomes 0.5 * delta (0.5 damage per second while you are rubbing against the tile, instead of 30 damage per second).
#we multiply the temperature/liquid value by delta (5.0 * delta), so that the tank doesn't empty instantaneously


func _ready() -> void:
	body_entered.connect(_drill_strike)

func _physics_process(delta: float) -> void:
	is_drilling_now = false
	
	if rig.velocity == Vector2.ZERO:
		turbo_drilling = false
	
	if has_overlapping_bodies() and rig.velocity != Vector2.ZERO:
		for body in get_overlapping_bodies():
			if body is TileMapLayer:
				_drill_floor(body, delta)
	
	if rig and rig.animated_sprite and rig.animated_sprite.material:
		var target_heat: float = 0.85 if is_drilling_now else 0.0
		var current_heat: float = rig.animated_sprite.material.get_shader_parameter("tip_heat")
		rig.animated_sprite.material.set_shader_parameter("tip_heat", lerp(current_heat, target_heat, 12.0 * delta))

func _drill_floor(body: Node2D, delta: float) -> void:
	var hit_hard_tile: bool = false
	var hit_slow_tile: bool = false
	var hit_coolant_tile: bool = false
	
	for x_pos in drill_area.x / 2:
		for y_pos in drill_area.y / 2:
			var q1: Vector2 = body.to_local(
				Vector2(global_position.x - x_pos, global_position.y - y_pos))
			var q2: Vector2 = body.to_local(
				Vector2(global_position.x + x_pos, global_position.y + y_pos))
			var q3: Vector2 = body.to_local(
				Vector2(global_position.x - x_pos, global_position.y + y_pos))
			var q4: Vector2 = body.to_local(
				Vector2(global_position.x + x_pos, global_position.y - y_pos))
			
			for point in [q1, q2, q3, q4]:
				var map_pos = body.local_to_map(point)
				if body.get_cell_source_id(map_pos) == -1:
					continue
					
				is_drilling_now = true
				var tile_data = body.get_cell_tile_data(map_pos)
				if tile_data and tile_data.get_custom_data("hard") == true and !turbo_drilling:
					hit_hard_tile = true
				elif tile_data and tile_data.get_custom_data("slow") == true:
					hit_slow_tile = true
				elif tile_data and tile_data.get_custom_data("liquid") == true:
					hit_coolant_tile = true
					body.erase_cell(map_pos)
				else:
					body.erase_cell(map_pos)
		
	if hit_hard_tile:
		rig._add_damage(rig.DAMAGE_BREAKABLE * delta)
		rig._add_red_temp(20.0 * delta)
		
	if hit_slow_tile:
		if !turbo_drilling:
			rig._apply_slow_effect()
			
	if hit_coolant_tile:
		rig._collect_liquid(0.5)

func _drill_strike(body: Node2D) -> void:
	if body is TileMapLayer:
		return
	
	if body.is_in_group("breakable"):
		if turbo_drilling:
			rig._apply_soft_hit()
			body.destroy.call_deferred()
		else:
			rig._apply_soft_hit()
			rig._add_damage(10.0) 
	else:
		rig._apply_hard_hit()
