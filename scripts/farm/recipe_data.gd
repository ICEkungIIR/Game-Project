extends Resource
class_name Recipe

## Create one .tres resource per recipe in resources/Recipes/
## e.g. bread.tres, soup.tres, cake.tres — set these in the Inspector.
## Matches GDD section 11:
##   Bread = Flour x2
##   Soup  = Carrot x1, Milk x1
##   Cake  = Flour x2, Egg x1, Honey x1
##
## ingredients is now an Array[IngredientEntry] instead of a raw Dictionary —
## in the Inspector this shows as an expandable list, and each entry is its
## own {item_id, amount} pair, which is easier to review/edit as recipes grow.

@export var recipe_id: String = "bread"        # matches the resulting item_id in Inventory
@export var ingredients: Array[IngredientEntry] = []
@export var result_amount: int = 1
@export var sell_price: int = 15
@export var icon: Texture2D
