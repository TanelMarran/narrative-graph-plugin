@tool
class_name NarrativeGraphNodeInspectorPlugin extends EditorInspectorPlugin

func _can_handle(object: Object) -> bool:
	return object is NarrativeGraphNode

func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	if name == 'position':
		return true
	
	return false
