const rateLimit = require('express-rate-limit');

const rateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: {
    success: false,
    message: 'Trop de requêtes, veuillez réessayer dans 15 minutes'
  },
  standardHeaders: true,
  legacyHeaders: false,
  // Skip rate limiting for trusted IPs in development
  skip: (req) => {
    if (process.env.NODE_ENV === 'development') {
      const trustedIPs = ['127.0.0.1', '::1', 'localhost'];
      return trustedIPs.includes(req.ip);
    }
    return false;
  }
});

module.exports = rateLimiter;