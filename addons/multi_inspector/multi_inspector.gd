@tool
extends EditorPlugin

var _add_inspector_btn: Button
var _inspectors: Dictionary[int, DockControls] = {}
var _count: int = 1

func _handles(object: Object) -> bool:
	return true

func _edit(object: Object) -> void:
	for d: DockControls in _inspectors.values():
		if (!d.lock_button.button_pressed):
			d.inspector.edit(object)

func _enter_tree() -> void:
	_count = 1
	var inspector_dock: EditorDock = EditorInterface.get_dock_by_name("Inspector")
	var toolbar: HBoxContainer = inspector_dock.get_child(0, true).get_child(0, true)
	_add_inspector_btn = Button.new()
	_add_inspector_btn.pressed.connect(_on_add_inspector_btn_pressed)
	_add_inspector_btn.icon =  EditorInterface.get_editor_theme().get_icon("ToolAddNode", "EditorIcons")
	_add_inspector_btn.tooltip_text = "Add Inspector"
	toolbar.add_child(_add_inspector_btn)


func _exit_tree() -> void:
	if (_add_inspector_btn):
		_add_inspector_btn.queue_free()
	for i in _inspectors.keys():
		remove_dock(_inspectors[i].dock)
		_inspectors[i].dock.queue_free()
	_inspectors.clear()


func _on_add_inspector_btn_pressed() -> void:
	var d := DockControls.new()
	
	d.dock = EditorDock.new()
	d.dock.title = "Inspector " + str(_count)
	d.dock.dock_icon = EditorInterface.get_editor_theme().get_icon("EditorInspector", "EditorIcons")
	d.dock.default_slot = EditorDock.DOCK_SLOT_RIGHT_BL
	
	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	d.dock.add_child(vbox)
	
	var toolbar := HBoxContainer.new()
	toolbar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(toolbar)
	
	var filter := LineEdit.new()
	filter.placeholder_text = "Filter Properties"
	filter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	toolbar.add_child(filter)
	
	d.lock_button = Button.new()
	d.lock_button.flat = true
	d.lock_button.icon = EditorInterface.get_editor_theme().get_icon("Unlock", "EditorIcons")
	d.lock_button.toggle_mode = true
	d.lock_button.toggled.connect(_on_lock_button_toggled.bind(d.lock_button))
	d.lock_button.tooltip_text = "Lock/Unlock Edited Object"
	toolbar.add_child(d.lock_button)
	
	d.inspector = EditorInspector.create_default_inspector(filter)
	d.inspector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	d.inspector.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(d.inspector)
	
	_inspectors[_count] = d
	add_dock(d.dock)
	
	_count += 1

func _on_lock_button_toggled(button_pressed: bool, button: Button) -> void:
	button.icon = EditorInterface.get_editor_theme().get_icon("Lock" if button_pressed else "Unlock" , "EditorIcons")

class DockControls:
	var dock: EditorDock
	var inspector: EditorInspector
	var lock_button: Button
	
