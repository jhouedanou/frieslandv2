const express = require('express');
const { models } = require('../config/database');

const router = express.Router();
const { Merchandiser } = models;

// GET /api/v1/merchandisers
router.get('/', async (req, res, next) => {
  try {
    const merchandisers = await Merchandiser.findAll({
      order: [['nom', 'ASC']]
    });

    res.json({
      success: true,
      data: { merchandisers }
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;