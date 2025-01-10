@tool
class_name NarrativeGraphDialogueNode extends NarrativeGraphNode

@export var priority: int:
	set(value):
		priority = value
		data_changed.emit('priority', value)
