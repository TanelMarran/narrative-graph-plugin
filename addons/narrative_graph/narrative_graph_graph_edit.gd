@tool
class_name NarrativeGraphEdit extends Control

const SCENE_DIALOGUE_NODE: PackedScene = preload("res://addons/narrative_graph/scenes/narrative_graph_node_dialogue.tscn")
const SCENE_REQUISITE_NODE: PackedScene = preload("res://addons/narrative_graph/scenes/narrative_graph_node_requisite.tscn")

var plugin: NarrativeGraphPlugin
var undo_redo: EditorUndoRedoManager

var graph: NarrativeGraph:
	set = set_narrative_graph
	
var graph_nodes: Dictionary = {}

var selected_nodes: Array[Node] = []

var _is_dragging: bool = false
var _drag_amount: Vector2 = Vector2.ZERO

@onready var add_dialogue_button: Button = %AddDialogueButton
@onready var add_requirement_button: Button = %AddRequirementButton
@onready var arrange_nodes_button: Button = %ArrangeNodesButton
@onready var graph_edit: GraphEdit = %GraphEdit

var _current_resource_data_changed_connections: Dictionary = {}

signal drag_released()

func _ready():
	graph_edit.show_arrange_button = false
	
	graph_edit.delete_nodes_request.connect(_on_delete_nodes_request)
	
	graph_edit.end_node_move.connect(_on_end_node_move)
	
	graph_edit.gui_input.connect(_on_gui_input)
	graph_edit.connection_request.connect(_on_connection_request)
	graph_edit.disconnection_request.connect(_on_disconnection_request)
	
	graph_edit.node_selected.connect(_on_node_selected)
	graph_edit.node_deselected.connect(_on_node_deselected)
	
	add_dialogue_button.pressed.connect(_on_add_dialogue_button_pressed)
	add_requirement_button.pressed.connect(_on_add_requirement_button_pressed)
	arrange_nodes_button.pressed.connect(_on_arrange_nodes_button_pressed)

func set_narrative_graph(new_graph: NarrativeGraph) -> void:
	var is_new_graph: bool = new_graph != graph
	
	if is_new_graph && new_graph:
		if graph:
			disconnect_from_graph(graph)
		connect_to_graph(new_graph)
		setup_graph_edit(new_graph)
	
	graph = new_graph

func _on_gui_input(event: InputEvent) -> void:
	var mouse_event_button: InputEventMouseButton = event as InputEventMouseButton
	if mouse_event_button:
		if mouse_event_button.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event_button.is_pressed():
				_is_dragging = true
			elif mouse_event_button.is_released():
				_is_dragging = false
				drag_released.emit()
	else:
		var mouse_event_motion: InputEventMouseMotion = event as InputEventMouseMotion
		if mouse_event_motion:
			if _is_dragging:
				_drag_amount += mouse_event_motion.velocity
			else:
				_drag_amount = Vector2.ZERO

func _on_resource_data_changed(key: String, value, _name: String) -> void:
	(graph_nodes[_name] as NarrativeGraphNodeControl).get_label_with_name(key).text = str(value)

func setup_graph_edit(target_graph: NarrativeGraph) -> void:
	graph_edit.clear_connections()
	selected_nodes.clear()
	
	for node in graph_nodes:
		graph_nodes.get(node).queue_free()
		await graph_nodes.get(node).tree_exited
	graph_nodes.clear()
	
	for node_key in target_graph.nodes.keys():
		var resource: NarrativeGraphNode = target_graph.get_node(node_key)
		var is_dialogue_node: bool = resource is NarrativeGraphDialogueNode
		var node: NarrativeGraphNodeControl = SCENE_DIALOGUE_NODE.instantiate() if is_dialogue_node else SCENE_REQUISITE_NODE.instantiate()
		node.name = node_key
		node.title = node.title + node_key
		node.position_offset = resource.position
		node.ready.connect(func():
			for label: Label in node.paramenter_labels:
				if label:
					label.text = str(resource.get(label.name.to_lower()))
		, CONNECT_ONE_SHOT)
		graph_edit.add_child(node)
		
		graph_nodes[node_key] = node
	
	for node_key in target_graph.nodes.keys():
		var requirements: = target_graph.get_node(node_key).requires
		for require_key in requirements:
			var error = graph_edit.connect_node(require_key, 0, node_key, 0)

func _on_node_selected(node: Node) -> void:
	selected_nodes.append(node)
	if _drag_amount.length() < 100:
		await drag_released
		EditorInterface.edit_resource(graph.get_node(node.name))

func _on_node_deselected(node: Node) -> void:
	selected_nodes.erase(node)

func disconnect_from_graph(_graph: NarrativeGraph) -> void:
	if _graph:
		_graph.connection_added.disconnect(_on_graph_connection_added)
		_graph.connection_removed.disconnect(_on_graph_connection_removed)
		_graph.node_added.disconnect(_on_graph_node_added)
		_graph.node_removed.disconnect(_on_graph_node_removed)
		_graph.node_moved.disconnect(_on_graph_node_moved)
		for node_key in _graph.nodes:
			_graph.get_node(node_key).data_changed.disconnect(_current_resource_data_changed_connections[node_key])
		

