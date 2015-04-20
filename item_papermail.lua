
brazutec_lunocartas.openpapermail = function(itemstack, player)
	if player ~= nil and player:is_player() then
		local playername = player:get_player_name()
		if brazutec_lunocartas.mailbox[playername]==nil then
			brazutec_lunocartas.mailbox[playername] = { }
			brazutec_lunocartas.mailbox[playername].selmail = 0
		end
		
		local formspecmails = brazutec_lunocartas.get_formspecmails(playername)
		--print("formspecmails = "..formspecmails)
		local formspec = "size[8,7.5]"
		.."image[2.2,0.0;0.7,0.7;brazutec_obj_mail.png]"
		.."label[2.75,0;CARTA DE CORREIO]"
		--.."textlist[0,0.7;7.7,6;selmail;"..formspecmails..";"..brazutec_lunocartas.mailbox[playername].selmail..";false]"
		.."field[0.5,1.0;7.7,1.0;toplayer;Destinatario:;]"
		.."textarea[0.5,2.0;7.7,5.5;message;Mensagem:;]"
		--.."button[3.5,7;1.5,0.5;sendmail;ENVIAR]"
		.."button_exit[3.5,7;1.5,0.5;sendmail;ENVIAR]"
		
		minetest.show_formspec(player:get_player_name(),"brazutec_lunocartas.mailmessage",formspec)
	end
end

minetest.register_on_player_receive_fields(function(sender, formname, fields)
	if formname == "brazutec_lunocartas.mailmessage"  then
		local sendername = sender:get_player_name()
		print("fields = "..dump(fields))
		if fields.sendmail then
			print("brazutec_lunocartas.openpapermail("..sendername..")")
			if fields.toplayer~=nil and type(fields.toplayer)=="string" and fields.toplayer~="" then
				if fields.message~=nil and type(fields.message)=="string" and fields.message~="" then
					local carta = brazutec_lunocartas.set_mail(sendername, fields.toplayer, fields.message)
					if carta~=nil then
						local itemWielded = sender:get_wielded_item()
						if not minetest.setting_getbool("creative_mode") then
							itemWielded:take_item()
							sender:set_wielded_item(itemWielded)
						end
						--minetest.show_formspec(sendername,"","size[5,1]label[0,0;Sua mensagem foi enviada com sucesso!]") --Infelizmente nao existe metodo para fechar formspec.
						minetest.chat_send_player(sendername, "Sua mensagem foi enviada com sucesso!")
					else
						minetest.chat_send_player(sendername, "Houve uma falha inesperada ao enviar sua mensagem! (Entre em contato dom o desenvolvedor do mod 'brazutec_lunocartas'.)")
					end
				else
					minetest.chat_send_player(sendername, "Favor digite uma mensagem antes de enviar sua carta!")
				end
			else
				minetest.chat_send_player(sendername, "Favor digite o nome exato da pessoa que recebera sua carta!")
			end
		end
	end
end)

minetest.register_craftitem("brazutec_lunocartas:papermail", {
	description = "Carta de Correio",
	inventory_image = "brazutec_obj_mail.png",
	--stack_max=16, --Acumula 16 por slot
	--groups = { eat=1 },
	on_use = function(itemstack, user, pointed_thing)
		--return lunorecipes.doEat(user, itemstack, 2, 4, "obj_chew")
		brazutec_lunocartas.openpapermail(itemstack, user)
	end,
})

minetest.register_craft({
	output = 'brazutec_lunocartas:papermail',
	recipe = {
		{"group:stick"},
		{"dye:violet"},
		{"default:paper"},
	}
})