extends Node3D

class_name SaveLoad

var save_path: String = "user://design.json"

func _ready() -> void:
	var ui_root: Node = get_tree().root.get_node("Main/UI/Root")
	
	var btn_save: Button = ui_root.get_node("TopBar/BtnSave")
	var btn_load: Button = ui_root.get_node("TopBar/BtnLoad")
	var btn_screenshot: Button = ui_root.get_node("TopBar/BtnScreenshot")
	var btn_import: Button = ui_root.get_node("TopBar/BtnImportRoom")
	var btn_showrooms: Button = ui_root.get_node("TopBar/BtnShowrooms")
	var btn_measure: Button = ui_root.get_node("TopBar/BtnMeasure")
	var btn_occluder: Button = ui_root.get_node("TopBar/BtnOccluder")
	
	btn_save.pressed.connect(_on_save)
	btn_load.pressed.connect(_on_load)
	btn_screenshot.pressed.connect(_on_screenshot)
	btn_import.pressed.connect(_on_import_room)
	btn_showrooms.pressed.connect(_on_load_showroom)
	btn_measure.pressed.connect(_on_toggle_measure)
	btn_occluder.pressed.connect(_on_toggle_occluder)

func _gather_design() -> Array[Dictionary]:
	var placed: Array[Dictionary] = []
	for child in get_children():
		if child is Node3D and child.name.begins_with("Instance"):
			placed.append({
				"name": child.name,
				"xform": child.global_transform
			})
	return placed

func _apply_design(data: Array[Dictionary]) -> void:
	for e in data:
		var box: MeshInstance3D = MeshInstance3D.new()
		var mesh: BoxMesh = BoxMesh.new()
		mesh.size = Vector3(0.5, 0.5, 0.5)
		box.mesh = mesh
		add_child(box)
		box.global_transform = e["xform"]

func _on_save() -> void:
	var state: Dictionary = {
		"placed": _gather_design()
	}
	var f: FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(state, "\t"))
		f.close()
		print("Saved to ", save_path)
	else:
		push_error("Failed to open file for saving: %s" % save_path)

func _on_load() -> void:
	if not FileAccess.file_exists(save_path):
		push_warning("No saved design at %s" % save_path)
		return

	var f: FileAccess = FileAccess.open(save_path, FileAccess.READ)
	if not f:
		push_error("Failed to open file for loading: %s" % save_path)
		return

	var text: String = f.get_as_text()
	f.close()
	
	var parse_result: Dictionary = JSON.parse_string(text)
	if parse_result.has("placed"):
		_apply_design(parse_result["placed"])

func _on_screenshot() -> void:
	var img: Image = get_viewport().get_texture().get_image()
	var path: String = "user://screenshot_%d.png" % Time.get_unix_time_from_system()
	img.save_png(path)
	print("Screenshot saved to ", path)

func _on_import_room() -> void:
	print("TODO: implement runtime GLB/OBJ import (drop your LiDAR/photogrammetry scan in res://assets/showrooms and load via menu).")

func _on_load_showroom() -> void:
	print("TODO: implement showroom loader from res://data/showrooms.json")

func _on_toggle_measure() -> void:
	# handled by MeasureTool
	pass

func _on_toggle_occluder() -> void:
	# handled by OccluderTool
	pass
