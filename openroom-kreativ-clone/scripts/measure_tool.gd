extends Node3D

class_name MeasureTool

var measuring := false
var start_point := Vector3.ZERO
var line: MeshInstance3D

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_measure"):
		measuring = !measuring
		if not measuring:
			_clear_line()

	if not measuring:
		return

	# Update measure line from camera center to collision point
	var cam := get_viewport().get_camera_3d()
	var screen_center := get_viewport().get_visible_rect().size * 0.5
	var from := cam.project_ray_origin(screen_center)
	var dir := cam.project_ray_normal(screen_center)
	var space := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, from + dir * 100.0)
	var res := space.intersect_ray(query)

	if res.has("position"):
		var hit: Vector3 = res["position"]
		if start_point == Vector3.ZERO:
			start_point = hit
			_create_line()
		else:
			_update_line(start_point, hit)
			_draw_distance_label(start_point.distance_to(hit))

func _create_line() -> void:
	line = MeshInstance3D.new()
	line.mesh = ImmediateMesh.new()
	add_child(line)

func _update_line(a: Vector3, b: Vector3) -> void:
	var im := line.mesh as ImmediateMesh
	im.clear_surfaces()
	im.surface_begin(Mesh.PRIMITIVE_LINES)
	im.surface_add_vertex(a)
	im.surface_add_vertex(b)
	im.surface_end()

func _draw_distance_label(dist: float) -> void:
	# In a real app you'd use 3D text; here we write to the window title for simplicity
	get_tree().root.title = "Distance: %.3f m" % dist

func _clear_line() -> void:
	start_point = Vector3.ZERO
	if line:
		line.queue_free()
		line = null
