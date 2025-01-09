@tool
class_name NarrativeGraph extends Resource

enum NodeType { Dialogue, Requirement }

@export var nodes: Dictionary = {}

signal node_added(node: String)
signal node_moved(node: String)
signal node_removed(node: String)
signal connection_added(from: String, to: String)
signal connection_removed(from: String, to: String)

var _counter: int = 0

func get_node(name: String) -> NarrativeGraphNode:
	if !nodes.has(name):
		return null
	
	return nodes[name]

func get_valid_key() -> String:
	var key = 0
	while (nodes.has(str(key))):
		key += 1
	return str(key)

func add_dialogue(name: String) -> void:
	if nodes.has(name):
		return
		
	nodes[name] = NarrativeGraphDialogueNode.new()
	node_added.emit(name)
	
func add_requirement(name: String) -> void:
	if nodes.has(name):
		return
		
	nodes[name] = NarrativeGraphNode.new()
	node_added.emit(name)
	
func remove_node(name: String) -> void:
	if !nodes.has(name):
		return
		
	for connection in get_node(name).opens:
		remove_connection(name, connection)
	
	for connection in get_node(name).requires:
		remove_connection(connection, name)
		
	nodes.erase(name)
	node_removed.emit(name)
	
func add_connection(from: String, to: String) -> void:
	if get_node(from).opens.has(to):
		return
	
	get_node(from).opens.append(to)
	get_node(to).requires.append(from)
	connection_added.emit(from, to)
	
func remove_connection(from: String, to: String) -> void:
	if !get_node(from).opens.has(to):
		return
	
	get_node(from).opens.erase(to)
	get_node(to).requires.erase(from)
	connection_added.emit(from, to)

func move_node(node: String, position: Vector2) -> void:
	get_node(node).position = position
	node_moved.emit(node)
