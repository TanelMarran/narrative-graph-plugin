@tool
class_name StateSelector extends EditorProperty

var item_scene: PackedScene = preload("res://addons/narrative_graph/scenes/state_selector_item.tscn")

@onready var editor_container = %EditorContainer

func _ready() -> void:
	set_bottom_editor(editor_container)
		
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
