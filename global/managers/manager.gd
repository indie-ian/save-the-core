extends Node
class_name Manager

@export var current_node2d: Node2D
@export var current_ui: Control

var previous_node2d
var previous_ui
var current_narrative
var previous_narrative
var current_pause
var previous_pause

@onready var game_state: GameState = $States/GameState
@onready var node2d_tree: Node2D = $Node2DTree
@onready var ui_tree: Control = $UITree
@onready var narrative_tree: CanvasLayer = $NarrativeTree
@onready var pause_tree: CanvasLayer = $PauseTree


func _ready() -> void:
	Global.manager = self


func update_node2d_tree(path: String, keep: bool = false) -> void:
	if current_node2d:
		if keep:
			previous_node2d = current_node2d
			previous_node2d.hide()
		else:
			current_node2d.queue_free()
	
	var new_node2d = load(path).instantiate()
	node2d_tree.add_child(new_node2d)
	current_node2d = new_node2d


func update_ui_tree(path: String, keep: bool = false) -> void:
	if current_ui:
		if keep:
			previous_ui = current_ui
			previous_ui.hide()
		else:
			current_ui.queue_free()
	
	var new_ui = load(path).instantiate()
	ui_tree.add_child(new_ui)
	current_ui = new_ui


func update_narrative_tree(path: String, keep: bool = false) -> void:
	if current_narrative:
		if keep:
			previous_narrative = current_narrative
			previous_narrative.hide()
		else:
			current_narrative.queue_free()
	
	var new_narrative = load(path).instantiate()
	narrative_tree.add_child(new_narrative)
	current_narrative = new_narrative


func update_pause_tree(path: String, keep: bool = false) -> void:
	if current_pause:
		if keep:
			previous_pause = current_pause
			previous_pause.hide()
		else:
			current_pause.queue_free()
	
	var new_pause = load(path).instantiate()
	pause_tree.add_child(new_pause)
	current_pause = new_pause


func clear_tree(tree: Node) -> void:
	var tree_to_clear: Node = null
	
	match tree:
		node2d_tree:
			tree_to_clear = node2d_tree
		ui_tree:
			tree_to_clear = ui_tree
		narrative_tree:
			tree_to_clear = narrative_tree
		pause_tree:
			tree_to_clear = pause_tree
		_:
			printerr("Unable to clear tree: Tree does not exist.")
			return
	
	if tree_to_clear != null:
		for child in tree_to_clear.get_children():
			child.queue_free()
