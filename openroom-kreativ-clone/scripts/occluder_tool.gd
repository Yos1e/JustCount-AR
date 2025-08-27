extends Node3D

class_name OccluderTool

var active := false
var current_box: MeshInstance3D

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_occluder"):
		active = !active
		if not active:
			_finalize_box()
		else:
			_start_box()

	if not active:
		return

	var cam := get_viewport().get_camera_3d()
	var screen_center := get_viewport().get_visible_rect().size * 0.5
	var from := cam.project_ray_origin(screen_center)
	var dir := cam.project_ray_normal(screen_center)
	var space := get_world_3d().direct_space_state
	var res := space.intersect_ray(PhysicsRayQueryParameters3D.create(from, from + dir * 100))

	if res.has("position") and current_box:
		var hit: Vector3 = res["position"]
		var origin := current_box.global_transform.origin
		var size := (hit - origin).abs() * 2.0
		size.y = max(size.y, 0.1)
		(current_box.mesh as BoxMesh).size = size

func _start_box() -> void:
	_finalize_box()
	current_box = MeshInstance3D.new()
	current_box.mesh = BoxMesh.new()
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.1, 0.1, 0.1, 0.25)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	current_box.material_override = mat
	add_child(current_box)

	# Place at current ray hit
	var cam := get_viewport().get_camera_3d()
	var c := get_viewport().get_visible_rect().size * 0.5
	var from := cam.project_ray_origin(c)
	var dir := cam.project_ray_normal(c)
	var res := get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, from + dir * 100))
	var hit: Vector3 = res.get("position", Vector3.ZERO)
	current_box.global_transform.origin = hit
	(current_box.mesh as BoxMesh).size = Vector3(0.2, 0.2, 0.2)

func _finalize_box() -> void:
	current_box = null
