const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Merchandiser = sequelize.define('Merchandiser', {
    merchandiser_id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    nom: {
      type: DataTypes.STRING,
      allowNull: false
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
      validate: {
        isEmail: true
      }
    },
    telephone: {
      type: DataTypes.STRING,
      allowNull: false
    },
    zone_assignee: {
      type: DataTypes.STRING,
      allowNull: false
    },
    secteurs_assignes: {
      type: DataTypes.JSONB,
      allowNull: false,
      defaultValue: []
    },
    zone_geofence: {
      type: DataTypes.JSONB,
      allowNull: true
    },
    actif: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    }
  }, {
    tableName: 'merchandisers',
    indexes: [
      {
        fields: ['zone_assignee']
      },
      {
        fields: ['email'],
        unique: true
      }
    ]
  });

  return Merchandiser;
};