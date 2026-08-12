extends Resource
class_name IngredientEntry

## One ingredient line inside a Recipe's `ingredients` array.
## Shows as an expandable list item in the Inspector instead of a raw Dictionary.

@export var item_id: String = ""   # must match an Inventory item_id, e.g. "carrot"
@export var amount: int = 1
