@tool
class_name StateSelectorItem extends HBoxContainer

var label: String:
	set(value):
		label = value
		%Label.text = label

@export var next_color: Color
@export var default_color: Color
@export var requirement_color: Color

@onready var up_next_icon: TextureRect = %UpNext
@onready var is_checked: bool = %CheckBox.button_pressed:
	set(value):
		%CheckBox.button_pressed = value
var is_next: bool = false:
	set(value):
		is_next = value
		if !is_requirement:
			up_next_icon.self_modulate = next_color if value else default_color
var is_requirement: bool = false:
	set(value):
		is_requirement = value
		if is_requirement:
			up_next_icon.self_modulate = requirement_color
		else:
			up_next_icon.self_modulate = next_color if value else default_color

signal toggled(toggled_on: bool)

func _ready() -> void:
	%CheckBox.toggled.connect(func(toggled_on):
		is_checked = toggled_on
		toggled.emit(toggled_on)
	)
