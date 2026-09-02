extends Control

@export var category_tabs: HBoxContainer
@export var recipe_list: VBoxContainer
@export var detail_icon: TextureRect
@export var detail_name: Label
@export var detail_desc: Label
@export var ingredients_box: VBoxContainer
@export var craft_button: Button

var current_category: String = "food"
var selected_recipe: Recipe = null

const RECIPE_ROW_SCENE := preload("res://scenes/UI/recipe_row.tscn")
const INGREDIENT_ROW_SCENE := preload("res://scenes/UI/ingredient_row.tscn")


func _ready() -> void:
	visible = false
	add_to_group("craft_menu")
	craft_button.pressed.connect(_on_craft_pressed)
	Craft.crafted.connect(_on_crafted)
	Craft.craft_failed.connect(_on_craft_failed)

	# เพิ่มตรงนี้ — ทำให้ label ในแผงรายละเอียดใหญ่เด่นกว่าลิสต์ซ้าย
	detail_name.add_theme_font_size_override("font_size", 36)
	detail_desc.add_theme_font_size_override("font_size", 20)
	craft_button.add_theme_font_size_override("font_size", 26)

	_build_category_tabs()
	_refresh_recipe_list()


func toggle_menu() -> void:
	if visible:
		close_menu()
	else:
		open_menu()


func open_menu() -> void:
	visible = true
	_refresh_recipe_list()


func close_menu() -> void:
	visible = false


func _build_category_tabs() -> void:
	for child in category_tabs.get_children():
		child.queue_free()

	for cat in RecipeDB.get_all_categories():
		var btn := Button.new()
		btn.text = cat.capitalize()
		btn.toggle_mode = true
		btn.button_pressed = (cat == current_category)
		btn.custom_minimum_size = Vector2(100, 36)   # เพิ่มบรรทัดนี้
		btn.pressed.connect(_on_category_selected.bind(cat))
		category_tabs.add_child(btn)


func _on_category_selected(cat: String) -> void:
	current_category = cat
	for btn in category_tabs.get_children():
		btn.button_pressed = (btn.text == cat.capitalize())
	_refresh_recipe_list()


func _refresh_recipe_list() -> void:
	for child in recipe_list.get_children():
		child.queue_free()

	var recipes: Array[Recipe] = RecipeDB.get_recipes_by_category(current_category)
	for recipe in recipes:
		var row := RECIPE_ROW_SCENE.instantiate()
		row.setup(recipe)
		row.pressed.connect(_on_recipe_selected.bind(recipe))
		recipe_list.add_child(row)

	if recipes.size() > 0:
		_on_recipe_selected(recipes[0])
	else:
		selected_recipe = null
		_clear_detail_panel()


func _on_recipe_selected(recipe: Recipe) -> void:
	selected_recipe = recipe
	detail_icon.texture = recipe.icon
	detail_name.text = recipe.display_name if recipe.display_name != "" else recipe.recipe_id.capitalize()
	detail_desc.text = recipe.description

	for child in ingredients_box.get_children():
		child.queue_free()

	for entry in recipe.ingredients:
		var have: int = Inventory.get_amount(entry.item_id) 
		var row := INGREDIENT_ROW_SCENE.instantiate()
		row.setup(entry.item_id, have, entry.amount)
		ingredients_box.add_child(row)

	craft_button.disabled = not Craft.can_craft(recipe)


func _clear_detail_panel() -> void:
	detail_icon.texture = null
	detail_name.text = ""
	detail_desc.text = ""
	for child in ingredients_box.get_children():
		child.queue_free()
	craft_button.disabled = true


func _on_craft_pressed() -> void:
	if selected_recipe == null:
		return
	Craft.make_recipe(selected_recipe)


func _on_crafted(_recipe_id: String, _amount: int) -> void:
	if selected_recipe != null:
		_on_recipe_selected(selected_recipe)  # รีเฟรชแผงหลังคราฟสำเร็จ


func _on_craft_failed(_recipe_id: String, _missing_item: String) -> void:
	pass  # TODO: อยากได้ feedback ตรงนี้ไหม เช่น shake ปุ่ม หรือ label สีแดงเตือน
