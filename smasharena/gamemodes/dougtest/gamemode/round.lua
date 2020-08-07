AddCSLuaFile()
if (!SERVER) then return end
round = {}

-- Variables
round.Break	= 5	-- 10 second breaks

-- Read Variables
round.InProgress = false
round.Breaking = false
round.Started = false

function round.Broadcast(Text)
	for k, v in pairs(player.GetAll()) do
		v:ConCommand("play buttons/button17.wav")
		v:ChatPrint(Text)
	end
end

function round.Begin()
	-- Your code
	-- (Anything that may need to happen when the round begins)
	round.InProgress = false
  RunConsoleCommand("gmod_admin_cleanup")
  spawnAllPlayers()
	round.Broadcast("Round starting!")
	round.InProgress = true
end

function round.End()
	-- Your code
	-- (Anything that may need to happen when the round ends)
  if (getNumAlivePlayers() > 0) then
	   round.Broadcast(getNumAlivePlayer():Nick().." wins! Next round in " .. round.Break .. " seconds!")
  else
     round.Broadcast("You All Lose! Next round in " .. round.Break .. " seconds!")
  end
end

function round.Handle()

	if (getNumAlivePlayers() < 2 and round.Started) then
    --print(getNumAlivePlayer())
		if (round.Breaking) then
			print("Breaking")
      if(round.Break == 0) then
				print("Done Breaking")
        round.Begin()
  			round.Breaking = false
        round.Break = 5
      else
				print("numbering down")
        print(round.Break)
        round.Break = round.Break - 1
				print(round.Break)
      end

		else
			print("Round Over")
			round.End()
			round.Breaking = true
		end
	end
end

timer.Create("round.Handle", 1, 0, round.Handle)


function getNumAlivePlayers()
	local count = 0

	for k, v in pairs( player.GetAll() ) do
		if( v:Alive() && v:Health() > 0 && v:GetObserverMode()==0)then
			count = count + 1
		end
	end

	return count
end

function getNumAlivePlayer()
   local alivePlayer

 	for k, v in pairs( player.GetAll() ) do
 		if( v:Alive() && v:Health() > 0  && v:GetObserverMode()==0 )then
 			alivePlayer = v
 		end
 	end

 	return alivePlayer
 end

function spawnAllPlayers()
  for k, v in pairs( player.GetAll() ) do
   v:KillSilent()
   v:UnSpectate()
   v:Spawn()
 end
end

function numplayers()
  local numplayers = 0;
  for k, v in pairs(player.GetAll()) do
    numplayers = numplayers + 1
  end
  return numplayers
end
