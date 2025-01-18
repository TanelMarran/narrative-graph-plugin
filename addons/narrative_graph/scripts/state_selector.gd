@tool
class_name StateSelector extends EditorProperty

var item_scene: PackedScene = preload("res://addons/narrative_graph/scenes/state_selector_item.tscn")

var _nodes: Dictionary = {}

@onready var editor_container = %EditorContainer
@onready var test_button = %TestButton

func _ready() -> void:
	set_bottom_editor(get_child(0))
	test_button.pressed.connect(update_valid_dialouges)
		
func _update_editor() -> void:
	var object: NarrativePlayer = get_edited_object()
	
	for child in editor_container.get_children():
		child.queue_free()
	
	_nodes.clear()
	for node_key in object.graph.nodes:
		var item: StateSelectorItem = item_scene.instantiate()
		var resource = object.graph.get_node(node_key)
		item.label = resource.name
		item.is_checked = object.state[node_key]
		item.ready.connect(func():
			item.is_requirement = resource is not NarrativeGraphDialogueNode
		, CONNECT_ONE_SHOT)
		_nodes[resource.name] = item
		item.toggled.connect(func(is_toggled: bool):
			object.state[node_key] = is_toggled
			emit_changed('state', is_toggled)
		)
		editor_container.add_child(item)
		if item.is_requirement:
			editor_container.move_child(item, 0)
	
	update_valid_dialouges()

func _update_property() -> void:
	_update_editor()

func update_valid_dialouges() -> void:
	var object: NarrativePlayer = get_edited_object()
	var valid_nodes = object.graph.get_all_valid_dialogues(object.state).map(func(element): return element.name)
	for node_key in _nodes:
		_nodes[node_key].is_next = node_key in valid_nodes
