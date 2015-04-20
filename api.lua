brazutec_lunocartas.players = { }
brazutec_lunocartas.default_url = minetest.get_worldpath().."/brazutec_lunocartas.tbl"
brazutec_lunocartas.huds = { }
brazutec_lunocartas.hud_time = 0
brazutec_lunocartas.hud_delay = 5 --Padrao = 30

--#####################################################################################################################

minetest.register_privilege("postman", "Jogador pode enviar mensagens diretamente por comando.")

brazutec_lunocartas.save = function(url)
	if url==nil or type(url)~="string" or url=="" then
		url = brazutec_lunocartas.default_url
	end
	local file = io.open(url, "w")
	if file then
		file:write(minetest.serialize(brazutec_lunocartas.players))
		file:close()
		minetest.log("action","[brazutec_lunocartas] Salvando '"..url.."'!!!")
	else
		minetest.log("error","[brazutec_lunocartas] Nao foi possivel salvar em '"..url.."'!!!")
	end
end

brazutec_lunocartas.open = function(url)
	if url==nil or type(url)~="string" or url=="" then
		url = brazutec_lunocartas.default_url
	end
	local file = io.open(url, "r")
	if file~=nil then
		local players = minetest.deserialize(file:read("*all"))
		file:close()
		if type(players) == "table" then
			brazutec_lunocartas.players = players
			minetest.log("action","[brazutec_lunocartas] Abrindo '"..url.."'!!!")
			return true
		else
			minetest.log("error","[brazutec_lunocartas] Nao foi possivel abrir em '"..url.."'!!!")
		end
	end
end

brazutec_lunocartas.set_mail = function(namefrom, nameto, message)
	if namefrom~=nil and type(namefrom)=="string" and namefrom~="" then
		if nameto~=nil and type(nameto)=="string" and nameto~="" then
			if message~=nil and type(message)=="string" and message~="" then
				
				if brazutec_lunocartas.players[namefrom]==nil then
					brazutec_lunocartas.players[namefrom] = { }
				end
				if brazutec_lunocartas.players[nameto]==nil then
					brazutec_lunocartas.players[nameto] = { }
				end
	
				--table.insert(brazutec_lunocartas._handlers,func)
				local tmp = { }
				tmp.namefrom = namefrom
				tmp.message = brazutec_lunocartas.regulechars(message)
				tmp.time = os.time()
				tmp.readed = false
				table.insert(brazutec_lunocartas.players[nameto],tmp)
				brazutec_lunocartas.save()
				return tmp
				
				--[[
				local qtd = #brazutec_lunocartas.players[nameto]
				brazutec_lunocartas.players[nameto][qtd+1] = {}
				brazutec_lunocartas.players[nameto][qtd+1].namefrom = namefrom
				brazutec_lunocartas.players[nameto][qtd+1].message = message
				brazutec_lunocartas.players[nameto][qtd+1].time = os.time()
				brazutec_lunocartas.players[nameto][qtd+1].readed = false
				brazutec_lunocartas.save()
				return brazutec_lunocartas.players[nameto][qtd+1]
				]]--
				
				
	
				
			else
				minetest.log("error","[brazutec_lunocartas.set_mail()] message = "..dump(message))
			end
		else
			minetest.log("error","[brazutec_lunocartas.set_mail()] nameto = "..dump(nameto))
		end
	else
		minetest.log("error","[brazutec_lunocartas.set_mail()] namefrom = "..dump(namefrom))
	end
end

brazutec_lunocartas.chat_writemail = function(name, param) --Usado apenas por comando de chat
	if name~=nil and type(name)=="string" and name~="" then
		if param~=nil and type(param)=="string" and param~="" then
			local to, msg = string.match(param, "([%a%d_]+) (.+)")
			
			if not to or not msg then
				minetest.chat_send_player(name,"/mail <jogador> <mensagem>")
				return false
			end
			
			print("Remetente...: "..name)
			print("Destinatario: "..to)
			print("Mensagem....: "..msg)
			
			
			local result = brazutec_lunocartas.set_mail(name, to, msg)
			if result~=nil then
				minetest.chat_send_player(name,"Sua mensagem foi enviada para '"..to.."'!")
				brazutec_lunocartas.save()
				return true
			else
				minetest.chat_send_player(name,"Ocorreu um erro ao enviar sua mensagem!!!")
			end
		else
			minetest.chat_send_player(name,"/mail <playername> <mensagem>: Envia email para um player.")
		end
	end
	return false
