if brazutec_lunocartas ==nil then
	brazutec_lunocartas = {}
end

brazutec_lunocartas.mailbox = { }


brazutec_lunocartas.openinbox = function(player, formname)
	if player ~= nil and player:is_player() then
		local playername = player:get_player_name()
		if brazutec_lunocartas.mailbox[playername]==nil or 
			brazutec_lunocartas.mailbox[playername].selmail == nil or 
			type(brazutec_lunocartas.mailbox[playername].selmail)~="number" or 
			brazutec_lunocartas.mailbox[playername].selmail<0 
		then
			brazutec_lunocartas.mailbox[playername] = { }
			brazutec_lunocartas.mailbox[playername].selmail = 0
		end
		
		local formspecmails = brazutec_lunocartas.get_formspecmails(playername)
		--print("formspecmails = "..formspecmails)
		local formspec = "size[12,9]"
		.."bgcolor[#080808BB;true]"
		.."image[0,0;15,10;brazutec_desktop.png]"
		.."label[0.5,0.6;CAIXA DE MENSAGENS]"
		.."button[1.5,7.5;1.5,0.5;closer;VOLTAR]"
		.."button[3.0,7.5;1.5,0.5;openmail;ABRIR]"
		.."button[4.5,7.5;1.5,0.5;delmail;EXCLUIR]"
		.."button[6.0,7.5;1.5,0.5;clearmails;LIMPAR]"
		.."textlist[0.5,1;11,6;selmail;"..formspecmails..";"..brazutec_lunocartas.mailbox[playername].selmail..";false]"
		
		minetest.show_formspec(player:get_player_name(), formname, formspec)
	end
end

brazutec_lunocartas.openmail = function(player, mailnumber, formname)
	if player ~= nil and player:is_player() then
		local playername = player:get_player_name()
		local mail = brazutec_lunocartas.get_mail(playername, mailnumber)
		if mail~=nil then
			--local formspecmails = brazutec_lunocartas.get_formspecmails(playername)
			--print("formspecmails = "..formspecmails)
			--print("mail = "..dump(mail))
			local formspec = "size[12,9]"
			--.."label[2.75,0;MENSAGEM DE: "..mail.namefrom.."]"
			.."bgcolor[#080808BB;true]"
			.."image[0,0;15,10;brazutec_desktop.png]"
			.."label[1.2,0.5;De: "..mail.namefrom.."]"
			.."button[9,2;2,0.5;openinbox;VOLTAR]"
			.."button[9,3.5;2,0.5;delmail;EXCLUIR]"
			.."textarea[1.5,1.5;7.7,7;message;"..
			minetest.formspec_escape(os.date("%Y-%m-%d %Hh:%Mm:%Ss", mail.time))..";"..minetest.formspec_escape(mail.message).."]"
			--.."textlist[0,0.7;15.5,6;selmail;"..formspecmails..";1;false]"
		
			brazutec_lunocartas.set_read(playername, mailnumber, true)
			brazutec_lunocartas.save()
		
			minetest.show_formspec(player:get_player_name(), formname, formspec)
		end
	end
end

minetest.register_on_player_receive_fields(function(sender, formname, fields)
	local sendername = sender:get_player_name()
	--print("fields = "..dump(fields))
	if fields.openinbox then
		--print("brazutec_lunocartas.openinbox("..sendername..","..formname..")")
		brazutec_lunocartas.openinbox(sender, formname)
	elseif fields.selmail then
		local selnum = (fields.selmail):gsub("CHG:", "")
		--print("brazutec_lunocartas.mailbox[sendername].selmail="..dump(brazutec_lunocartas.mailbox[sendername].selmail))
		brazutec_lunocartas.mailbox[sendername].selmail = tonumber(selnum)
	elseif fields.openmail~=nil then
		if brazutec_lunocartas.mailbox[sendername].selmail~=nil and type(brazutec_lunocartas.mailbox[sendername].selmail)=="number" and brazutec_lunocartas.mailbox[sendername].selmail >=1 then
			--print("brazutec_lunocartas.openmail["..sendername.."].selmail="..dump(brazutec_lunocartas.mailbox[sendername].selmail))
			brazutec_lunocartas.openmail(sender, brazutec_lunocartas.mailbox[sendername].selmail, formname)
		else
			minetest.chat_send_player(sendername, "Selecione a carta que deseja abrir!")
		end
	elseif fields.delmail~=nil then
		if brazutec_lunocartas.mailbox[sendername].selmail~=nil and type(brazutec_lunocartas.mailbox[sendername].selmail)=="number" and brazutec_lunocartas.mailbox[sendername].selmail >=1 then
			--print("brazutec_lunocartas.del_mail("..sendername..", "..brazutec_lunocartas.mailbox[sendername].selmail..")")
			brazutec_lunocartas.del_mail(sendername, brazutec_lunocartas.mailbox[sendername].selmail)
			brazutec_lunocartas.openinbox(sender, formname)
		else
			minetest.chat_send_player(sendername, "Selecione a carta que deseja excluir!")
		end
	elseif fields.clearmails~=nil then
		--print("brazutec_lunocartas.chat_delreadeds("..sendername..")")
		brazutec_lunocartas.chat_delreadeds(sendername)
		brazutec_lunocartas.openinbox(sender, formname)
	end
	if fields.closer then
		--print("formspec = "..formname)
		minetest.show_formspec(sender:get_player_name(), formname, brazutec_laptop.desktop)
	end
end)
