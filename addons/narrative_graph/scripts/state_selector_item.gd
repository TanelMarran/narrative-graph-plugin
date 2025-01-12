@tool
class_name StateSelectorItem extends HBoxContainer

var label: String:
	set(value):
		label = value
		%Label.text = label

@onready var is_checked: bool = %CheckBox.button_pressed:
	set(value):
		%CheckBox.button_pressed = value

signal toggled(toggled_on: bool)

func _ready() -> void:
	%CheckBox.toggled.connect(func(toggled_on):
		is_checked = toggled_on
		toggled.emit(toggled_on)
	)
