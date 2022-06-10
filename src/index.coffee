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

Discord = require('discord.js-light')
Sequelize = require('sequelize')
client = new Discord.Client()
secret = process.env.DISCORD_TOKEN
my_id = 1234

# Connect to database
sequelize = new Sequelize(process.env.DATABASE_URL, {
  dialect:  'postgres',
  protocol: 'postgres',
  dialectOptions: {
    ssl: {
      require: true,
      rejectUnauthorized: false
    }
  }
})

# Create a model
Boardgame = sequelize.define('boardgame', {
  name: {
    type: Sequelize.STRING,
    unique: true,
    allowNull: false,
  },
  min_age: Sequelize.INTEGER,
  min_time: Sequelize.INTEGER,
  max_time: Sequelize.INTEGER,
  min_players: Sequelize.INTEGER,
  max_players: Sequelize.INTEGER,
  bgg_score: Sequelize.FLOAT,
  tabletopia: Sequelize.TEXT,
})

RoleMessage = sequelize.define('role_message', {
  message_id: {
    type: Sequelize.STRING,
    unique: true,
  }
})

Role = sequelize.define('role', {
  name: {
    type: Sequelize.STRING,
    unique: true,
  },
  emoji: {
    type: Sequelize.STRING,
    unique: true,
  },
}, {
  getterMethods: {
    description: () -> "#{this.emoji} #{this.name}",
    reference: () -> "@#{this.name}",
  }
})

Role.belongsToMany(RoleMessage, {through: 'RoleRoleMessage'})
RoleMessage.belongsToMany(Role, {through: 'RoleRoleMessage'})

Poll = sequelize.define('poll', {
  message_id: {
    type: Sequelize.STRING,
    unique: true,
    allowNull: false,
  }
})

Choice = sequelize.define('choice', {
  name: {
    type: Sequelize.STRING,
  },
  emoji: {
    type: Sequelize.STRING,
  },
  count: Sequelize.INTEGER,
})

Choice.belongsTo(Poll)

# Update models
sequelize.sync().then((result) =>
  console.log(result)
)
.catch((err) =>
  console.log(err)
)

print_reaction = (emoji, user, author, message) =>
  console.log("Reaction of " + emoji + " from " + user.username + " on " + author.username + "'s message!")
  message.channel.send("Reaction of " + emoji + " from " + user.username + " on " + author.username + "'s message!")

# Hola, mundo
client.once('ready', () =>
  console.log('Ready!')
)

client.login(secret)


parse_poll = (message) =>
  return 1


# find_or_create_role
#
# Use the name to find a role.  If none exists, create it and give it an emoji.
find_or_create_role = (emoji, name)  =>
  # Sanity check emoji starts and ends with ::
  if(emoji.charCodeAt(0) <= 255) # Unicode at least...
    console.log("find_or_create_role: emoji argument failed sanity check #{emoji}")
    return null

  ret_role = Role.findOne({
    where: {
      name: name
    }
  }).then((role) =>
    if(role == null)
      return Role.create({emoji: emoji, name: name}).then((new_role) =>
        return new_role
      ).catch(console.error)
    else
      return role
  ).catch(console.error)

  return ret_role

# create_role_assignments
#
# words - the remaining, tokenized command of the format: :foo: Role Name1, :bar: Role Name2, ...
# channel - what channel to post the role message in
#
# Send a message to the given channel with the parsed out roles.  Create the RoleMessage object with the associated
# Roles.  Create any Roles that do not already exist.
create_role_assignments = (words, channel) =>
  roles = []

  # what remains should be emoji, role pairs
  str = words.join(' ')
  tokens = tokenize(str, ',')
  console.log(tokens)

  # Process each role with its emoji
  for i in [0..tokens.length-1]
    entry_words = tokens[i].split(' ')
    emoji = entry_words.shift()
    name = entry_words.join(' ')

    roles.push find_or_create_role(emoji, name)

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
        load_data.push(message.guild.fetch())

        # Wait for them both...
        Promise.all(load_data).then( (loaded_data) =>
          role_message = loaded_data[0]
          guild = loaded_data[1]

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
                data: {
                  name: role.name,
                  mentionable: true,
                  position: 4,
                  permissions: Discord.Permissions.DEFAULT,
                },
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
client.on("message", (message) =>
  words = tokenize(message.content, ' ')
  console.log(words)

  first_word = words.shift()
  command = words.shift()

  if(first_word == 'tb!')
    console.log(command)

    switch command
      when 'poll'
        return 1
      when 'roles'
        create_role_assignments(words, message.channel)
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