end

brazutec_lunocartas.set_broadcast = function(namefrom, message)
	if brazutec_lunocartas.players[namefrom]==nil then
		brazutec_lunocartas.players[namefrom] = { }
	end

	local contsend = 0
	local players = brazutec_lunocartas.players
	--print("cccccccccccccccccccccc players="..dump(players))
	--print("cccccccccccccccccccccc #players="..#players)
	if players~=nil and type(players)=="table" then
		for nameto, _ in pairs(players) do 
			--print("cccccccccccccccccccccc nameto="..dump(nameto))
			local mens = brazutec_lunocartas.set_mail(namefrom, nameto, message)
			if mens~=nil then
				contsend = contsend + 1
			end
		end
	end
	return contsend
end

brazutec_lunocartas.chat_broadcast = function(name, param) --Usado apenas por comando de chat
	if name~=nil and type(name)=="string" and name~="" then
		player = minetest.get_player_by_name(name)
		if player~=nil and player:is_player() then --Verifica se o player ainda esta online
			if param~=nil and type(param)=="string" and param~="" then
				local contsend = brazutec_lunocartas.set_broadcast(name, param)
				if contsend>=1 then
					--minetest.sound_play("sfx_alertfire", {object=player, max_hear_distance = 1000})  
					minetest.chat_send_player(name,"Sua carta foi enviada para '"..contsend.."' players.")
					brazutec_lunocartas.save()
				else
					minetest.chat_send_player(name,"Nao foi enviada esta carta para nenhum player.")
				end
				return contsend
			else
				minetest.chat_send_player(name,"/broadcast <mensagem>: Envia cartas para todos os jogadores cadastrados.")
			end
		end
	end
end

brazutec_lunocartas.regulechars = function(text)
	text = text:gsub("\r", "")

	text = text:gsub("[Â]", "A")
	text = text:gsub("[Ä]", "A")
	text = text:gsub("[Ã]", "A")
	text = text:gsub("[Á]", "A")
	text = text:gsub("[À]", "A")
	text = text:gsub("[Ê]", "E")
	text = text:gsub("[Ë]", "E")
	text = text:gsub("[Ẽ]", "E")
	text = text:gsub("[É]", "E")
	text = text:gsub("[È]", "E")
	text = text:gsub("[Î]", "I")
	text = text:gsub("[Ï]", "I")
	text = text:gsub("[Ĩ]", "I")
	text = text:gsub("[Í]", "I")
	text = text:gsub("[Ì]", "I")
	text = text:gsub("[Ô]", "O")
	text = text:gsub("[Ö]", "O")
	text = text:gsub("[Õ]", "O")
	text = text:gsub("[Ó]", "O")
	text = text:gsub("[Ò]", "O")
	text = text:gsub("[Û]", "U")
	text = text:gsub("[Ü]", "U")
	text = text:gsub("[Ũ]", "U")
	text = text:gsub("[Ú]", "U")
	text = text:gsub("[Ù]", "U")
	text = text:gsub("[Ç]", "C")
	
	text = text:gsub("[â]", "a")
	text = text:gsub("[ä]", "a")
	text = text:gsub("[ã]", "a")
	text = text:gsub("[á]", "a")
	text = text:gsub("[à]", "a")
	text = text:gsub("[ê]", "e")
	text = text:gsub("[ë]", "e")
	text = text:gsub("[ẽ]", "e")
	text = text:gsub("[é]", "e")
	text = text:gsub("[è]", "e")
	text = text:gsub("[î]", "i")
	text = text:gsub("[ï]", "i")
	text = text:gsub("[ĩ]", "i")
	text = text:gsub("[í]", "i")
	text = text:gsub("[ì]", "i")
	text = text:gsub("[ô]", "o")
	text = text:gsub("[ö]", "o")
	text = text:gsub("[õ]", "o")
	text = text:gsub("[ó]", "o")
	text = text:gsub("[ò]", "o")
	text = text:gsub("[û]", "u")
	text = text:gsub("[ü]", "u")
	text = text:gsub("[ũ]", "u")
	text = text:gsub("[ú]", "u")
	text = text:gsub("[ù]", "u")
	text = text:gsub("[ç]", "c")

	
	return text
end

brazutec_lunocartas.get_mails = function(playername)
	if brazutec_lunocartas.players~=nil and type(brazutec_lunocartas.players)=="table" and brazutec_lunocartas.players[playername]~=nil then
		return brazutec_lunocartas.players[playername]
	end
end

brazutec_lunocartas.get_mail = function(playername, mailnumber)
	if playername~=nil and type(playername)=="string" and playername~="" then
		if brazutec_lunocartas.players~=nil and type(brazutec_lunocartas.players)=="table" and brazutec_lunocartas.players[playername]~=nil then
			local mails = brazutec_lunocartas.players[playername]
			if #mails >= 1 and type(mailnumber)=="number" and mails[mailnumber]~=nil then
				return mails[mailnumber]
			end
		end
	end
end

brazutec_lunocartas.get_formspecmails = function(playername)
	local formspeclist = ""
	if playername~=nil and type(playername)=="string" and playername~="" then
		local mails = brazutec_lunocartas.get_mails(playername)
		if mails~=nil and type(mails)=="table" and #mails>=1 then
			for n, mail in pairs(mails) do 
				local mensagem = mail.message:gsub("[\n]", " ")
				mensagem = brazutec_lunocartas.regulechars(mensagem)
				
				if mail.readed == true then
					formspeclist = formspeclist .. minetest.formspec_escape(os.date("%Y-%m-%d %Hh:%Mm:%Ss", mail.time).." [X] <"..mail.namefrom.."> ".. brazutec_lunocartas.regulechars(mensagem))
				else
					formspeclist = formspeclist .. minetest.formspec_escape(os.date("%Y-%m-%d %Hh:%Mm:%Ss", mail.time).." [  ] <"..mail.namefrom.."> ".. brazutec_lunocartas.regulechars(mensagem))
				end
				if n < #mails then
					formspeclist = formspeclist .. ","
				end
			end
		end
	end
	return formspeclist
end


brazutec_lunocartas.chat_readmail = function(name) --Usado apenas por comando de chat
	if name~=nil and type(name)=="string" and name~="" then
		local player = minetest.get_player_by_name(name)
		if player~=nil and player:is_player() then --Verifica se o player ainda esta online
			local mails = brazutec_lunocartas.get_mails(name)
			if mails~=nil and type(mails)=="table" and #mails>=1 then
				for n, mail in pairs(mails) do 
					if mail.readed == true then
						minetest.chat_send_player(name, os.date("%Y-%m-%d %Hh:%Mm:%Ss", mail.time) .." [X] <"..mail.namefrom.."> ".. brazutec_lunocartas.regulechars(mail.message))
					else
						minetest.chat_send_player(name, os.date("%Y-%m-%d %Hh:%Mm:%Ss", mail.time) .." [  ] <"..mail.namefrom.."> ".. brazutec_lunocartas.regulechars(mail.message))
					end
					brazutec_lunocartas.set_read(name, n, true)
				end
				brazutec_lunocartas.save()
				return #mails
			else
				minetest.chat_send_player(name, "Voce nao tem nenhuma mensagem...")
				return 0
			end
		end
	end
	return false
end

brazutec_lunocartas.del_mail = function(playername, mailnumber)
	if playername~=nil and type(playername)=="string" and playername~="" then
		if brazutec_lunocartas.players~=nil and type(brazutec_lunocartas.players)=="table" and brazutec_lunocartas.players[playername]~=nil then
			local mails = brazutec_lunocartas.players[playername]
			if #mails >= 1 and type(mailnumber)=="number" and mails[mailnumber]~=nil then
				table.remove(brazutec_lunocartas.players[playername], mailnumber)
				--brazutec_lunocartas.players[playername][mailnumber] = nil
				brazutec_lunocartas.hud_print(playername)
				return true
			end
		end
	end
	return false
end

brazutec_lunocartas.del_readeds = function(playername)
	print("brazutec_lunocartas.del_readeds() ===========> playername=" ..dump(playername))
	if playername~=nil and type(playername)=="string" and playername~="" then
		local mails = brazutec_lunocartas.players[playername]
		--print("aaaaaaaaaaa mails = "..dump(mails))
		if mails~=nil and type(mails)=="table" then
			local countdel = 0
			if #mails>=1 then
				for n, mail in pairs(mails) do 
					--print("aaaaaaaaaaa brazutec_lunocartas.players["..playername.."]["..n.."].readed = "..dump(brazutec_lunocartas.players[playername][n].readed))
					--print("aaaaaaaaaaa mail.readed = "..dump(mail.readed))
					if mail.readed == true then
						--print("aaaaaaaaaaa brazutec_lunocartas.del_mail("..playername..", "..n..")")
						if brazutec_lunocartas.del_mail(playername, n)==true then
							countdel = countdel + 1
						end
					end
				end
			end
			return countdel
		end
	end
end

brazutec_lunocartas.chat_delreadeds = function(playername) --Usado apenas por comando de chat
	--print("bbbbbbbbbbbbbbbbbb playername = "..dump(playername))
	if playername~=nil and type(playername)=="string" and playername~="" then
		player = minetest.get_player_by_name(playername)
		if player~=nil and player:is_player() then --Verifica se o player ainda esta online
			local apagados = brazutec_lunocartas.del_readeds(playername)
			if apagados~=nil and type(apagados)=="number" then
				if apagados>=1 then
					minetest.chat_send_player(playername, "Cartas Destruidas: "..apagados)
					brazutec_lunocartas.save()
				else
					minetest.chat_send_player(playername, "Voce nao tem nenhuma carta lida para destruir.")
				end
			else
				minetest.chat_send_player(playername, "Erro ao apagar suas cartas.")
			end
			return apagados
		end
	end
end

brazutec_lunocartas.get_countunreaded = function(name)
	--print("name="..dump(name))
	if name~=nil and type(name)=="string" and name~="" and brazutec_lunocartas.players[name]~=nil then
		local mails = brazutec_lunocartas.players[name]
		--print("type(mails)="..type(mails))
		--print("mails="..dump(mails))
		local myCount = 0
		if mails~=nil and type(mails)=="table" and #mails>=1 then
			for n, mail in pairs(mails) do 
				if mail.readed ~= true then
					myCount = myCount +1
				end
			end
		end
		return myCount
	end
end


brazutec_lunocartas.del_olds = function()
	if brazutec_lunocartas.players~=nil and type(brazutec_lunocartas.players)=="table" and #brazutec_lunocartas.players>=1 then
		local countdels = 0
		for name, _ in pairs(brazutec_lunocartas.players) do 
			local mails = brazutec_lunocartas.players[name]
			if mails~=nil and type(mails)=="number" and #mails>=1 then
				for n, mail in pairs(mails) do 
					if brazutec_lunocartas.players[name][n].time < os.time() - (1000*60*60*24*30) then --2592000000ms = 30 dias
						if brazutec_lunocartas.del_mail(name, n)==true then
							countdels = countdels + 1
						end
					end
				end
				brazutec_lunocartas.save()
			end
		end
		return countdels
	end
end

brazutec_lunocartas.chat_delolds = function(name) --Usado apenas por comando de chat
	if name~=nil and type(name)=="string" and name~="" then
		player = minetest.get_player_by_name(name)
		if player~=nil and player:is_player() then --Verifica se o player ainda esta online
			local contdels = brazutec_lunocartas.del_olds()
			if contdels~=nil and type(contdels)=="number" then
				if contdels>=1 then
					minetest.chat_send_player(name, contdels.." mensagens antigas foram apagadas no servidor.")
					brazutec_lunocartas.save()
				else
					minetest.chat_send_player(name,"Nao foi apagado nenhum mensagem antiga neste servidor.")
				end
				return contdels
			else
				minetest.chat_send_player(name,"Ocorreu um erro ao apagar todos os email antigos.")
			end
		end
	end
end


brazutec_lunocartas.set_read = function(playername, mailnumber, value)
	if playername~=nil and type(playername)=="string" and playername~="" then
		if brazutec_lunocartas.players~=nil and type(brazutec_lunocartas.players)=="table" and brazutec_lunocartas.players[playername]~=nil then
			local mails = brazutec_lunocartas.players[playername]
			if #mails >= 1 and type(mailnumber)=="number" and mails[mailnumber]~=nil then
				brazutec_lunocartas.players[playername][mailnumber].readed = value
				return true
			end
		end
	end
end

brazutec_lunocartas.hud_print = function(player)
	if player~=nil and type(player)=="string" and player~="" then --Caso a variavel "player" seja fornecido no formato "string"
		player = minetest.get_player_by_name(player)
	end
	
	if player~=nil and player:is_player() then
		local playername = player:get_player_name()

		if brazutec_lunocartas.huds[playername]==nil then
			brazutec_lunocartas.huds[playername] ={}
		end
		
		if brazutec_lunocartas.huds[playername].image then
			player:hud_remove(brazutec_lunocartas.huds[playername].image)
		end
		if brazutec_lunocartas.huds[playername].text1 then
			player:hud_remove(brazutec_lunocartas.huds[playername].text1)
		end
		--[[
		if brazutec_lunocartas.huds[playername].text2 then
			player:hud_remove(brazutec_lunocartas.huds[playername].text2)
		end
		]]--

		
		local unreadeds = brazutec_lunocartas.get_countunreaded(playername)
		--print("brazutec_lunocartas.get_countunreaded("..playername..")="..unreadeds)
		if unreadeds~=nil and type(unreadeds)=="number" and unreadeds>=1 then
			local mensagem=""
			if unreadeds==1 then
				mensagem="Voce tem 1 email nao lido \nem sua caixa de correio!"
			else
				mensagem="Voce tem "..unreadeds.." emails nao lidos \nem sua caixa de correio!"
			end
			
			brazutec_lunocartas.huds[playername].image = player:hud_add({
				hud_elem_type = "image",
				--name = "MailIcon",
				position = {x=0.71, y=0.45}, --{x=0.51, y=0.45},
				text="brazutec_icon_mail2.png",
				scale = {x=1,y=1},
				alignment = {x=0.5, y=0.5},
			})	
			brazutec_lunocartas.huds[playername].text1 = player:hud_add({
				hud_elem_type = "text",
				--name = "MailText",
				number = 0xFFFFFF,
				position = {x=0.81, y=0.49}, --{x=0.71, y=0.56},
				text=mensagem,
				scale = {x=1,y=1},
				alignment = {x=0.5, y=0.5},
			})
			--[[
			brazutec_lunocartas.huds[playername].text2 = player:hud_add({
				hud_elem_type = "text",
				--name = "MailHint", -- Criado por mim(Lunovox).
				position = {x=0.70, y=0.55}, --{x=0.50, y=0.55},
				text="Digite: [/brazutec_lunocartas]",
				scale = {x=1,y=1},
				alignment = {x=0.5, y=0.5},
			})
			]]--
		end -- fim de if unreadeds~=nil then
	end -- fim de if player~=nil and player:is_player() then
end

brazutec_lunocartas.hud_check = function()
	local players = minetest.get_connected_players()
	--print("#players="..#players)
	--print("brazutec_lunocartas.hud_time["..brazutec_lunocartas.hud_time.."] + brazutec_lunocartas.hud_delay["..brazutec_lunocartas.hud_delay.."] < os.time("..os.time()..") ")
	if #players >= 1 then
		if 
			brazutec_lunocartas.hud_time~=nil and brazutec_lunocartas.hud_delay~=nil and 
			type(brazutec_lunocartas.hud_time)=="number" and type(brazutec_lunocartas.hud_delay)=="number" and 
			brazutec_lunocartas.hud_time + brazutec_lunocartas.hud_delay < os.time() 
		then
			brazutec_lunocartas.hud_time = os.time()
			for _, player in ipairs(players) do
				--print("#players="..#players)
				--print("brazutec_lunocartas.hud_time["..brazutec_lunocartas.hud_time.."] + brazutec_lunocartas.hud_delay["..brazutec_lunocartas.hud_delay.."] < os.time("..os.time()..") ")
				--print("brazutec_lunocartas.hud_print("..player:get_player_name()..")")
				brazutec_lunocartas.hud_print(player)
			end
		end
	end
end


