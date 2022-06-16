// tox-bot

// Objectives
//   - Enable bot in certain channels only to avoid spam
//     - !tb tox-bot enable
//   - Assign a role from emoji reaction
//     - Message should indicate role-emoji dictionary
//     - Also create the role
//       - guild.roles.create({ data: { name: 'Mod', permissions: ['MANAGE_MESSAGES', 'KICK_MEMBERS'] } });
//     - Other bot examples
//       - !tb add [channel] emoji role, emoji role, emoji role ...
//       - Saves to a database!?
//         - Maybe just check if role already exists
//   - Query available roles
//   - Randomly pick from a list
//     - Who goes first, what game to play, etc
//   - Polls, voting
//     - Close poll with a reaction
//     - Show results with a reaction
//   - Assign a role when users say something for the first time in a channel
//     - i.e. Say hi in board-games to be added to @board-games
//     - Enable when an admin gives a command r! chat-role <role>
//     - Also create the role
//   - Quotes
//     - Access the quotebook via API for a random quote
//     - Band names
//   - Spin up a tabletopia game or link
//   - r!games r!playnow
//     - Scribbl.io - https://skribbl.io
//     - tabletopia - simple link to tabletopia.com
//     - Pokemon Showdown
//     - Pokemon TCGO

// Helpful links
//  https://stackoverflow.com/questions/27687546/cant-connect-to-heroku-postgresql-database-from-local-node-app-with-sequelize
//  https://discord.js.org/#/docs/discord.js/main/class/Client?scrollTo=e-messageCreate
//  https://www.npmjs.com/package/discord.js-light
var Database, DeployCommands, Discord, Role, RoleMessage, Validation, client, create_role_assignments, parse_poll, print_reaction, register_commands, secret, tokenize;

Database = require('../src/database');

Role = Database.Role;

RoleMessage = Database.RoleMessage;

Validation = require('../src/validation');

Discord = require('discord.js-light');

client = new Discord.Client({
  intents: [Discord.Intents.FLAGS.GUILDS, Discord.Intents.FLAGS.GUILD_MESSAGES, Discord.Intents.FLAGS.GUILD_MESSAGE_REACTIONS]
});

// Flag to specify whether to re-register commands
register_commands = true;

DeployCommands = require('../src/deploy-commands');

secret = process.env.DISCORD_TOKEN;

print_reaction = (emoji, user, author, message) => {
  console.log("Reaction of " + emoji + " from " + user.username + " on " + author.username + "'s message!");
  return message.channel.send("Reaction of " + emoji + " from " + user.username + " on " + author.username + "'s message!");
};

// Hola, mundo
client.once('ready', () => {
  console.log('Ready!!!');
  if (register_commands) {
    // Initialize commands globally
    return DeployCommands.register(client);
  }
});

//await sequelize.sync({ force: true })
//console.log("All models were synchronized successfully.")
client.login(secret);

parse_poll = (message) => {
  return 1;
};

// create_role_assignments

// words - the remaining, tokenized command of the format: :foo: Role Name1, :bar: Role Name2, ...
// channel - what channel to post the role message in