func connect_to_graph(_graph: NarrativeGraph) -> void:
	if _graph:
		_graph.connection_added.connect(_on_graph_connection_added)
		_graph.connection_removed.connect(_on_graph_connection_removed)
		_graph.node_added.connect(_on_graph_node_added)
		_graph.node_removed.connect(_on_graph_node_removed)
		_graph.node_moved.connect(_on_graph_node_moved)
		for node_key in _graph.nodes:
			var callable = _on_resource_data_changed.bind(node_key)
			_current_resource_data_changed_connections[node_key] = callable
			_graph.get_node(node_key).data_changed.connect(callable)

func _on_graph_connection_added(from: String, to: String) -> void:
	graph_edit.connect_node(from, 0, to, 0)

func _on_graph_connection_removed(from: String, to: String) -> void:
	graph_edit.disconnect_node(from, 0, to, 0)

func _on_graph_node_added(node_key: String) -> void:
	var resource = graph.get_node(node_key)
	var is_dialogue_node: bool = resource is NarrativeGraphDialogueNode
	var node = SCENE_DIALOGUE_NODE.instantiate() if is_dialogue_node else SCENE_REQUISITE_NODE.instantiate()
	node.name = node_key
	node.title = node.title + node_key
	node.ready.connect(func():
		for label: Label in node.paramenter_labels:
			if label:
				label.text = str(resource.get(label.name.to_lower()))
	, CONNECT_ONE_SHOT)
	var callable = _on_resource_data_changed.bind(node_key)
	_current_resource_data_changed_connections[node_key] = callable
	resource.data_changed.connect(callable)
	graph_nodes[node_key] = node
	graph_edit.add_child(node)

func _on_graph_node_removed(node: String) -> void:
	graph_nodes[node].queue_free()
	graph_nodes.erase(node)

func _on_graph_node_moved(node: String) -> void:
	graph_nodes[node].position_offset = graph.get_node(node).position
	
func _on_delete_nodes_request(names: Array[StringName]) -> void:
	for node_key in names:
		action_remove_node('Remove node', node_key, UndoRedo.MERGE_ALL)
	
func _on_end_node_move() -> void:
	for node in (selected_nodes if selected_nodes.size() > 0 else graph_nodes.values()):
		if node is NarrativeGraphNodeControl:
			undo_redo.create_action('Node moved', UndoRedo.MERGE_ALL)
			undo_redo.add_do_method(graph, "move_node", node.name, node.position_offset)
			undo_redo.add_undo_method(graph, "move_node", node.name, graph.get_node(node.name).position)
			undo_redo.commit_action()
	
func _on_add_dialogue_button_pressed() -> void:
	action_add_dialogue('Add node')
	
func _on_add_requirement_button_pressed() -> void:
	action_add_requirement('Add node')
	
func _on_arrange_nodes_button_pressed() -> void:
	graph_edit.arrange_nodes()
	_on_end_node_move()
	
func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int):
	action_add_connection('Add connection', from_node, to_node)
	
func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int):
	action_remove_connenction('Remove connection', from_node, to_node)

func action_add_dialogue(action_name: String, merge_mode: UndoRedo.MergeMode = UndoRedo.MERGE_DISABLE) -> void:
	var key = graph.get_valid_key()
	undo_redo.create_action(action_name, merge_mode)
	undo_redo.add_do_method(graph, "add_dialogue", key)
	undo_redo.add_undo_method(graph, "remove_node", key)
	undo_redo.commit_action()

func action_add_requirement(action_name: String, merge_mode: UndoRedo.MergeMode = UndoRedo.MERGE_DISABLE) -> void:
	var key = graph.get_valid_key()
	undo_redo.create_action(action_name, merge_mode)
	undo_redo.add_do_method(graph, "add_requirement", key)
	undo_redo.add_undo_method(graph, "remove_node", key)
	undo_redo.commit_action()
	
func action_remove_node(action_name: String, key: String, merge_mode: UndoRedo.MergeMode = UndoRedo.MERGE_DISABLE) -> void:
	var undo_method = "add_dialogue" if graph.get_node(key) is NarrativeGraphDialogueNode else "add_requirement"
	undo_redo.create_action(action_name, merge_mode)
	undo_redo.add_do_method(graph, "remove_node", key)
	undo_redo.add_undo_method(graph, undo_method, key)
	for requirement_key in graph.get_node(key).requires:
		undo_redo.add_undo_method(graph, "add_connection", requirement_key, key)
	for opens_key in graph.get_node(key).opens:
		undo_redo.add_undo_method(graph, "add_connection", key, opens_key)
	undo_redo.commit_action()
	
func action_add_connection(action_name: String, from: String, to: String, merge_mode: UndoRedo.MergeMode = UndoRedo.MERGE_DISABLE) -> void:
	undo_redo.create_action(action_name, merge_mode)
	undo_redo.add_do_method(graph, "add_connection", from, to)
	undo_redo.add_undo_method(graph, "remove_connection", from, to)
	undo_redo.commit_action()

func action_remove_connenction(action_name: String, from: String, to: String, merge_mode: UndoRedo.MergeMode = UndoRedo.MERGE_DISABLE) -> void:
	undo_redo.create_action(action_name, merge_mode)
	undo_redo.add_do_method(graph, "remove_connection", from, to)
	undo_redo.add_undo_method(graph, "add_connection", from, to)
	undo_redo.commit_action()
