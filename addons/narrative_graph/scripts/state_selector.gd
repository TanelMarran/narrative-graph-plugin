@tool
class_name StateSelector extends EditorProperty

var item_scene: PackedScene = preload("res://addons/narrative_graph/scenes/state_selector_item.tscn")

@onready var editor_container = %EditorContainer
@onready var test_button = %TestButton

func _ready() -> void:
	set_bottom_editor(get_child(0))
	test_button.pressed.connect(print_valid_dialouges)
		
func _update_editor() -> void:
	var object: NarrativePlayer = get_edited_object()
	
	for child in editor_container.get_children():
		child.queue_free()
	
	for node_key in object.graph.nodes:
		var item: StateSelectorItem = item_scene.instantiate()
		item.label = object.graph.get_node(node_key).name
		item.is_checked = object.state[node_key]
		item.toggled.connect(func(is_toggled: bool):
			object.state[node_key] = is_toggled
			emit_changed('state', is_toggled)
		)
		editor_container.add_child(item)

func _update_property() -> void:
	_update_editor()

func print_valid_dialouges() -> void:
	var object: NarrativePlayer = get_edited_object()
	var valid_nodes = object.graph.get_all_valid_dialogues(object.state)
	print(valid_nodes)
