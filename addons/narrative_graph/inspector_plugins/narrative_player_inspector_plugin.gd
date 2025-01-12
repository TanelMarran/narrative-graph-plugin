@tool
class_name NarrativePlayerInspectorPlugin extends EditorInspectorPlugin

func _can_handle(object: Object) -> bool:
	return object is NarrativePlayer
	
func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	if name == 'state':
		var editor = preload("res://addons/narrative_graph/scenes/state_selector.tscn").instantiate() as EditorProperty
		add_property_editor('state', editor, false, 'State')
		return true
		
	return false
