@tool
class_name NarrativeGraphPlugin extends EditorPlugin

var narrative_graph_edit: NarrativeGraphEdit
var narrative_player: NarrativePlayer
var undo_redo: EditorUndoRedoManager

var narrative_graph_zoom: float
var narrative_graph_offset: Vector2

func _enter_tree():
	undo_redo = get_undo_redo()
	narrative_graph_edit = preload("res://addons/narrative_graph/scenes/graph_editor.tscn").instantiate() as NarrativeGraphEdit
	narrative_graph_edit.ready.connect(func():
		narrative_graph_edit.graph_edit.zoom = narrative_graph_zoom
		narrative_graph_edit.graph_edit.scroll_offset = narrative_graph_offset
		narrative_graph_edit.graph_edit.scroll_offset_changed.connect(func(offset: Vector2):
			narrative_graph_offset = offset
		)
	)
	narrative_graph_edit.plugin = self
	narrative_graph_edit.undo_redo = undo_redo

func _exit_tree():
	if narrative_graph_edit:
		remove_control_from_bottom_panel(narrative_graph_edit)

func _handles(object):
	return object is NarrativeGraph
	
func _edit(object: Object) -> void:
	if object is not NarrativeGraph:
		return
		
	narrative_graph_edit.set_narrative_graph(object as NarrativeGraph)
	
	make_bottom_panel_item_visible(narrative_graph_edit)

func _make_visible(visible):
	if visible:
		var button: Button = add_control_to_bottom_panel(narrative_graph_edit, "Narrative Graph")
		make_bottom_panel_item_visible(narrative_graph_edit)
	else:
		remove_control_from_bottom_panel(narrative_graph_edit)

func _get_state() -> Dictionary:
	if narrative_graph_edit && narrative_graph_edit.graph_edit:
		narrative_graph_offset = narrative_graph_edit.graph_edit.scroll_offset
		narrative_graph_zoom = narrative_graph_edit.graph_edit.zoom
	
	return {
		'scroll_offset': narrative_graph_offset,
		'screen_zoom': narrative_graph_zoom
	}
	
func _set_state(state: Dictionary) -> void:
	narrative_graph_zoom = state.get('screen_zoom', 1)
	narrative_graph_offset = state.get('scroll_offset', Vector2.ZERO)
	
func _get_plugin_name() -> String:
	return 'Narrative Graph'
