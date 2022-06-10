Sequelize = require('sequelize')

Database = () =>
  # Connect to database
  sequelize = new Sequelize(process.env.DATABASE_URL, {
    logging: false,
    dialect:  'postgres',
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

module.exports = Database