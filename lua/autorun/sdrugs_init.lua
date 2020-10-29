if SERVER then
 util.AddNetworkString( "SDrugsDeath" )


 hook.Add("PlayerDeath","SDrugsDeath",function(ply)
  net.Start("SDrugsDeath")
  net.WriteEntity(ply)
  net.Send(ply)
 end)

 hook.Add("PlayerSilentDeath","SDrugsDeath",function(ply)
  net.Start("SDrugsDeath")
  net.WriteEntity(ply)
  net.Send(ply)
 end)
 --Resources
 resource.AddFile("materials/sdrugs/lsd_dx80.vmt")
 resource.AddFile("materials/sdrugs/lsd_bg.vmt")
 resource.AddFile("materials/sdrugs/textures/lsd_bg.vtf")
 resource.AddFile("materials/sdrugs/lsd.vmt")

 CreateConVar("sdrugs_limitspawn_25sheet",2,FCVAR_ARCHIVE,"Limits how much of the 25sheet entity can be spawn by using the blotter_sheet")
 CreateConVar("sdrugs_limitspawn_5sheet",8,FCVAR_ARCHIVE,"Limits how much of the 5sheet entity can be spawn by using the blotter_25sheet")
 CreateConVar("sdrugs_limitspawn_1sheet",5,FCVAR_ARCHIVE,"Limits how much of the 1sheet entity can be spawn by using the blotter_5sheet")

end

if SERVER then
 local function UpdateSavedBlotter( ply, ent, ddata )
  ent:SetNWString("SDrugs_blotter_data",ddata.data)
  ent:SetNWInt("matpos",ddata.matpos)
  ent:SetNWInt("SDrugs_quantity",ddata.quantity)
  ent:SetNWString("SDrugs_type",ddata.type) 
 end
 duplicator.RegisterEntityModifier( "sdrugs_blotter_data", UpdateSavedBlotter  )
end