extends Resource
class_name CropData

## Create one .tres resource per crop in resources/Crops/
## e.g. carrot.tres, tomato.tres — set these fields in the Inspector.

@export var crop_id: String 
@export var days_to_grow: int 
@export var harvest_yield: int 
@export var stage_textures: Array[Texture2D]   # index 0 = just planted, last = ready to harvest
@export var sell_price: int 
@export var icon : Texture2D
## Per-crop render scale for the in-field sprite (both stage_textures and
## icon fallback). Each artist's art can be a different native resolution,
## so this lives here instead of one global scale in FarmManager.
## 0.0 = AUTO: FarmManager computes scale = tile_size / texture_width per
## the currently-shown texture (Saran's formula), so art at any resolution
## fits the grid automatically without manual tuning. Set a positive value
## here to override auto-scaling for this crop specifically.
@export var display_scale: float = 0.0
