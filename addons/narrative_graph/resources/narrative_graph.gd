@tool
class_name NarrativeGraph extends Resource

enum NodeType { Dialogue, Requirement }

@export var nodes: Dictionary = {}
@export var _flat_requirements: Dictionary = {}

signal node_added(node: String)
signal node_moved(node: String)
signal node_removed(node: String)
signal connection_added(from: String, to: String)
signal connection_removed(from: String, to: String)

var _counter: int = 0

var _selection_counter: int = 0

signal nodes_changed

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
	nodes_changed.emit()
	
func add_requirement(name: String) -> void:
	if nodes.has(name):
		return
		
	nodes[name] = NarrativeGraphNode.new()
	node_added.emit(name)
	nodes_changed.emit()
	
func remove_node(name: String) -> void:
	if !nodes.has(name):
		return
		
	for connection in get_node(name).opens:
		remove_connection(name, connection)
	
	for connection in get_node(name).requires:
		remove_connection(connection, name)
		
	nodes.erase(name)
	node_removed.emit(name)
	nodes_changed.emit()
	
func add_connection(from: String, to: String) -> void:
	if get_node(from).opens.has(to):
		return
	
	get_node(from).opens.append(to)
	get_node(to).requires.append(from)
	connection_added.emit(from, to)
	update_flat_requirements([to])
	
func remove_connection(from: String, to: String) -> void:
	if !get_node(from).opens.has(to):
		return
	
	get_node(from).opens.erase(to)
	get_node(to).requires.erase(from)
	connection_removed.emit(from, to)
	update_flat_requirements([to])

func move_node(node: String, position: Vector2) -> void:
	get_node(node).position = position
	node_moved.emit(node)
	
func update_all_flat_requirements() -> void:
	var no_requirement_node_keys: Array[String] = []
	for key in nodes:
		if get_node(key).requires.size() == 0:
			no_requirement_node_keys.append(key)
	update_flat_requirements(no_requirement_node_keys)
	
func update_flat_requirements(keys_to_check: Array[String], moving_up: bool = false) -> void:
	for key in keys_to_check:
		var node: = get_node(key)
		_flat_requirements[key] = {}
		for require_key in node.requires:
			if get_node(require_key).requires.size() != 0 && (!_flat_requirements.has(require_key) || _flat_requirements[require_key].size() == 0):
				update_flat_requirements([require_key], true)
			if _flat_requirements.has(require_key):
				(_flat_requirements[key] as Dictionary).merge(_flat_requirements[require_key])
			_flat_requirements[key][require_key] = null
		update_flat_requirements(node.opens)
	
func get_one_valid_dialogue(state: Dictionary) -> NarrativeGraphDialogueNode:
	var all_valid: Array[NarrativeGraphDialogueNode] = get_all_valid_dialogues(state)
	var current_priority: int = -INF
	var highest_priority_nodes: Array[NarrativeGraphDialogueNode] = []
	_selection_counter += 1
	
	for resource in all_valid:
		if resource.priority < current_priority:
			continue
		
		if resource.priority > current_priority:
			highest_priority_nodes = []
			current_priority = resource.priority
		highest_priority_nodes.append(resource)
	
	return highest_priority_nodes[_selection_counter % highest_priority_nodes.size()]
	
func get_all_valid_dialogues(state: Dictionary) -> Array[NarrativeGraphDialogueNode]:
	var true_values: Dictionary = {}
	for state_key in state:
		if state[state_key]:
			true_values[state_key] = null
	
	var valid_items: Array[NarrativeGraphDialogueNode] = []
	
	if !_flat_requirements:
		_flat_requirements = {}
		update_all_flat_requirements()
	
	for key in nodes:
		var node = get_node(key)
		var is_dialogue: bool = node is NarrativeGraphDialogueNode
		if is_dialogue:
			var has_requirements: bool = _flat_requirements.has(key)
			var has_met_all_requirements: bool = true_values.has_all(_flat_requirements[key].keys() if _flat_requirements.has(key) else [])
			var has_not_been_read: bool = key not in true_values
			var is_repeat: bool = node.repeat
			var openables_followups_exist: bool = false
			var no_followups_open: bool = false
			if is_repeat:
				openables_followups_exist = node.opens.any(func(open_key: String): return open_key not in true_values)
				no_followups_open = node.opens.all(func(open_key: String): return !true_values.has_all(_flat_requirements[open_key].keys()) || open_key in true_values)
			if (!has_requirements || has_met_all_requirements) && (has_not_been_read || (is_repeat && no_followups_open && openables_followups_exist)):
				valid_items.append(node)
	return valid_items
