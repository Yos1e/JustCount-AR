extends Node
class_name VRPlacement

@export var placement_scene: PackedScene
@export var grid_snap: float = 0.1
@export var rotation_speed_deg: float = 60.0
@export var scale_speed: float = 0.25
@export var min_scale: Vector3 = Vector3(0.1,0.1,0.1)

# XR camera and controller ray
@onready var xr_camera: XRCamera3D = get_parent().get_node("XRCamera3D")
@onready var ray: RayCast3D = get_parent().get_node("RightController/RightControllerRay")

var ghost_instance: Node3D = null

func _ready() -> void:
	# Enable XR rendering
	get_viewport().use_xr = true
	xr_camera.current = true

	# Initialize OpenXR
	var xr: XRInterface = XRServer.find_interface("OpenXR")
	if not xr:
		push_error("OpenXR interface not found! Make sure the plugin is active.")
		return
	XRServer.primary_interface = xr
	xr.initialize()  # Tracking is automatic in Godot 4

	# Spawn ghost object
	spawn_ghost()

	# Quick test cube to ensure visibility
	var test_cube = MeshInstance3D.new()
	test_cube.mesh = BoxMesh.new()
	test_cube.global_transform.origin = Vector3(0, 1.5, -2)
	get_parent().add_child(test_cube)

func _process(delta: float) -> void:
	if not ghost_instance or not ray:
		return

	if ray.is_colliding():
		var pos: Vector3 = ray.get_collision_point()
		pos.x = snappedf(pos.x, grid_snap)
		pos.z = snappedf(pos.z, grid_snap)
		ghost_instance.global_transform.origin = pos

	# Place object
	if Input.is_action_just_pressed("place"):
		_place_selected()

	# Rotate ghost
	if Input.is_action_pressed("rotate_left"):
		ghost_instance.rotate_y(deg_to_rad(-rotation_speed_deg) * delta)
	if Input.is_action_pressed("rotate_right"):
		ghost_instance.rotate_y(deg_to_rad(rotation_speed_deg) * delta)

	# Scale ghost
	if Input.is_action_pressed("scale_up"):
		ghost_instance.scale += Vector3.ONE * scale_speed * delta
	if Input.is_action_pressed("scale_down"):
		ghost_instance.scale -= Vector3.ONE * scale_speed * delta
		ghost_instance.scale = ghost_instance.scale.max(min_scale)

func spawn_ghost() -> void:
	_clear_ghost()
	if not placement_scene:
		push_warning("No scene assigned for placement.")
		return
	ghost_instance = placement_scene.instantiate()
	_set_transparency(ghost_instance, 0.5)
	add_child(ghost_instance)

func _place_selected() -> void:
	if not ghost_instance:
		return
	var real_instance: Node3D = ghost_instance.duplicate()
	_set_transparency(real_instance, 0.0)
	get_parent().add_child(real_instance)
	real_instance.owner = get_tree().edited_scene_root

func _clear_ghost() -> void:
	if ghost_instance and is_instance_valid(ghost_instance):
		ghost_instance.queue_free()
	ghost_instance = null

func _set_transparency(node: Node, alpha: float) -> void:
	if node is GeometryInstance3D:
		var geo: GeometryInstance3D = node
		for i in range(geo.get_surface_override_material_count()):
			var mat: Material = geo.get_active_material(i)
			if mat and mat is StandardMaterial3D:
				mat = mat.duplicate()
				mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA if alpha < 1.0 else BaseMaterial3D.TRANSPARENCY_DISABLED
				var c: Color = mat.albedo_color
				c.a = clamp(alpha, 0.0, 1.0)
				mat.albedo_color = c
				geo.set_surface_override_material(i, mat)
	for child in node.get_children():
		_set_transparency(child, alpha)
