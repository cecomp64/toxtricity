# tox-bot
#
# Objectives
#   - Enable bot in certain channels only to avoid spam
#     - r! tox-bot enable
#   - Assign a role from emoji reaction
#     - Message should indicate role-emoji dictionary
#     - Also create the role
#       - guild.roles.create({ data: { name: 'Mod', permissions: ['MANAGE_MESSAGES', 'KICK_MEMBERS'] } });
#   - Assign a role when users say something for the first time in a channel
#     - i.e. Say hi in board-games to be added to @board-games
#     - Enable when an admin gives a command r! chat-role <role>
#     - Also create the role
#   - Quotes
#     - Access the quotebook via API for a random quote
#     - Band names

Discord = require('discord.js-light')
client = new Discord.Client()
secret = process.env.DISCORD_TOKEN
my_id = 1234

# Hola, mundo
client.once('ready', () =>
  console.log('Ready!')
)

client.login(secret)

# Events
# https://gist.github.com/koad/316b265a91d933fd1b62dddfcc3ff584
# messageReactionAdd
client.on("messageReactionAdd", (messageReaction, user) =>
  # In discord.js-light, message is a *partial* (just ID)
  #  channel.messages.fetch(id)
  message = messageReaction.message
  channel = message.channel

  console.log("Message partial: #{message.partial}")

  if(message.partial)
    console.log("Message ID: #{message.id}")
    message = channel.messages.fetch(message.id)


  author = message.author

  emoji = messageReaction.emoji.name

  console.log("Reaction of " + emoji + " from " + user.username + " on " + author.username + "'s message!")
  message.channel.send("Reaction of " + emoji + " from " + user.username + " on " + author.username + "'s message!")

  # Message format:
  #  Some text instructions
)

client.on("message", (message) =>
  console.log(message.content)
)
