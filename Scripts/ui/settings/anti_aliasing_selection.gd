extends OptionButton

@onready var vp_rid = get_viewport().get_viewport_rid()


func _ready() -> void:
	mouse_entered.connect(take_focus)
	var video_settings = CfgHandler.load_video_settings()
	
	if "antialiasing" not in video_settings:
		CfgHandler.create_new_preferences_file() 
		video_settings = CfgHandler.load_video_settings()
	
	match video_settings.antialiasing:
		CfgHandler.AntiAliasing.OFF:
			selected = 0
			RenderingServer.viewport_set_use_taa(vp_rid, false)
			RenderingServer.viewport_set_msaa_2d(vp_rid, RenderingServer.VIEWPORT_MSAA_DISABLED)
			RenderingServer.viewport_set_msaa_3d(vp_rid, RenderingServer.VIEWPORT_MSAA_DISABLED)
		CfgHandler.AntiAliasing.TAA:
			selected = 1
			RenderingServer.viewport_set_use_taa(vp_rid, true)
			RenderingServer.viewport_set_msaa_2d(vp_rid, RenderingServer.VIEWPORT_MSAA_DISABLED)
			RenderingServer.viewport_set_msaa_3d(vp_rid, RenderingServer.VIEWPORT_MSAA_DISABLED)
		CfgHandler.AntiAliasing.MSAA2X:
			selected = 2
			RenderingServer.viewport_set_use_taa(vp_rid, false)
			RenderingServer.viewport_set_msaa_2d(vp_rid, RenderingServer.VIEWPORT_MSAA_2X)
			RenderingServer.viewport_set_msaa_3d(vp_rid, RenderingServer.VIEWPORT_MSAA_2X)
		CfgHandler.AntiAliasing.MSAA4X:
			selected = 3
			RenderingServer.viewport_set_use_taa(vp_rid, false)
			RenderingServer.viewport_set_msaa_2d(vp_rid, RenderingServer.VIEWPORT_MSAA_4X)
			RenderingServer.viewport_set_msaa_3d(vp_rid, RenderingServer.VIEWPORT_MSAA_4X)
		CfgHandler.AntiAliasing.MSAA8X:
			selected = 4
			RenderingServer.viewport_set_use_taa(vp_rid, false)
			RenderingServer.viewport_set_msaa_2d(vp_rid, RenderingServer.VIEWPORT_MSAA_8X)
			RenderingServer.viewport_set_msaa_3d(vp_rid, RenderingServer.VIEWPORT_MSAA_8X)




func _on_item_selected(index: int) -> void:
	match index:
		0: 
			RenderingServer.viewport_set_use_taa(vp_rid, false)
			RenderingServer.viewport_set_msaa_2d(vp_rid, RenderingServer.VIEWPORT_MSAA_DISABLED)
			RenderingServer.viewport_set_msaa_3d(vp_rid, RenderingServer.VIEWPORT_MSAA_DISABLED)
			CfgHandler.save_video_setting("antialiasing", CfgHandler.AntiAliasing.OFF)
		1:
			RenderingServer.viewport_set_use_taa(vp_rid, true)
			RenderingServer.viewport_set_msaa_2d(vp_rid, RenderingServer.VIEWPORT_MSAA_DISABLED)
			RenderingServer.viewport_set_msaa_3d(vp_rid, RenderingServer.VIEWPORT_MSAA_DISABLED)
			CfgHandler.save_video_setting("antialiasing", CfgHandler.AntiAliasing.TAA)
		2: 
			RenderingServer.viewport_set_use_taa(vp_rid, false)
			RenderingServer.viewport_set_msaa_2d(vp_rid, RenderingServer.VIEWPORT_MSAA_2X)
			RenderingServer.viewport_set_msaa_3d(vp_rid, RenderingServer.VIEWPORT_MSAA_2X)
			CfgHandler.save_video_setting("antialiasing", CfgHandler.AntiAliasing.MSAA2X)
		3:
			RenderingServer.viewport_set_use_taa(vp_rid, false)
			RenderingServer.viewport_set_msaa_2d(vp_rid, RenderingServer.VIEWPORT_MSAA_4X)
			RenderingServer.viewport_set_msaa_3d(vp_rid, RenderingServer.VIEWPORT_MSAA_4X)
			CfgHandler.save_video_setting("antialiasing", CfgHandler.AntiAliasing.MSAA4X)
		4:
			RenderingServer.viewport_set_use_taa(vp_rid, false)
			RenderingServer.viewport_set_msaa_2d(vp_rid, RenderingServer.VIEWPORT_MSAA_8X)
			RenderingServer.viewport_set_msaa_3d(vp_rid, RenderingServer.VIEWPORT_MSAA_8X)
			CfgHandler.save_video_setting("antialiasing", CfgHandler.AntiAliasing.MSAA8X)


func take_focus() -> void:
	grab_focus()
