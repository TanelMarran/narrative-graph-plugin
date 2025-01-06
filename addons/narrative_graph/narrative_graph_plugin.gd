@tool
extends EditorPlugin

var resource_edit_plugin: EditorInspectorPlugin

func _enter_tree():
	resource_edit_plugin = preload("res://addons/narrative_graph/plugins/narrative_graph_resource_editor.gd").new()
	add_inspector_plugin(resource_edit_plugin)
	print('yipii')


func _exit_tree():
	if resource_edit_plugin:
		remove_inspector_plugin(resource_edit_plugin)
		print('baybay')

func _handles(object):
	return object is NarrativePlayer

func _make_visible(visible):
	print(visible)
