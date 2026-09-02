extends Node
## Autoload — ตั้งชื่อ "RecipeDB" ใน Project Settings > Autoload

const RECIPE_FOLDER := "res://resources/Recipes/"

var recipes: Array[Recipe] = []

func _ready() -> void:
	_load_all_recipes()

func _load_all_recipes() -> void:
	var dir := DirAccess.open(RECIPE_FOLDER)
	if dir == null:
		push_warning("RecipeDB: ไม่พบโฟลเดอร์ %s" % RECIPE_FOLDER)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var res := load(RECIPE_FOLDER + file_name)
			if res is Recipe:
				recipes.append(res)
		file_name = dir.get_next()
	dir.list_dir_end()

func get_recipes_by_category(category: String) -> Array[Recipe]:
	return recipes.filter(func(r): return r.category == category)

func get_all_categories() -> Array[String]:
	var cats: Array[String] = []
	for r in recipes:
		if not cats.has(r.category):
			cats.append(r.category)
	return cats
