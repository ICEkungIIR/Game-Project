extends Resource
class_name CropData

## Create one .tres resource per crop in resources/Crops/
## e.g. carrot.tres, tomato.tres — set these fields in the Inspector.

@export var crop_id: String 
@export var days_to_grow: int 
@export var harvest_yield: int 
@export var stage_textures: Array[Texture2D]   # index 0 = just planted, last = ready to harvest
@export var sell_price: int 
