@tool
extends Node2D

@onready var sky :TileMapLayer =$"5_sky"
@onready var shrubs:TileMapLayer=$"2_shrub"
@onready var nav :TileMapLayer =$"2_nav"
@onready var ground:TileMapLayer =$"0_ground"

@export var navReg:NavigationRegion2D
@export var mapsize:Vector2= Vector2i(255, 255)


const gnd =[Vector2i(0,0),Vector2i(1,0)] # Base ground, stones
const gnd_top =[Vector2i(0,0),Vector2i(1,0)] # masks?
const shrub =[Vector2i(0,1)] # ??

const nav_tiles =[Vector2i(0,1)] #Tree_Trunk, ??, ??
const tree =[Vector2i(1,2),Vector2i(2,2),Vector2i(3,2)] # center, corner, side






@export_tool_button("generate") var gen = _generate
@export_range(1, 10, 1) var height := 4:
	set(v):
		height=v
		#_generate()
@export_tool_button("clear map") var clr = _clear

@export var ground_noise: FastNoiseLite:
	set(new_noise):
		ground_noise=new_noise

@export var variance_noise: FastNoiseLite:
	set(new_noise):
		variance_noise=new_noise




func _clear():
	sky.clear()
	nav.clear()
	ground.clear()
	print("clear!")
	
func _generate():
	var texture = NoiseTexture2D.new()
	texture.noise = ground_noise
	await texture.changed
	var noiseImage_ground = texture.get_image()
	texture = NoiseTexture2D.new()
	texture.noise = variance_noise
	await texture.changed
	var noiseImage_variance = texture.get_image()
	
	for i in mapsize.x:
		for j in mapsize.y:
			var value:int = noiseImage_ground.get_pixel(i,j).r * height
			var location=Vector2i(i,j)
			
			if value==1:
				ground.set_cell(location, 1, gnd[1]) #add rocks
			else:
				ground.set_cell(location, 1, gnd[0])
				
			if value==3:
				create_tree(location)
				
			if value==0:
				nav.set_cell(location, 1, Vector2i(3,1))
		
		
	
	
	#_gen_navpoly()
	
func _gen_navpoly():
	## Probably should change how the pathfinding map is mande
	var used_rect = ground.get_used_rect()
	#Outer corners	
	var corner_a:Vector2 = ground.map_to_local(Vector2i(0,0))
	
	var corner_c:Vector2 = ground.map_to_local(used_rect.size)
	
	# Far corners
	var corner_b:Vector2 = Vector2(corner_c.x, corner_a.y) #inverse
	var corner_d:Vector2 = Vector2(corner_a.x, corner_c.y) #inverse
	print(corner_a)
	print(corner_b)
	print(corner_c)
	print(corner_d)
	var bounding_outline = PackedVector2Array([corner_a, corner_b, corner_c, corner_d])

	var nav_poly = NavigationPolygon.new()
	nav_poly.add_outline(bounding_outline)
	nav_poly.source_geometry_group_name="navigation"
	nav_poly.source_geometry_mode=2

	navReg.navigation_polygon = nav_poly
	


	

	
func create_tree( location:Vector2i):
	var x=location.x
	var y=location.y
	#Trunk
	nav.set_cell(location,1 ,nav_tiles[0])
	#Center of leavage
	sky.set_cell(location,1 ,tree[0])
	sky.set_cell(Vector2i(x,y+1),1 ,tree[0])	
	sky.set_cell(Vector2i(x,y-1),1 ,tree[0])
	sky.set_cell(Vector2i(x+1,y),1 ,tree[0])	
	sky.set_cell(Vector2i(x-1,y),1 ,tree[0])	
	
	##Large tree, need rotation for corners :weary:
	#leavage 
	#sky.set_cell(Vector2i(x-1,y-1),1, tree[2])
	#sky.set_cell(Vector2i(x-1,y+1),1, tree[2])
	#sky.get_cell_tile_data(Vector2i(x-1,y+1)).tile_data_bl.set_flip_v(false) <- rotate not working...
	#sky.set_cell(Vector2i(x+1,y-1),1 ,Vector2i(tree[2],0))
	#sky.set_cell(Vector2i(x+1,y+1),1 ,Vector2i(tree[2],0))
	
	# Edge of middle
	#sky.set_cell(Vector2i(x,y+2),1 ,Vector2i(tree[3],0))	
	#sky.set_cell(Vector2i(x,y-2),1 ,Vector2i(tree[3],0))		
	#sky.set_cell(Vector2i(x+2,y),1 ,Vector2i(tree[3],0))	
	#sky.set_cell(Vector2i(x-2,y),1 ,Vector2i(tree[3],0))	
	
	
	
func _enter_tree():
	pass

func _ready():
	pass
