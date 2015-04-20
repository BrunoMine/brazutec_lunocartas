

minetest.register_chatcommand("publicar", {
	privs = {postman=true},
	params = "<mensagem>",
	description = "/publicar <mensagem> : Envia email para todos os players cadastrados.",
	func = function(name, param)
		brazutec_lunocartas.chat_broadcast(name, param)
	end,
})

minetest.register_chatcommand("delolds", {
	privs = {postman=true},
	params = "",
	description = "/delolds : Apaga os email com mais de trinta dias em todo o servidor.",
	func = function(name, param)
		brazutec_lunocartas.chat_delolds(name)
	end,
})