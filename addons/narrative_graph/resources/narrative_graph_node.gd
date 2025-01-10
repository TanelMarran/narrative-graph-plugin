@tool
class_name NarrativeGraphNode extends Resource

@export var name: String:
	set(value):
		name = value
		data_changed.emit('name', value)

@export var position: Vector2 = Vector2.ZERO

@export var requires: Array[String]
@export var opens: Array[String]

signal data_changed
