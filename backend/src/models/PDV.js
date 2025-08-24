const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const PDV = sequelize.define('PDV', {
    pdv_id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    nom_pdv: {
      type: DataTypes.STRING,
      allowNull: false
    },
    canal: {
      type: DataTypes.STRING,
      defaultValue: 'General trade'
    },
    categorie_pdv: {
      type: DataTypes.STRING,
      defaultValue: 'Point de vente détail'
    },
    sous_categorie_pdv: {
      type: DataTypes.ENUM('Tabliers', 'Pushcart', 'Superette', 'Boutique', 'Kiosque', 'Cafétéria'),
      allowNull: false
    },
    autre_sous_categorie: {
      type: DataTypes.STRING,
      allowNull: true
    },
    region: {
      type: DataTypes.STRING,
      allowNull: false
    },
    territoire: {
      type: DataTypes.STRING,
      allowNull: false
    },
    zone: {
      type: DataTypes.STRING,
      allowNull: false
    },
    secteur: {
      type: DataTypes.STRING,
      allowNull: false
    },
    latitude: {
      type: DataTypes.DECIMAL(10, 8),
      allowNull: false
    },
    longitude: {
      type: DataTypes.DECIMAL(11, 8),
      allowNull: false
    },
    rayon_geofence: {
      type: DataTypes.DECIMAL(10, 2),
      defaultValue: 300.0
    },
    adressage: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    image_path: {
      type: DataTypes.STRING,
      allowNull: true
    },
    date_creation: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW
    },
    ajoute_par: {
      type: DataTypes.STRING,
      allowNull: false
    },
    mdm: {
      type: DataTypes.STRING,
      allowNull: false
    },
    actif: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    }
  }, {
    tableName: 'pdvs',
    indexes: [
      {
        fields: ['secteur']
      },
      {
        fields: ['zone']
      },
      {
        fields: ['territoire']
      },
      {
        fields: ['sous_categorie_pdv']
      },
      {
        fields: ['latitude', 'longitude']
      }
    ]
  });

  return PDV;
};