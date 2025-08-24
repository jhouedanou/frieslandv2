const { Sequelize } = require('sequelize');

const sequelize = new Sequelize({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'friesland_db',
  username: process.env.DB_USER || 'friesland_user',
  password: process.env.DB_PASSWORD || 'friesland_password',
  dialect: 'postgres',
  logging: process.env.NODE_ENV === 'development' ? console.log : false,
  pool: {
    max: 10,
    min: 0,
    acquire: 30000,
    idle: 10000
  },
  define: {
    underscored: true,
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at'
  }
});

// Import models
const Visite = require('../models/Visite')(sequelize);
const PDV = require('../models/PDV')(sequelize);
const Merchandiser = require('../models/Merchandiser')(sequelize);
const GeofenceZone = require('../models/GeofenceZone')(sequelize);

// Define associations
const setupAssociations = () => {
  // PDV -> Visites (One to Many)
  PDV.hasMany(Visite, {
    foreignKey: 'pdv_id',
    as: 'visites'
  });
  
  Visite.belongsTo(PDV, {
    foreignKey: 'pdv_id',
    as: 'pdv'
  });

  // Merchandiser -> GeofenceZones (Many to Many)
  Merchandiser.belongsToMany(GeofenceZone, {
    through: 'merchandiser_zones',
    foreignKey: 'merchandiser_id',
    otherKey: 'zone_id',
    as: 'zones'
  });

  GeofenceZone.belongsToMany(Merchandiser, {
    through: 'merchandiser_zones',
    foreignKey: 'zone_id',
    otherKey: 'merchandiser_id',
    as: 'merchandisers'
  });
};

setupAssociations();

module.exports = {
  sequelize,
  models: {
    Visite,
    PDV,
    Merchandiser,
    GeofenceZone
  }
};