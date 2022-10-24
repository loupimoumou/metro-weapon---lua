
givelight_cv = CreateConVar( "sv_givelight", "1", { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_DONTRECORD, FCVAR_SERVER_CAN_EXECUTE }, "Toggles spawing with the flashlight." )

shl_convar = CreateConVar( "sv_shoulderlight", "0", { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_DONTRECORD, FCVAR_SERVER_CAN_EXECUTE }, "Toggles drawing the flashlight on pressing the flashlight bind." )

CreateClientConVar( "cl_flashlight_texture", "effects/flashlight001", true, true, "Path to flashlight texture, set in the options menu." )
CreateClientConVar( "cl_flashlight_r", "255", true, true, "0-255 Flashlight color's red component, set in the options menu." )
CreateClientConVar( "cl_flashlight_g", "255", true, true, "0-255 Flashlight color's green component, set in the options menu." )
CreateClientConVar( "cl_flashlight_b", "255", true, true, "0-255 Flashlight color's blue component, set in the options menu." )
CreateClientConVar( "cl_flashlight_allow_refresh", "0", true, true, "Toggles allowing refresh of the flashlight with reload." )

-- Since people have had trouble with stuck flashlight spots
-- and I've failed to eliminate the problem so far, I'm adding
-- this as a temporary workaround.
cleanup.Register( "flspot" )

local function GiveLight( ply )
local gvlight = givelight_cv:GetBool()
if ( gvlight ) then
	ply:Give("weapon_flashlight")
end
end
hook.Add( "PlayerLoadout", "FlashlighLoadout", GiveLight)

local function FlashlightBind( ply, ucmd )
	local shld = shl_convar:GetBool()
	if ( shld || ply:InVehicle() == true ) then return end
	if ( ucmd:GetImpulse() == 100 ) then
		if ( ply:GetActiveWeapon():GetClass() == "weapon_flashlight" ) then
			ucmd:SetImpulse( 0 )
			RunConsoleCommand( "lastinv" )
		else
			ucmd:SetImpulse( 0 )
			RunConsoleCommand( "use", "weapon_flashlight" )
		end
	end
end
hook.Add( "StartCommand", "SWEP FlashlightBind", FlashlightBind )

if (CLIENT) then

local function LightOptions( CPanel )

	-- HEADER
	CPanel:AddControl( "Header", { Description = "Server Settings" }  )

	CPanel:AddControl( "Checkbox", { Label = "Spawn With Flashlight", Command = "sv_givelight" } )

	CPanel:AddControl( "Checkbox", { Label = "Use Engine Flashlight on Bind Press", Command = "sv_shoulderlight" } )
	
	CPanel:AddControl( "Header", { Description = "Client Settings" }  )
	
	CPanel:AddControl( "Checkbox", { Label = "Refresh Light on Reload", Command = "cl_flashlight_allow_refresh" } )

	local MatSelect = CPanel:MatSelect( "cl_flashlight_texture", nil, true, 0.33, 0.33 )
	
	for k, v in pairs( list.Get( "FlashlightTextures" ) ) do
		MatSelect:AddMaterial( v.Name or k, k )
	end
	
	CPanel:AddControl( "Color",  { Label	= "Flashlight Color",
									Red			= "cl_flashlight_r",
									Green		= "cl_flashlight_g",
									Blue		= "cl_flashlight_b",
									ShowAlpha	= 0,
									ShowHSV		= 1,
									ShowRGB 	= 1,
									Multiplier	= 255 } )	
end

hook.Add( "PopulateToolMenu", "AddFLMenu", function()
	spawnmenu.AddToolMenuOption( "Options", "Flashlight", "FlashlightSettings", "Settings", "", "", LightOptions )
end )

language.Add( "cleanup_flspot", "Flashlight Spots" )
language.Add( "cleaned_flspot", "Removed Flashlight Spots" )

end

list.Set( "FlashlightTextures", "effects/flashlight001", { Name = "Default" } )
list.Set( "FlashlightTextures", "effects/flashlight/flashlight001_l4d2", { Name = "Left 4 Dead" } )
list.Set( "FlashlightTextures", "effects/flashlight/flashlight001_improved_fix", { Name = "Global Offensive Improved" } )
list.Set( "FlashlightTextures", "effects/flashlight/flashlight_security001", { Name = "Global Offensive Security" } )
list.Set( "FlashlightTextures", "effects/flashlight/flashlight_trinity", { Name = "Trinity Renderer" } )
list.Set( "FlashlightTextures", "effects/flashlight/flashlight001_ronster", { Name = "Ronster's Flashlight" } )
list.Set( "FlashlightTextures", "effects/flashlight/flashlight_horrible", { Name = "Horrible Flashlight" } )
list.Set( "FlashlightTextures", "effects/flashlight/flashlight_led", { Name = "LED Flashlight" } )
