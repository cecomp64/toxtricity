################################################
#
#  Database Configuration and Schema
#
################################################
Sequelize = require('sequelize')
Path = require('path')

# Connect to database
sequelize = switch process.env.DATABASE_TYPE
  when 'sqlite' then new Sequelize('sqlite::memory:', {storage: Path.join(__dirname, '..', 'dev.sqlite')});
  else new Sequelize(process.env.DATABASE_URL, {
    logging: false,
    dialect:  'postgres',
    url: process.env.DATABASE_URL,
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
sequelize.sync().then(() =>
  console.log('Synced!')
).catch(console.error)

module.exports.Role = Role
module.exports.RoleMessage = RoleMessage

################################################
#
#  Database Helpers
#
################################################

# find_or_create_role
#
# Use the name to find a role.  If none exists, create it and give it an emoji.
module.exports.find_or_create_role = (emoji, name)  =>
  # Gut check emoji starts and ends with ::
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