// Send a message to the given channel with the parsed out roles.  Create the RoleMessage object with the associated
// Roles.  Create any Roles that do not already exist.
create_role_assignments = (words, channel, guild) => {
  var i, j, pairs, ref, roles;
  roles = [];
  
  //If errors are present log and return
  pairs = Validation.validate_pairs(words);

  // Process each role with its emoji
  for (i = j = 0, ref = pairs.length - 1; (0 <= ref ? j <= ref : j >= ref); i = 0 <= ref ? ++j : --j) {
    roles.push(Database.find_or_create_role(pairs[i].emoji, pairs[i].name));
  }

  // Remove failed roles
  console.log(roles);

  roles = roles.filter(function(el) {
    return el !== null;
  });

  if (roles.length === 0) {
    return null;
  }

  // Roles are still just promises, so wait for them all
  return Promise.all(roles).then((resolved_roles) => {
    var k, len, message_content, role;

    // Create the message to assign roles!
    message_content = "Respond with an emoji to assign yourself one of the following roles: \n";

    for (i = k = 0, len = resolved_roles.length; k < len; i = ++k) {
      role = resolved_roles[i];
      console.log(role.name);
      message_content = `${message_content}${role.description}\n`;
    }
    // Fetch the channel for good measure...
    return channel.fetch().then((_channel) => {
      // Send the message
      return _channel.send(message_content).then((message) => {
        var load_data;

        console.log(message);
        load_data = [];

        // Create the role message to lookup on reaction
        load_data.push(RoleMessage.create({
          message_id: message.id
        }));
        // Wait for them both...
        return Promise.all(load_data).then((loaded_data) => {
          var l, len1, reactionsAsync, role_message;
          role_message = loaded_data[0];
          // Add placeholder reactions
          reactionsAsync = [];

          for (i = l = 0, len1 = resolved_roles.length; l < len1; i = ++l) {
            role = resolved_roles[i];
            reactionsAsync.push(message.react(role.emoji));
          }

          return Promise.all(reactionsAsync).then((reactions) => {
            var len2, m, reactionMessage, results;
            results = [];

            for (i = m = 0, len2 = reactions.length; m < len2; i = ++m) {
              reactionMessage = reactions[i];
              role = resolved_roles[i];

              // Add this role to the role_message, so reactions will trigger role assignments
              role_message.addRole(role).then(console.log).catch(console.error);

              // Check if role already exists
              // Create role
              results.push(guild.roles.create({
                name: role.name,
                mentionable: true,
                //position: 4,
                permissions: Discord.Permissions.DEFAULT,
                reason: `To stay informed about ${role.name}`
              }).then(console.log).catch(console.error));

            }

            return results;
          }).catch(console.error);
        }).catch(console.error); // RoleMessage.create
      }).catch(console.error); // channel.send
    }).catch(console.error); // channel.fetch
  }).catch(console.error); // Promise.all
};


// Parse commands from chat
client.on("messageCreate", (message) => {
  var command, first_word, words;

  words = tokenize(message.content, ' ');
  console.log(words);

  first_word = words.shift();
  command = words.shift();

  console.log('Handling Message');
  if (first_word === 'tb!') {
    console.log(command);
    switch (command) {
      case 'register':
        DeployCommands.register(message.guildId);
        break;
      case 'roles':
        create_role_assignments(words, message.channel, message.guild);
        break;
    }
  }

});

// Handle slash commands (aka "interactions")
client.on("interactionCreate", (interaction) => {
  if (!interaction.isCommand()) {
    return;
  }
  return console.log(interaction);
});

// messageReactionAdd

// Handle any reaction-based actions, like:
//   - Assigning a role if the reaction message matches a RoleMessage
client.on("messageReactionAdd", (messageReaction, user) => {
  var channel, message;
  // In discord.js-light, message is a *partial*
  message = messageReaction.message;
  channel = message.channel;
  console.log(`Message partial: ${message.partial}`);
  console.log(`Message ID: ${message.id}`);
  // Fetch that message... always?  What if it is already cached?
  return channel.messages.fetch(message.id).then((message) => {
    var author, emoji;
    author = message.author;
    console.log(`Author: ${author}`);
    emoji = messageReaction.emoji.name;
    // Fetch those users!
    return messageReaction.users.fetch().then((users) => {
      // The first one is the one for this reaction!?  Check them all?
      user = users.first();
      return print_reaction(emoji, user, author, message);
    // Find the role for this emoji
    //role = get_role()
    }).catch(console.error);
  }).catch(console.error);
});

//######################################################
//######################################################
//                   Helpers
//######################################################
//######################################################

// Put this at the end because syntax highlighting is sad
// Message format:
//  Some text instructions
tokenize = (str, separator) => {
  var regex, tokens;

  regex = new RegExp(`${separator}+`);

  tokens = str.split(regex).filter(function(el) {
    return el !== '';
  }).map(function(el) {
    return el.trim();
  });

  return tokens;
};