extends Node

## Autoload singleton: CraftManager
## Add as Autoload named "Craft" in Project Settings (see setup notes below).
## Usage: Craft.make_recipe(bread_recipe)  -- pass a loaded Recipe resource

signal crafted(recipe_id: String, amount: int)
signal craft_failed(recipe_id: String, missing_item: String)


func can_craft(recipe: Recipe) -> bool:
	for entry in recipe.ingredients:
		if not Inventory.has_item(entry.item_id, entry.amount):
			return false
	return true


func make_recipe(recipe: Recipe) -> bool:
	# Check everything first so we never partially consume ingredients.
	for entry in recipe.ingredients:
		if not Inventory.has_item(entry.item_id, entry.amount):
			craft_failed.emit(recipe.recipe_id, entry.item_id)
			return false

	for entry in recipe.ingredients:
		Inventory.remove_item(entry.item_id, entry.amount)

	Inventory.add_item(recipe.recipe_id, recipe.result_amount)
	crafted.emit(recipe.recipe_id, recipe.result_amount)
	return true
