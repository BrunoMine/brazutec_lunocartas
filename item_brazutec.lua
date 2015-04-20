if type(brazutec_laptop)=="table" then
	local imagem_para_enviar = "brazutec_lunocartas_botao_app.png";
	local etiqueta_para_enviar = "abrirmsg";
	brazutec_instalar_em_cub(imagem_para_enviar,etiqueta_para_enviar)
	minetest.register_on_player_receive_fields(function(player, formname, fields)
		if fields.abrirmsg then
			brazutec_lunocartas.openinbox(player, formname)
		end
	end)
end
