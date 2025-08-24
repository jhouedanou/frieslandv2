const express = require('express');
const { models, sequelize } = require('../config/database');
const { Op } = require('sequelize');

const router = express.Router();
const { Visite, PDV } = models;

// GET /api/v1/analytics/dashboard
router.get('/dashboard', async (req, res, next) => {
  try {
    const { date_debut, date_fin } = req.query;
    const where = {};

    if (date_debut && date_fin) {
      where.date_visite = {
        [Op.between]: [new Date(date_debut), new Date(date_fin)]
      };
    }

    // KPIs principaux
    const totalVisites = await Visite.count({ where });
    const visitesValides = await Visite.count({
      where: { ...where, geofence_valide: true }
    });

    // Présence par catégorie
    const productPresence = await Visite.findAll({
      attributes: [
        [sequelize.fn('COUNT', sequelize.col('evap_present')), 'evap_count'],
        [sequelize.fn('COUNT', sequelize.col('imp_present')), 'imp_count'],
        [sequelize.fn('COUNT', sequelize.col('scm_present')), 'scm_count'],
        [sequelize.fn('COUNT', sequelize.col('uht_present')), 'uht_count'],
        [sequelize.fn('COUNT', sequelize.col('yoghurt_present')), 'yoghurt_count'],
      ],
      where: {
        ...where,
        [Op.or]: [
          { evap_present: true },
          { imp_present: true },
          { scm_present: true },
          { uht_present: true },
          { yoghurt_present: true }
        ]
      }
    });

    // Performance par commercial
    const commercialStats = await Visite.findAll({
      attributes: [
        'commercial',
        [sequelize.fn('COUNT', sequelize.col('commercial')), 'total_visites'],
        [sequelize.fn('COUNT', sequelize.col('geofence_valide')), 'visites_valides']
      ],
      where,
      group: ['commercial'],
      order: [[sequelize.fn('COUNT', sequelize.col('commercial')), 'DESC']]
    });

    // Alertes (prix non respectés, ruptures)
    const alertes = await Visite.findAll({
      where: {
        ...where,
        [Op.or]: [
          { evap_prix_respectes: false, evap_present: true },
          { imp_prix_respectes: false, imp_present: true },
          { scm_prix_respectes: false, scm_present: true },
          { uht_prix_respectes: false, uht_present: true },
          { yoghurt_prix_respectes: false, yoghurt_present: true }
        ]
      },
      include: [{
        model: PDV,
        as: 'pdv',
        attributes: ['nom_pdv', 'secteur']
      }],
      order: [['date_visite', 'DESC']],
      limit: 10
    });

    res.json({
      success: true,
      data: {
        kpis: {
          totalVisites,
          visitesValides,
          tauxValidation: totalVisites > 0 ? (visitesValides / totalVisites * 100).toFixed(1) : 0
        },
        productPresence: productPresence[0] || {},
        commercialStats,
        alertes
      }
    });
  } catch (error) {
    next(error);
  }
});

// GET /api/v1/analytics/commercial/:commercial
router.get('/commercial/:commercial', async (req, res, next) => {
  try {
    const { commercial } = req.params;
    const { date_debut, date_fin } = req.query;
    const where = { commercial };

    if (date_debut && date_fin) {
      where.date_visite = {
        [Op.between]: [new Date(date_debut), new Date(date_fin)]
      };
    }

    // Stats du commercial
    const totalVisites = await Visite.count({ where });
    const visitesValides = await Visite.count({
      where: { ...where, geofence_valide: true }
    });

    // Évolution dans le temps
    const evolution = await Visite.findAll({
      attributes: [
        [sequelize.fn('DATE', sequelize.col('date_visite')), 'date'],
        [sequelize.fn('COUNT', sequelize.col('visite_id')), 'visites']
      ],
      where,
      group: [sequelize.fn('DATE', sequelize.col('date_visite'))],
      order: [[sequelize.fn('DATE', sequelize.col('date_visite')), 'ASC']]
    });

    // Répartition par type de PDV
    const pdvTypes = await Visite.findAll({
      attributes: [
        [sequelize.col('pdv.sous_categorie_pdv'), 'type'],
        [sequelize.fn('COUNT', sequelize.col('visite_id')), 'count']
      ],
      include: [{
        model: PDV,
        as: 'pdv',
        attributes: []
      }],
      where,
      group: [sequelize.col('pdv.sous_categorie_pdv')],
      order: [[sequelize.fn('COUNT', sequelize.col('visite_id')), 'DESC']]
    });

    res.json({
      success: true,
      data: {
        commercial,
        totalVisites,
        visitesValides,
        tauxValidation: totalVisites > 0 ? (visitesValides / totalVisites * 100).toFixed(1) : 0,
        evolution,
        pdvTypes
      }
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;