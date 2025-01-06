extends EditorInspectorPlugin


func _can_handle(object: Object):
	return object is NarrativePlayer

func _parse_begin(object: Object):
	var label = Label.new()
	label.text = 'testing!:)'
	add_custom_control(label)
