extends GraphEdit

const SCENE_DIALOGUE_NODE: PackedScene = preload("res://addons/narrative_graph/scenes/narrative_graph_node_dialogue.tscn")

var narrative_graph: NarrativeGraph

func set_narrative_graph(graph: NarrativeGraph) -> void:
	narrative_graph = graph

func _ready():
	connection_request.connect(_on_connection_request)
	disconnection_request.connect(_on_disconnection_request)
	
func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int):
	connect_node(from_node, from_port, to_node, to_port)
	connection_request.connect(_on_connection_request)
	
func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int):
	disconnect_node(from_node, from_port, to_node, to_port)
