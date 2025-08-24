const express = require('express');
const visitesController = require('../controllers/visitesController');
const upload = require('../middleware/upload');

const router = express.Router();

// Routes principales
router.get('/', visitesController.getAllVisites);
router.get('/analytics/kpis', visitesController.getKPIs);
router.get('/:id', visitesController.getVisiteById);
router.post('/', visitesController.createVisite);
router.put('/:id', visitesController.updateVisite);
router.delete('/:id', visitesController.deleteVisite);

// Upload d'images pour les visites
router.post('/:id/image', upload.single('image'), (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Aucune image fournie'
      });
    }

    res.json({
      success: true,
      message: 'Image uploadée avec succès',
      data: {
        filename: req.file.filename,
        path: req.file.path,
        url: `/uploads/${req.file.filename}`
      }
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;