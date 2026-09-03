extends Node
## Autoload — ตั้งชื่อ "RecipeDB" ใน Project Settings > Autoload
##
## Was previously a runtime DirAccess scan of resources/Recipes/ — switched
## to explicit preload() (same fix already applied to CropDB/ToolDB) because
## runtime directory-listing of res:// is fragile across exported builds —
## it works in the editor but returns nothing in the exported web build,
## which is why the craft menu showed empty with no recipes.
##
## Add a new recipe: add its .tres path to RECIPE_RESOURCES below.

const RECIPE_RESOURCES: Array[Recipe] = [
	preload("res://resources/Recipes/bread.tres"),
	preload("res://resources/Recipes/flour.tres"),
	preload("res://resources/Recipes/milk.tres"),
	preload("res://resources/Recipes/soup.tres"),
]

var recipes: Array[Recipe] = []

func _ready() -> void:
	_load_all_recipes()

func _load_all_recipes() -> void:
	for r in RECIPE_RESOURCES:
		recipes.append(r)

func get_recipe(recipe_id: String) -> Recipe:
	for r in recipes:
		if r.recipe_id == recipe_id:
			return r
	return null

func get_recipes_by_category(category: String) -> Array[Recipe]:
	return recipes.filter(func(r): return r.category == category)

func get_all_categories() -> Array[String]:
	var cats: Array[String] = []
	for r in recipes:
		if not cats.has(r.category):
			cats.append(r.category)
	return cats
