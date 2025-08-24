const { models } = require('../config/database');
const { Op } = require('sequelize');
const Joi = require('joi');

const { Visite, PDV } = models;

// Validation schema
const visiteSchema = Joi.object({
  pdv_id: Joi.string().uuid().required(),
  nom_du_pdv: Joi.string().required(),
  date_visite: Joi.date().required(),
  commercial: Joi.string().valid(
    'COULIBALY PADIE',
    'EBROTTIE MIAN CHRISTIAN INNOCENT',
    'GAI KAMY',
    'OUATTARA ZANGA',
    'Guea Hermann'
  ).required(),
  latitude: Joi.number().min(-90).max(90).required(),
  longitude: Joi.number().min(-180).max(180).required(),
  distance_au_pdv: Joi.number().min(0).required(),
  mdm: Joi.string().required(),
  image_path: Joi.string().allow(null, ''),
  geofence_valide: Joi.boolean().required(),
  precision_gps: Joi.number().min(0).required(),
  
  // EVAP fields
  evap_present: Joi.boolean().required(),
  evap_br_gold_present: Joi.string().valid('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture').allow(null),
  evap_br_160g_present: Joi.string().valid('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture').allow(null),
  evap_brb_160g_present: Joi.string().valid('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture').allow(null),
  evap_br_400g_present: Joi.string().valid('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture').allow(null),
  evap_brb_400g_present: Joi.string().valid('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture').allow(null),
  evap_pearl_400g_present: Joi.string().valid('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture').allow(null),
  evap_prix_respectes: Joi.boolean().required(),
  
  // IMP fields
  imp_present: Joi.boolean().required(),
  imp_br_400g_present: Joi.string().valid('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture').allow(null),
  imp_br_900g_present: Joi.string().valid('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture').allow(null),
  imp_br_2_5kg_present: Joi.string().valid('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture').allow(null),
  imp_br_375g_present: Joi.string().valid('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture').allow(null),
  imp_brb_400g_present: Joi.string().valid('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture').allow(null),
  imp_br_20g_present: Joi.string().valid('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture').allow(null),
  imp_brb_25g_present: Joi.string().valid('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture').allow(null),
  imp_prix_respectes: Joi.boolean().required(),
  
  // SCM fields
  scm_present: Joi.boolean().required(),
  scm_br_1kg_present: Joi.string().valid('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture').allow(null),
  scm_brb_1kg_present: Joi.string().valid('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture').allow(null),
  scm_brb_397g_present: Joi.string().valid('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture').allow(null),
  scm_br_397g_present: Joi.string().valid('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture').allow(null),
  scm_pearl_1kg_present: Joi.string().valid('Disponible , Prix respecté', 'Disponible , Prix non respecté', 'Présent , Prix respecté', 'En rupture').allow(null),
  scm_prix_respectes: Joi.boolean().required(),
  
  // UHT and YOGHURT fields
  uht_present: Joi.boolean().required(),
  uht_prix_respectes: Joi.boolean().required(),
  yoghurt_present: Joi.boolean().required(),
  yoghurt_prix_respectes: Joi.boolean().required()
});

