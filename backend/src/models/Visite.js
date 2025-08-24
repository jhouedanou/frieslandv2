const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Visite = sequelize.define('Visite', {
    visite_id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    pdv_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'pdvs',
        key: 'pdv_id'
      }
    },
    nom_du_pdv: {
      type: DataTypes.STRING,
      allowNull: false
    },
    date_visite: {
      type: DataTypes.DATE,
      allowNull: false
    },
    commercial: {
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
    distance_au_pdv: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false
    },
    mdm: {
      type: DataTypes.STRING,
      allowNull: false
    },
    image_path: {
      type: DataTypes.STRING,
      allowNull: true
    },
    geofence_valide: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    precision_gps: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false
    },

    // EVAP (Lait évaporé)
    evap_present: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    evap_br_gold_present: {
      type: DataTypes.ENUM('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture'),
      allowNull: true
    },
    evap_br_160g_present: {
      type: DataTypes.ENUM('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture'),
      allowNull: true
    },
    evap_brb_160g_present: {
      type: DataTypes.ENUM('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture'),
      allowNull: true
    },
    evap_br_400g_present: {
      type: DataTypes.ENUM('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture'),
      allowNull: true
    },
    evap_brb_400g_present: {
      type: DataTypes.ENUM('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture'),
      allowNull: true
    },
    evap_pearl_400g_present: {
      type: DataTypes.ENUM('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture'),
      allowNull: true
    },
    evap_prix_respectes: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },

    // IMP (Lait en poudre)
    imp_present: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    imp_br_400g_present: {
      type: DataTypes.ENUM('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture'),
      allowNull: true
    },
    imp_br_900g_present: {
      type: DataTypes.ENUM('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture'),
      allowNull: true
    },
    imp_br_2_5kg_present: {
      type: DataTypes.ENUM('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture'),
      allowNull: true
    },
    imp_br_375g_present: {
      type: DataTypes.ENUM('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture'),
      allowNull: true
    },
    imp_brb_400g_present: {
      type: DataTypes.ENUM('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture'),
      allowNull: true
    },
    imp_br_20g_present: {
      type: DataTypes.ENUM('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture'),
      allowNull: true
    },
    imp_brb_25g_present: {
      type: DataTypes.ENUM('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture'),
      allowNull: true
    },
    imp_prix_respectes: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },

    // SCM (Lait concentré sucré)
    scm_present: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    scm_br_1kg_present: {
      type: DataTypes.ENUM('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture'),
      allowNull: true
    },
    scm_brb_1kg_present: {
      type: DataTypes.ENUM('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture'),
      allowNull: true
    },
    scm_brb_397g_present: {
      type: DataTypes.ENUM('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture'),
      allowNull: true
    },
    scm_br_397g_present: {
      type: DataTypes.ENUM('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture'),
      allowNull: true
    },
    scm_pearl_1kg_present: {
      type: DataTypes.ENUM('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture'),
      allowNull: true
    },
    scm_prix_respectes: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },

    // UHT (Lait UHT)
    uht_present: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    uht_prix_respectes: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },

    // YOGHURT (Yaourt)
    yoghurt_present: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    yoghurt_prix_respectes: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    }
  }, {
    tableName: 'visites',
    indexes: [
      {
        fields: ['commercial']
      },
      {
        fields: ['date_visite']
      },
      {
        fields: ['pdv_id']
      },
      {
        fields: ['geofence_valide']
      }
    ]
  });

  return Visite;
};