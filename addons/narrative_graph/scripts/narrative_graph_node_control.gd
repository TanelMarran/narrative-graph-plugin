@tool
class_name NarrativeGraphNodeControl extends GraphNode

@export var paramenter_labels: Array[Label] = []

func get_label_with_name(_name:  String) -> Label:
	return paramenter_labels.filter(func(element): return element.name.to_lower() == _name)[0]
