const express = require('express');
const { models } = require('../config/database');
const { Op } = require('sequelize');

const router = express.Router();
const { PDV } = models;

// GET /api/v1/pdvs
router.get('/', async (req, res, next) => {
  try {
    const {
      page = 1,
      limit = 50,
      secteur,
      zone,
      sous_categorie_pdv,
      search
    } = req.query;

    const offset = (page - 1) * limit;
    const where = { actif: true };

    // Filtres
    if (secteur) where.secteur = secteur;
    if (zone) where.zone = zone;
    if (sous_categorie_pdv) where.sous_categorie_pdv = sous_categorie_pdv;
    if (search) {
      where.nom_pdv = {
        [Op.iLike]: `%${search}%`
      };
    }

    const { count, rows } = await PDV.findAndCountAll({
      where,
      order: [['nom_pdv', 'ASC']],
      limit: parseInt(limit),
      offset: parseInt(offset)
    });

    res.json({
      success: true,
      data: {
        pdvs: rows,
        pagination: {
          currentPage: parseInt(page),
          totalPages: Math.ceil(count / limit),
          totalItems: count,
          itemsPerPage: parseInt(limit)
        }
      }
    });
  } catch (error) {
    next(error);
  }
});

// GET /api/v1/pdvs/:id
router.get('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;

    const pdv = await PDV.findByPk(id, {
      include: [{
        model: models.Visite,
        as: 'visites',
        limit: 5,
        order: [['date_visite', 'DESC']]
      }]
    });

    if (!pdv) {
      return res.status(404).json({
        success: false,
        message: 'PDV non trouvé'
      });
    }

    res.json({
      success: true,
      data: { pdv }
    });
  } catch (error) {
    next(error);
  }
});

// GET /api/v1/pdvs/nearby/:lat/:lng
router.get('/nearby/:lat/:lng', async (req, res, next) => {
  try {
    const { lat, lng } = req.params;
    const { radius = 5000, limit = 20 } = req.query;

    // Using Haversine formula in raw SQL for better performance
    const pdvs = await PDV.findAll({
      attributes: {
        include: [
          [
            sequelize.literal(`
              6371000 * acos(
                cos(radians(${lat})) * 
                cos(radians(latitude)) * 
                cos(radians(longitude) - radians(${lng})) + 
                sin(radians(${lat})) * 
                sin(radians(latitude))
              )
            `),
            'distance'
          ]
        ]
      },
      having: sequelize.literal(`distance <= ${radius}`),
      order: sequelize.literal('distance ASC'),
      limit: parseInt(limit),
      where: { actif: true }
    });

    res.json({
      success: true,
      data: { pdvs }
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;