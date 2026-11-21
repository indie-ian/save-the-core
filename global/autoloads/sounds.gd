extends Node

const MAX_DRILLING: float = 100.0

var drilling_tween: Tween
var charge_tween: Tween

@onready var music: AudioStreamPlayer = $Music
@onready var drilling: AudioStreamPlayer = $Drilling
@onready var impact: AudioStreamPlayer = $Impact
@onready var overcharge: AudioStreamPlayer = $Overcharge
@onready var charge: AudioStreamPlayer = $Charge

func _ready() -> void:
	music.play()


func modulate_engine(velocity: Vector2) -> void:
	if !drilling.playing:
		drilling.volume_linear = 4.0
		drilling.play()
		if drilling_tween:
			drilling_tween.kill()
		drilling_tween = create_tween()
		drilling_tween.tween_property(drilling, "volume_linear", 0.0, velocity.length() / 1000)
		await drilling_tween.finished
		drilling.stop()

func charge_up() -> void:
	charge.volume_linear = 0.0
	charge.play()
	if charge_tween:
			charge_tween.kill()
	charge_tween = create_tween()
	charge_tween.tween_property(charge, "volume_linear", 5.0, 2.0)

func stop_charge(fade_time: float = 0.05) -> void:
	if charge_tween:
		charge_tween.kill()
	if charge.playing:
		if fade_time > 0.0:
			charge_tween = create_tween()
			charge_tween.tween_property(charge, "volume_linear", 0.0, fade_time)
			await charge_tween.finished
		charge.stop()
		charge.volume_linear = 0.0


func play_boom() -> void:
	overcharge.play()
