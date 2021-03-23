if SERVER then
    util.AddNetworkString( "PsychedelicsDeath" )
    --Hooks
    hook.Add("PlayerDeath","PsychedelicsDeath",function(ply)
        net.Start("PsychedelicsDeath")
        net.WriteEntity(ply)
        net.Send(ply)
    end)
    hook.Add("PlayerSilentDeath","PsychedelicsDeath",function(ply)
        net.Start("PsychedelicsDeath")
        net.WriteEntity(ply)
        net.Send(ply)
    end)
    --Resources
    resource.AddFile("materials/psychedelics/lsd_dx80.vmt")
    resource.AddFile("materials/psychedelics/lsd_bg.vmt")
    resource.AddFile("materials/psychedelics/textures/lsd_bg.vtf")
    resource.AddFile("materials/psychedelics/lsd.vmt")
    --ConVars
    CreateConVar("psychedelics_limitspawn_25sheet",2,FCVAR_ARCHIVE,"Limits how much of the 25sheet entity can be spawn by using the blotter_sheet")
    CreateConVar("psychedelics_limitspawn_5sheet",8,FCVAR_ARCHIVE,"Limits how much of the 5sheet entity can be spawn by using the blotter_25sheet")
    CreateConVar("psychedelics_limitspawn_1sheet",5,FCVAR_ARCHIVE,"Limits how much of the 1sheet entity can be spawn by using the blotter_5sheet")
    local function UpdateSavedBlotter( ply, ent, ddata )
        ent:SetNWString("psychedelics_blotter_data",ddata.data)
        ent:SetNWInt("matpos",ddata.matpos)
        ent:SetNWInt("psychedelics_quantity",ddata.quantity)
        ent:SetNWString("psychedelics_type",ddata.type) 
    end
    duplicator.RegisterEntityModifier( "sdrugs_blotter_data", UpdateSavedBlotter  )
end

if CLIENT then
    CreateConVar("psychedelics_tips",1,FCVAR_ARCHIVE,"Enable or disable the tips in entities")
end