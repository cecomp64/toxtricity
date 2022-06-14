# tox-bot
#
# Objectives
#   - Enable bot in certain channels only to avoid spam
#     - !tb tox-bot enable
#   - Assign a role from emoji reaction
#     - Message should indicate role-emoji dictionary
#     - Also create the role
#       - guild.roles.create({ data: { name: 'Mod', permissions: ['MANAGE_MESSAGES', 'KICK_MEMBERS'] } });
#     - Other bot examples
#       - !tb add [channel] emoji role, emoji role, emoji role ...
#       - Saves to a database!?
#         - Maybe just check if role already exists
#   - Query available roles
#   - Randomly pick from a list
#     - Who goes first, what game to play, etc
#   - Polls, voting
#     - Close poll with a reaction
#     - Show results with a reaction
#   - Assign a role when users say something for the first time in a channel
#     - i.e. Say hi in board-games to be added to @board-games
#     - Enable when an admin gives a command r! chat-role <role>
#     - Also create the role
#   - Quotes
#     - Access the quotebook via API for a random quote
#     - Band names
#   - Spin up a tabletopia game or link
#   - r!games r!playnow
#     - Scribbl.io - https://skribbl.io
#     - tabletopia - simple link to tabletopia.com
#     - Pokemon Showdown
#     - Pokemon TCGO

# Helpful links
#  https://stackoverflow.com/questions/27687546/cant-connect-to-heroku-postgresql-database-from-local-node-app-with-sequelize
#  https://discord.js.org/#/docs/discord.js/main/class/Client?scrollTo=e-messageCreate
#  https://www.npmjs.com/package/discord.js-light

Database = require('../lib/database')
Role = Database.Role
RoleMessage = Database.RoleMessage

Validation = require('../lib/validation')

Discord = require('discord.js-light')
client = new Discord.Client({
  intents: [Discord.Intents.FLAGS.GUILDS, Discord.Intents.FLAGS.GUILD_MESSAGES, Discord.Intents.FLAGS.GUILD_MESSAGE_REACTIONS]
})

# Flag to specify whether to re-register commands
register_commands = true
DeployCommands = require('../lib/deploy-commands')

secret = process.env.DISCORD_TOKEN

print_reaction = (emoji, user, author, message) =>
  console.log("Reaction of " + emoji + " from " + user.username + " on " + author.username + "'s message!")
  message.channel.send("Reaction of " + emoji + " from " + user.username + " on " + author.username + "'s message!")

# Hola, mundo
client.once('ready', () =>
  console.log('Ready!!!')

  # Initialize commands globally
  DeployCommands.register(client) if(register_commands)

  #await sequelize.sync({ force: true })
  #console.log("All models were synchronized successfully.")
)

client.login(secret)


parse_poll = (message) =>
  return 1


# create_role_assignments
#
# words - the remaining, tokenized command of the format: :foo: Role Name1, :bar: Role Name2, ...
# channel - what channel to post the role message in
#
# Send a message to the given channel with the parsed out roles.  Create the RoleMessage object with the associated
# Roles.  Create any Roles that do not already exist.
create_role_assignments = (words, channel, guild) =>
  roles = []

  #If errors are present log and return
  pairs = Validation.validate_pairs(words)

  # Process each role with its emoji
  for i in [0..pairs.length-1]
    roles.push Database.find_or_create_role(pairs[i].emoji, pairs[i].name)

  # Remove failed roles
  console.log(roles)
  roles = roles.filter((el) -> el != null)

  return null if(roles.length == 0)

  # Roles are still just promises, so wait for them all
  Promise.all(roles).then((resolved_roles) =>
    # Create the message to assign roles!
    message_content = "Respond with an emoji to assign yourself one of the following roles: \n"

    for role, i in resolved_roles
      console.log(role.name)
      message_content = "#{message_content}#{role.description}\n"

    # Fetch the channel for good measure...
    channel.fetch().then((_channel) =>
      # Send the message
      _channel.send(message_content).then((message) =>
        console.log(message)
        load_data = []

        # Create the role message to lookup on reaction
        load_data.push(RoleMessage.create({message_id: message.id}))

        # Wait for them both...
        Promise.all(load_data).then( (loaded_data) =>
          role_message = loaded_data[0]

          # Add placeholder reactions
          reactionsAsync = []
          for role, i in resolved_roles
            reactionsAsync.push(message.react(role.emoji))

          Promise.all(reactionsAsync).then((reactions) =>
            for reactionMessage, i in reactions
              role = resolved_roles[i]

              # Add this role to the role_message, so reactions will trigger role assignments
              role_message.addRole(role).then(console.log).catch(console.error)

              # Check if role already exists
              # Create role
              guild.roles.create({
                name: role.name,
                mentionable: true,
                #position: 4,
                permissions: Discord.Permissions.DEFAULT,
                reason: "To stay informed about #{role.name}",
              }).then(console.log).catch(console.error)
            ).catch(console.error)
        ).catch(console.error) # RoleMessage.create

      ).catch(console.error) # channel.send
    ).catch(console.error) # channel.fetch
  ).catch(console.error) # Promise.all

# message
#
# Parse commands
client.on("messageCreate", (message) =>
  words = tokenize(message.content, ' ')
  console.log(words)

  first_word = words.shift()
  command = words.shift()

  console.log('Handling Message')

  if(first_word == 'tb!')
    console.log(command)

    switch command
      when 'register'
        DeployCommands.register(message.guildId)
      when 'roles'
        create_role_assignments(words, message.channel, message.guild)
)

# Handle slash commands (aka "interactions")
client.on("interactionCreate", (interaction) =>
  # Only handle commands
  return if !interaction.isCommand()
  console.log(interaction)
)

# messageReactionAdd
#
# Handle any reaction-based actions, like:
#   - Assigning a role if the reaction message matches a RoleMessage
client.on("messageReactionAdd", (messageReaction, user) =>
  # In discord.js-light, message is a *partial*
  message = messageReaction.message
  channel = message.channel

  console.log("Message partial: #{message.partial}")
  console.log("Message ID: #{message.id}")

  # Fetch that message... always?  What if it is already cached?
  channel.messages.fetch(message.id).then( (message) =>
    author = message.author
    console.log("Author: #{author}")
    emoji = messageReaction.emoji.name

    # Fetch those users!
    messageReaction.users.fetch().then( (users) =>
      # The first one is the one for this reaction!?  Check them all?
      user = users.first()
      print_reaction(emoji, user, author, message)

      # Find the role for this emoji
      #role = get_role()

    ).catch(console.error)

  ).catch(console.error)

  # Message format:
  #  Some text instructions
)

#######################################################
#######################################################
#                   Helpers
#######################################################
#######################################################

# Put this at the end because syntax highlighting is sad
tokenize = (str, separator) =>
  regex = new RegExp("#{separator}+")
  tokens = str.split(regex).filter((el) -> el != '').map((el) -> el.trim())
  return tokens
