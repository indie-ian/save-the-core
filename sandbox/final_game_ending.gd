extends Node2D

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D

const FIRST_ANIM := "first scene"
const FLASH_ANIM := "flash"
const PLANET_ANIM := "planetRotation"
const SPRITE_SIZE := Vector2(256.0, 128.0)
const ZOOM_TRIGGER_FRAME := 9

@export var zoom_in_multiplier: float = 1.6
@export var right_pan_distance: float = 30.0
@export var shake_strength: float = 0.5
@export var smooth_speed: float = 8.0
@export var slow_mo_speed: float = 0.45

@export var zoom_out_end_multiplier: float = 0.2

@onready var main_button: Button = $Panel3/MainButton
@onready var score_label: Label = $Panel3/ScoreLabel

var charge_started: bool = false
var base_zoom: Vector2 = Vector2.ONE
var cover_zoom: Vector2 = Vector2.ONE
var planet_start_zoom: Vector2 = Vector2.ONE
var planet_end_zoom: Vector2 = Vector2.ONE
var base_cam_pos: Vector2 = Vector2.ZERO

var is_zoom_active: bool = false
var is_flash_active: bool = false
var is_planet_active: bool = false

func _ready() -> void:
	main_button.pressed.connect(Global.manager.update_ui_tree.bind(Library.MAIN_MENU_SCENE))
	
	base_cam_pos = anim_sprite.global_position
	camera.global_position = base_cam_pos
	camera.make_current()

	var viewport_size: Vector2 = get_viewport_rect().size

	var fill_zoom: float = max(viewport_size.x / SPRITE_SIZE.x, viewport_size.y / SPRITE_SIZE.y)
	cover_zoom = Vector2(fill_zoom, fill_zoom)
	base_zoom = cover_zoom

	camera.zoom = base_zoom

	if not anim_sprite.animation_finished.is_connected(_on_animation_finished):
		anim_sprite.animation_finished.connect(_on_animation_finished)

	anim_sprite.speed_scale = 1.0
	anim_sprite.play(FIRST_ANIM)
	
	score_label.text = "Time: %02d:%02d" % [ Global.manager.game_state.end_time_min, Global.manager.game_state.end_time_sec ]

func _process(delta: float) -> void:
	if is_flash_active:
		camera.global_position = base_cam_pos
		camera.zoom = cover_zoom
		anim_sprite.speed_scale = 1.0
		return

	if is_planet_active:
		camera.global_position = base_cam_pos
		anim_sprite.speed_scale = 1.0

		var total_frames: int = 1
		if anim_sprite.sprite_frames and anim_sprite.sprite_frames.has_animation(PLANET_ANIM):
			total_frames = max(anim_sprite.sprite_frames.get_frame_count(PLANET_ANIM), 1)

		var last_frame_index: float = max(float(total_frames - 1), 1.0)
		var progress: float = clamp(float(anim_sprite.frame) / last_frame_index, 0.0, 1.0)

		var desired_zoom: Vector2 = planet_start_zoom.lerp(planet_end_zoom, progress)
		camera.zoom = camera.zoom.lerp(desired_zoom, smooth_speed * delta)
		return

	var target_zoom: Vector2 = base_zoom
	var target_pos: Vector2 = base_cam_pos
	var target_speed: float = 1.0
	var current_shake: float = 0.0

	if anim_sprite.animation == FIRST_ANIM and anim_sprite.is_playing():
		if anim_sprite.frame >= ZOOM_TRIGGER_FRAME:
			is_zoom_active = true
			if not charge_started:
				charge_started = true
				Sounds.charge_up()

	if is_zoom_active:
		target_zoom = base_zoom * zoom_in_multiplier
		target_pos = base_cam_pos + Vector2(right_pan_distance, 0.0)
		target_speed = slow_mo_speed
		current_shake = shake_strength

	anim_sprite.speed_scale = lerp(anim_sprite.speed_scale, target_speed, smooth_speed * delta)
	camera.zoom = camera.zoom.lerp(target_zoom, smooth_speed * delta)
	var smooth_pos: Vector2 = camera.global_position.lerp(target_pos, smooth_speed * delta)

	if current_shake > 0.0:
		var jitter := Vector2(
			randf_range(-current_shake, current_shake),
			randf_range(-current_shake, current_shake)
		)
		camera.global_position = smooth_pos + jitter
	else:
		camera.global_position = smooth_pos

func _on_animation_finished() -> void:
	if anim_sprite.animation == FIRST_ANIM:
		is_zoom_active = false
		is_flash_active = true
		is_planet_active = false

		camera.global_position = base_cam_pos
		camera.zoom = cover_zoom
		anim_sprite.speed_scale = 1.0
		anim_sprite.play(FLASH_ANIM)
		Sounds.stop_charge(0.04)
		Sounds.play_boom()

	elif anim_sprite.animation == FLASH_ANIM:
		is_zoom_active = false
		is_flash_active = false
		is_planet_active = true

		planet_start_zoom = camera.zoom
		planet_end_zoom = base_zoom * zoom_out_end_multiplier

		camera.global_position = base_cam_pos
		anim_sprite.speed_scale = 1.0
		anim_sprite.play(PLANET_ANIM)

	elif anim_sprite.animation == PLANET_ANIM:
		camera.zoom = planet_end_zoom
