@tool
class_name NarrativeGraphDialogueNode extends NarrativeGraphNode

@export var repeat: bool = false
@export var priority: int = 0:
	set(value):
		priority = value
		data_changed.emit('priority', value)
