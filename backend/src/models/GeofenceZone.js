const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const GeofenceZone = sequelize.define('GeofenceZone', {
    zone_id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    nom_zone: {
      type: DataTypes.STRING,
      allowNull: false
    },
    coordonnees_polygone: {
      type: DataTypes.JSONB,
      allowNull: false
    },
    secteur: {
      type: DataTypes.STRING,
      allowNull: false
    },
    territoire: {
      type: DataTypes.STRING,
      allowNull: false
    },
    rayon_buffer: {
      type: DataTypes.DECIMAL(10, 2),
      defaultValue: 300.0
    },
    actif: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    }
  }, {
    tableName: 'geofence_zones',
    indexes: [
      {
        fields: ['secteur']
      },
      {
        fields: ['territoire']
      }
    ]
  });

  return GeofenceZone;
};