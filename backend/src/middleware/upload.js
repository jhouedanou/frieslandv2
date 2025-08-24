const multer = require('multer');
const sharp = require('sharp');
const path = require('path');
const fs = require('fs').promises;

// Storage configuration
const storage = multer.diskStorage({
  destination: async (req, file, cb) => {
    const uploadPath = 'uploads/images';
    try {
      await fs.mkdir(uploadPath, { recursive: true });
      cb(null, uploadPath);
    } catch (error) {
      cb(error);
    }
  },
  filename: (req, file, cb) => {
    // Generate unique filename
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname).toLowerCase();
    cb(null, `${file.fieldname}-${uniqueSuffix}${ext}`);
  }
});

// File filter
const fileFilter = (req, file, cb) => {
  const allowedMimeTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
  
  if (allowedMimeTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('Type de fichier non supporté. Utilisez JPG, PNG ou WebP.'), false);
  }
};

// Multer configuration
const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: parseInt(process.env.MAX_FILE_SIZE) || 5242880, // 5MB default
    files: 5 // Maximum 5 files per request
  }
});

// Middleware to process uploaded images
const processImages = async (req, res, next) => {
  if (!req.file && !req.files) {
    return next();
  }

  try {
    const files = req.files || [req.file];
    const processedFiles = [];

    for (const file of files) {
      if (file) {
        // Create optimized version
        const optimizedPath = file.path.replace(path.extname(file.path), '_optimized.webp');
        
        await sharp(file.path)
          .resize(1200, 1200, {
            fit: 'inside',
            withoutEnlargement: true
          })
          .webp({ quality: 80 })
          .toFile(optimizedPath);

        // Create thumbnail
        const thumbnailPath = file.path.replace(path.extname(file.path), '_thumb.webp');
        
        await sharp(file.path)
          .resize(300, 300, {
            fit: 'cover'
          })
          .webp({ quality: 70 })
          .toFile(thumbnailPath);

        processedFiles.push({
          ...file,
          optimizedPath,
          thumbnailPath
        });
      }
    }

    if (req.file) {
      req.file = processedFiles[0];
    } else {
      req.files = processedFiles;
    }

    next();
  } catch (error) {
    next(error);
  }
};

// Export configured upload middleware
module.exports = {
  single: (fieldName) => [upload.single(fieldName), processImages],
  array: (fieldName, maxCount) => [upload.array(fieldName, maxCount), processImages],
  fields: (fields) => [upload.fields(fields), processImages]
};