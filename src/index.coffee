Discord = require('discord.js')
client = new Discord.Client()
secret = process.env.DISCORD_TOKEN

client.once('ready', () =>
  console.log('Ready!')
)

client.login(secret)