class VisitesController {
  // GET /api/v1/visites
  async getAllVisites(req, res, next) {
    try {
      const {
        page = 1,
        limit = 20,
        commercial,
        secteur,
        date_debut,
        date_fin,
        geofence_valide
      } = req.query;

      const offset = (page - 1) * limit;
      const where = {};

      // Filtres
      if (commercial) where.commercial = commercial;
      if (geofence_valide !== undefined) where.geofence_valide = geofence_valide === 'true';
      
      if (date_debut && date_fin) {
        where.date_visite = {
          [Op.between]: [new Date(date_debut), new Date(date_fin)]
        };
      }

      const include = [{
        model: PDV,
        as: 'pdv',
        where: secteur ? { secteur } : undefined
      }];

      const { count, rows } = await Visite.findAndCountAll({
        where,
        include,
        order: [['date_visite', 'DESC']],
        limit: parseInt(limit),
        offset: parseInt(offset)
      });

      res.json({
        success: true,
        data: {
          visites: rows,
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
  }

  // GET /api/v1/visites/:id
  async getVisiteById(req, res, next) {
    try {
      const { id } = req.params;

      const visite = await Visite.findByPk(id, {
        include: [{
          model: PDV,
          as: 'pdv'
        }]
      });

      if (!visite) {
        return res.status(404).json({
          success: false,
          message: 'Visite non trouvée'
        });
      }

      res.json({
        success: true,
        data: { visite }
      });
    } catch (error) {
      next(error);
    }
  }

  // POST /api/v1/visites
  async createVisite(req, res, next) {
    try {
      const { error, value } = visiteSchema.validate(req.body);
      if (error) {
        return res.status(400).json({
          success: false,
          message: 'Données invalides',
          errors: error.details.map(d => d.message)
        });
      }

      // Vérifier que le PDV existe
      const pdv = await PDV.findByPk(value.pdv_id);
      if (!pdv) {
        return res.status(404).json({
          success: false,
          message: 'PDV non trouvé'
        });
      }

      // Validation géofencing côté serveur
      const distance = this.calculateDistance(
        value.latitude,
        value.longitude,
        pdv.latitude,
        pdv.longitude
      );

      if (distance > pdv.rayon_geofence) {
        value.geofence_valide = false;
      }

      const visite = await Visite.create(value);

      res.status(201).json({
        success: true,
        message: 'Visite créée avec succès',
        data: { visite }
      });
    } catch (error) {
      next(error);
    }
  }

  // PUT /api/v1/visites/:id
  async updateVisite(req, res, next) {
    try {
      const { id } = req.params;
      const { error, value } = visiteSchema.validate(req.body);
      
      if (error) {
        return res.status(400).json({
          success: false,
          message: 'Données invalides',
          errors: error.details.map(d => d.message)
        });
      }

      const visite = await Visite.findByPk(id);
      if (!visite) {
        return res.status(404).json({
          success: false,
          message: 'Visite non trouvée'
        });
      }

      await visite.update(value);

      res.json({
        success: true,
        message: 'Visite mise à jour avec succès',
        data: { visite }
      });
    } catch (error) {
      next(error);
    }
  }

  // DELETE /api/v1/visites/:id
  async deleteVisite(req, res, next) {
    try {
      const { id } = req.params;

      const visite = await Visite.findByPk(id);
      if (!visite) {
        return res.status(404).json({
          success: false,
          message: 'Visite non trouvée'
        });
      }

      await visite.destroy();

      res.json({
        success: true,
        message: 'Visite supprimée avec succès'
      });
    } catch (error) {
      next(error);
    }
  }

  // GET /api/v1/visites/analytics/kpis
  async getKPIs(req, res, next) {
    try {
      const { date_debut, date_fin } = req.query;
      const where = {};

      if (date_debut && date_fin) {
        where.date_visite = {
          [Op.between]: [new Date(date_debut), new Date(date_fin)]
        };
      }

      // Total visites
      const totalVisites = await Visite.count({ where });

      // Visites validées géofencing
      const visitesValides = await Visite.count({
        where: { ...where, geofence_valide: true }
      });

      // Présence par catégorie
      const evapPresence = await Visite.count({
        where: { ...where, evap_present: true }
      });

      const impPresence = await Visite.count({
        where: { ...where, imp_present: true }
      });

      const scmPresence = await Visite.count({
        where: { ...where, scm_present: true }
      });

      const uhtPresence = await Visite.count({
        where: { ...where, uht_present: true }
      });

      const yoghurtPresence = await Visite.count({
        where: { ...where, yoghurt_present: true }
      });

      // Prix respectés
      const prixRespectes = await Visite.count({
        where: {
          ...where,
          [Op.or]: [
            { evap_prix_respectes: true },
            { imp_prix_respectes: true },
            { scm_prix_respectes: true },
            { uht_prix_respectes: true },
            { yoghurt_prix_respectes: true }
          ]
        }
      });

      res.json({
        success: true,
        data: {
          totalVisites,
          visitesValides,
          tauxValidation: totalVisites > 0 ? (visitesValides / totalVisites * 100).toFixed(1) : 0,
          presenceProduits: {
            evap: totalVisites > 0 ? (evapPresence / totalVisites * 100).toFixed(1) : 0,
            imp: totalVisites > 0 ? (impPresence / totalVisites * 100).toFixed(1) : 0,
            scm: totalVisites > 0 ? (scmPresence / totalVisites * 100).toFixed(1) : 0,
            uht: totalVisites > 0 ? (uhtPresence / totalVisites * 100).toFixed(1) : 0,
            yoghurt: totalVisites > 0 ? (yoghurtPresence / totalVisites * 100).toFixed(1) : 0
          },
          prixRespectes: totalVisites > 0 ? (prixRespectes / totalVisites * 100).toFixed(1) : 0
        }
      });
    } catch (error) {
      next(error);
    }
  }

  // Utilitaire pour calculer la distance
  calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371e3; // Earth's radius in meters
    const φ1 = lat1 * Math.PI / 180;
    const φ2 = lat2 * Math.PI / 180;
    const Δφ = (lat2 - lat1) * Math.PI / 180;
    const Δλ = (lon2 - lon1) * Math.PI / 180;

    const a = Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
              Math.cos(φ1) * Math.cos(φ2) *
              Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return R * c;
  }
}

module.exports = new VisitesController();