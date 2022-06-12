{ SlashCommandBuilder } = require('@discordjs/builders')

module.exports = {
  data: new SlashCommandBuilder()
    .setName('ping_three')
    .setDescription('Replies with Pong!'),

  execute: (interaction) =>
    console.log('Execute triggered...') 
    await interaction.reply('Pong!')
}
