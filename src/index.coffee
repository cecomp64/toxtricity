Discord = require('discord.js')
client = new Discord.Client()
secret = process.env.DISCORD_TOKEN
my_id = 1234

client.once('ready', () =>
  console.log('Ready!')
)

client.login(secret)

# Events
# https://gist.github.com/koad/316b265a91d933fd1b62dddfcc3ff584
# messageReactionAdd
#client.on("messageReactionAdd", (messageReaction, user) =>
#  me = messageReaction.message.author.id == my_id