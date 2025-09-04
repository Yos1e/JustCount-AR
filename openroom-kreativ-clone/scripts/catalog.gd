extends Node

signal category_changed(category_name)
signal item_selected(item_data)

var catalog := {}
var categories := []
var current_category := ""

@onready var category_dropdown := get_tree().root.get_node("Main/UI/Root/CatalogPanel/CategoryDropdown")
@onready var item_list := get_tree().root.get_node("Main/UI/Root/CatalogPanel/ItemList")

func _ready() -> void:
	_load_catalog()
	_populate_ui()
	category_dropdown.item_selected.connect(_on_category_selected)
	item_list.item_selected.connect(_on_item_chosen)

func _load_catalog() -> void:
	var fpath = "res://data/catalog.json"
	if not FileAccess.file_exists(fpath):
		push_warning("catalog.json not found at %s" % fpath)
		return
	var f = FileAccess.open(fpath, FileAccess.READ)
	var text = f.get_as_text()
	f.close()
	var data = JSON.parse_string(text)
	if typeof(data) == TYPE_DICTIONARY:
		catalog = data
		categories = catalog.keys()
		categories.sort()
	else:
		push_error("Invalid JSON in catalog.json")

func _populate_ui() -> void:
	category_dropdown.clear()
	for i in range(categories.size()):
		category_dropdown.add_item(categories[i])
	if categories.size() > 0:
		category_dropdown.select(0)
		_set_category(categories[0])
	else:
		# Provide a default empty "Furniture" category per spec.
		categories = ["Furniture"]
		category_dropdown.add_item("Furniture")
		category_dropdown.select(0)
		_set_category("Furniture")

func _set_category(name: String) -> void:
	current_category = name
	item_list.clear()
	if not catalog.has(name):
		return
	for item in catalog[name]:
		var title := "%s (%.2fm x %.2fm x %.2fm)" % [item.get("name", "Unnamed"),
			item.get("size", Vector3.ZERO).x, item.get("size", Vector3.ZERO).y, item.get("size", Vector3.ZERO).z]
		item_list.add_item(title)

	emit_signal("category_changed", name)

func _on_category_selected(index: int) -> void:
	var name = category_dropdown.get_item_text(index)
	_set_category(name)

func _on_item_chosen(index: int) -> void:
	if not catalog.has(current_category):
		return
	var item = catalog[current_category][index]
	emit_signal("item_selected", item)
