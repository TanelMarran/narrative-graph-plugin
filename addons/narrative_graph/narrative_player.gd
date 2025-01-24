@tool
class_name NarrativePlayer extends Node

@export var graph: NarrativeGraph:
	set(value):
		graph = value
		graph.nodes_changed.connect(_on_graph_nodes_changed)
		update_state_dictionary()

@export var state: Dictionary = {}

func _on_graph_nodes_changed() -> void:
	update_state_dictionary()

func update_state_dictionary() -> Dictionary:
	var new_state: Dictionary = {}
	if graph:
		for node_key in graph.nodes:
			new_state[node_key] = state[node_key] if state.has(node_key) else false
		state = new_state
		
	return state

func _ready() -> void:
	if graph && !graph.nodes_changed.is_connected(_on_graph_nodes_changed):
		graph.nodes_changed.connect(_on_graph_nodes_changed)
	if Engine.is_editor_hint():
		update_state_dictionary()
