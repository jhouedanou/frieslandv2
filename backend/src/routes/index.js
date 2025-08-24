const express = require('express');
const visitesRoutes = require('./visites');
const pdvsRoutes = require('./pdvs');
const merchandisersRoutes = require('./merchandisers');
const analyticsRoutes = require('./analytics');

const router = express.Router();

// API Info
router.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'Friesland Backend API v1.0.0',
    timestamp: new Date().toISOString(),
    endpoints: {
      visites: '/visites',
      pdvs: '/pdvs',
      merchandisers: '/merchandisers',
      analytics: '/analytics'
    }
  });
});

// Routes
router.use('/visites', visitesRoutes);
router.use('/pdvs', pdvsRoutes);
router.use('/merchandisers', merchandisersRoutes);
router.use('/analytics', analyticsRoutes);

module.exports = router;