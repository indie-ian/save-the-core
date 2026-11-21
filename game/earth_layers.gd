extends Node2D

@export var player: CharacterBody2D

var entered_crust: bool = false
var entered_upper_mantle: bool = false
var entered_lower_mantle: bool = false
var entered_core_entrance: bool = false

var crust_message: String = "CRUST LAYER"
var upper_mantle_message: String = "UPPER MANTLE LAYER"
var lower_mantle_message: String = "LOWER MANTLE LAYER"
var core_message: String = "APPROACHING THE CORE"

@onready var crust_entrance: Area2D = $CrustEntrance
@onready var upper_mantle_entrance: Area2D = $UpperMantleEntrance
@onready var lower_mantle_entrance: Area2D = $LowerMantleEntrance
@onready var core_entrance: Area2D = $CoreEntrance


func _ready() -> void:
	crust_entrance.body_entered.connect(_enter_layer.bind(crust_entrance))
	upper_mantle_entrance.body_entered.connect(_enter_layer.bind(upper_mantle_entrance))
	lower_mantle_entrance.body_entered.connect(_enter_layer.bind(lower_mantle_entrance))
	core_entrance.body_entered.connect(_enter_layer.bind(core_entrance))
	
	Global.manager.game_state.start_time()


func _enter_layer(body: Node2D, area: Area2D) -> void:
	if body == player:
		match area:
			crust_entrance:
				if !entered_crust:
					SignalBus.enter_layer.emit(crust_message)
				entered_crust = true
				return
			upper_mantle_entrance:
				if !entered_upper_mantle:
					SignalBus.enter_layer.emit(upper_mantle_message)
				entered_upper_mantle = true
				return
			lower_mantle_entrance:
				if !entered_lower_mantle:
					SignalBus.enter_layer.emit(lower_mantle_message)
				entered_lower_mantle = true
				return
			core_entrance:
				if !entered_core_entrance:
					SignalBus.enter_layer.emit(core_message)
				entered_core_entrance = true
				return
