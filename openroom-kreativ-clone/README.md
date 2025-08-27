# OpenRoom – Godot 4 AR Room Designer (Feature-Parity Template)

> Clean-room template inspired by the *features* of IKEA Kreativ. No IKEA assets, branding, or proprietary code are used.
> Furniture catalog is intentionally left **empty** per spec; instructions below show how to add your own.

## What you get
- ✅ **Import a room scan** (pipeline-ready): drop your LiDAR/photogrammetry `.glb/.obj` scans into `res://assets/showrooms/` and load at runtime (see TODO in UI).
- ✅ **Place/rotate/scale items** on surfaces with grid snapping.
- ✅ **Manual "erase" via occluder boxes** to hide unwanted real-world geometry in the scan (depth-occlusion shader hook included as a TODO).
- ✅ **Measure tool** for rough distances in meters.
- ✅ **Showrooms** (virtual rooms) loader stub via `data/showrooms.json`.
- ✅ **Screenshot + save/load** scene state to `user://design.json`.
- ✅ **AR-ready architecture**: add Godot XR plugins (ARKit/ARCore) to drive anchors & light estimation.

> NOTE: Some features (room scanning, true AI-based object removal, shopping/cart) in IKEA Kreativ are proprietary or platform-specific. This template gives you the hooks to implement equivalents with open tooling.

## Controls (desktop)
- **Left Click**: place the selected item
- **Q/E**: rotate item
- **R/F**: scale item up/down
- **M**: toggle Measure mode
- **O**: toggle Erase (Occluder) mode
- **P**: screenshot
- **Ctrl+S / Ctrl+L**: save/load

## Project layout
```
res://
  project.godot
  scenes/
	Main.tscn        # world root
	UI.tscn          # minimal UI
  scripts/
	catalog.gd       # loads JSON catalog, emits selection
	placement.gd     # preview ghost + placement logic
	measure_tool.gd  # distance line
	occluder_tool.gd # "erase" boxes (depth-occlusion shader hook TODO)
	save_load.gd     # save/load, screenshots, showroom/scan stubs
  assets/
	furniture/       # put your .glb models here
	showrooms/       # put room shells / scans here
  data/
	catalog.json     # empty furniture category (by request)
	showrooms.json   # list of available showroom shells
```

## How to add furniture (catalog is blank on purpose)
1. Export or download a **GLB** model (real-world scale, meters).
2. Place it in `res://assets/furniture/your_item.glb`.
3. Open `res://data/catalog.json` and add an entry under `"Furniture"`:

```json
{
  "id": "chair_demo_01",
  "name": "Demo Chair",
  "model_path": "res://assets/furniture/chair_demo.glb",
  "size": [0.45, 0.9, 0.45],
  "tags": ["chair", "dining"]
}
```

4. Relaunch the project. Select the item from the **Catalog** panel and click to place.
5. (Optional) Create material variants by referencing `.tres` StandardMaterial3D resources.

## Room scans (how-to)
- **iOS LiDAR / RoomPlan**: Export as USDZ/OBJ → convert to GLB (Blender) → drop into `assets/showrooms/`.
- **Photogrammetry** (RealityCapture, Polycam, KIRI, etc.): Export GLB directly → drop into `assets/showrooms/`.
- In runtime, use the **Load Showroom** button (currently prints TODO) to load from `data/showrooms.json`.

## "Erase existing furniture" (manual occluders)
This template places **semi-transparent occluder boxes** that visually cover undesired mesh areas.
For proper **depth-only occlusion** (in AR), implement a small spatial shader that writes depth but no color, and enable depth testing. Hook it up in `occluder_tool.gd`.

## AR mode (Godot XR)
- Add the official **ARKit** / **ARCore** / **OpenXR** plugins to enable plane detection & anchors.
- Replace `Camera3D` with an XR camera and feed plane hits into `Placement`.
- (Optional) Use **light estimation** to match item materials to real lighting.

## Legal note
- This project **does not** include IKEA assets, logos, UI, copy, or code. It is a clean-room **feature template** only.
- Rename anything you like and ship under your own branding. MIT license included.

## Next steps / TODO hooks
- Runtime GLB/OBJ loader dialog
- Showroom selector UI from `showrooms.json`
- Proper depth-only occlusion shader for erasing
- Physics-based placement (wall snapping, hanging)
- Multi-item selection & group transforms
- Share/export: PNG + JSON bundle
