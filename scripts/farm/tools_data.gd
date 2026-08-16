extends Resource
class_name Tools

## Create one .tres resource per recipe in resources/Recipes/
## e.g. bread.tres, soup.tres, cake.tres — set these in the Inspector.
## Matches GDD section 11:
##   hoe = wood*2, stone*1
##
## ingredients is now an Array[IngredientEntry] instead of a raw Dictionary —
## in the Inspector this shows as an expandable list, and each entry is its
## own {item_id, amount} pair, which is easier to review/edit as recipes grow.
##
## efficiency is damage against objects such as tree, rock, ore and etc.
## damage is damage against characters such as monster.

@export var tools_id: String        # matches the resulting item_id in Inventory
@export var ingredients: Array[IngredientEntry] = []
@export var efficiency: int 
@export var damage: int 
@export var sell_price: int 
@export var icon: Texture2D
