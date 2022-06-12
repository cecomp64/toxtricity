# Derived from https://discordjs.guide/creating-your-bot/command-handling.html#individual-command-files
{ Collection } = require('discord.js')
{ REST } = require('@discordjs/rest');
{ Routes } = require('discord-api-types/v9');

# Return either an array of JSON command data, or a collection (keyed by name) with full object
commandArray = (array_not_collection) =>
  fs = require('node:fs')
  path = require('node:path')

  commands = []
  command_collection = new Collection()
  commandsPath = path.join(__dirname, 'commands')
  commandFiles = fs.readdirSync(commandsPath).filter((file) => file.endsWith('.js'))

  # Dynamically read in command files
  for file of commandFiles
    filePath = path.join(commandsPath, commandFiles[file])
    command = require(filePath)
    commands.push(command.data.toJSON())
    command_collection.set(command.data.name, command)

  return if array_not_collection then commands else command_collection

module.exports.commandArray = commandArray
module.exports.register = (client) =>
  clientId = process.env.DISCORD_CLIENT_ID
  token = process.env.DISCORD_TOKEN
  guildId = null
  commands = commandArray(true)
  rest = new REST({ version: '9' }).setToken(token);

  console.log('Unregistering old commands...')

  # Delete old commands
  client.application.commands.cache.forEach((command, key)=>
    command.delete()
    console.log('  Deleted command ' + command.id)
  )

  console.log('Registering commands...')

  # Register new commands global or per guild
  # guild is not supported, just here for informational purposes
  if guildId == null
    rest.put(Routes.applicationCommands(clientId), { body: commands })
      .then(() => console.log('Successfully registered global application commands.'))
      .catch(console.error)
  else
    rest.put(Routes.applicationGuildCommands(clientId, guildId), { body: commands })
      .then(() => console.log('Successfully registered Guild application commands.'))
      .catch(console.error)