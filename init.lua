brazutec_lunocartas = {}

local path = minetest.get_modpath(minetest.get_current_modname())

dofile(path.."/api.lua")
dofile(path.."/chatcommand.lua")
dofile(path.."/item_mailbox.lua")
dofile(path.."/item_papermail.lua")
dofile(path.."/item_brazutec.lua")


minetest.register_on_joinplayer(function(player)
	brazutec_lunocartas.open()
	if player ~= nil and player:is_player() then
		local playername = player:get_player_name()
		if brazutec_lunocartas.players[playername]==nil then
			brazutec_lunocartas.players[playername] = { }
			brazutec_lunocartas.save()
		end
	end
end)
minetest.register_on_leaveplayer(function(player)
	brazutec_lunocartas.save()
end)
minetest.register_on_shutdown(function()
	brazutec_lunocartas.save()
end)

minetest.register_globalstep(function(dtime)
	brazutec_lunocartas.hud_check()
end)

minetest.log('action',"["..minetest.get_current_modname():upper().."] Carregado!")
