AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( 'shared.lua' )
include('round.lua')

--include ("player_class.lua")
CreateClientConVar("developer", 2, true, true)



function GM:PlayerSpawn( ply )
    --self.BaseClass:PlayerSpawn( ply )

    if (numplayers() < 2 or round.InProgress) then
      GAMEMODE:PlayerSpawnAsSpectator(ply)
    else
      if (!round.Started) then
        round.Started = true
        round.Begin()
      end
      ply:SetGravity  ( 1 )
      ply:SetMaxHealth( 10, true )

      ply:SetWalkSpeed( 200 )
      ply:SetRunSpeed ( 400 )
      --player_manager.SetPlayerClass( ply, "player_custom" )
      ply:Give( "sinkshotty" )
      ply:Give("homerun")
      ply:Give("forcesnipe")
      ply:Give("rocketlawnchair")
      --ply:KillSilent()
    end

end

function GM:PlayerLoadout( ply )
end

function GM:PlayerInitialSpawn( ply )
	   ply:PrintMessage( HUD_PRINTTALK, "Welcome, " .. ply:Name() .. "!" )
end

function GM:EntityTakeDamage(target, dmg)
  if(target:IsPlayer()) then
    if (dmg:GetDamageType() ~= 16384) then
      dmg:ScaleDamage( 0 )

    else
      dmg:ScaleDamage( 1 )
    end
    --target:TakeDamageInfo(dmg)
  end
end
--[[
function GM:PlayerDeathThink(ply)
  return true
end
]]
function numplayers()
  local numplayers = 0;
  for k, v in pairs(player.GetAll()) do
    numplayers = numplayers + 1
  end
  return numplayers
end

function GM:IsSpawnpointSuitable(ply, spwn, force, rigged)
   if not IsValid(ply) then return true end
   if not rigged and (not IsValid(spwn) or not spwn:IsInWorld()) then return false end

   -- spwn is normally an ent, but we sometimes use a vector for jury rigged
   -- positions
   local pos = rigged and spwn or spwn:GetPos()

   if not util.IsInWorld(pos) then return false end

   local blocking = ents.FindInBox(pos + Vector( -16, -16, 0 ), pos + Vector( 16, 16, 64 ))

   for k, p in pairs(blocking) do
      if IsValid(p) and p:IsPlayer() and p:Alive() then
         if force then
            p:Kill()
         else
            return false
         end
      end
   end

   return true
end
--[[
spawnArray = {}
function GM:PlayerSelectSpawn( pl )

	local spawns = ents.FindByClass( "info_player_start" )
	local random_entry = math.random( #spawns )
  for a,b in pairs(spawnArray) do
    if b = random_entry then
    end
    table.insert(spawnArray, random_entry)
  end

	return spawns[ random_entry ]

end
]]




--[[
function GM:ShouldCollide( ent1, ent2 )

	-- If players are about to collide with each other, then they won't collide.
	if ( IsValid( ent1 ) and IsValid( ent2 ))  then
    console.log(ent1)
    return true
  end


	-- We must call this because anything else should return true.
	return true

end
]]
