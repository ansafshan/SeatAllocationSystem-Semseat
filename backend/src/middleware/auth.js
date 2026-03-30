const jwt = require('jsonwebtoken');
const User = require('../models/User');

const protect = async (req, res, next) => {
  // Allow preflight requests to pass without authentication
  if (req.method === 'OPTIONS') {
    return next();
  }

  try {
    let token;

    // Express normalizes all headers to lowercase keys
    const authHeader = req.headers['authorization'];
    console.log(`AUTH_DEBUG: Request to ${req.method} ${req.originalUrl}`);
    console.log(`AUTH_DEBUG: Auth Header: ${authHeader ? 'Found' : 'Missing'}`);

    if (authHeader) {
      if (authHeader.toLowerCase().startsWith('bearer ')) {
        token = authHeader.split(' ')[1];
        console.log(`AUTH_DEBUG: Token extracted from Bearer`);
      } else if (!authHeader.includes(' ')) {
        // Fallback for tokens sent without "Bearer" prefix
        token = authHeader;
        console.log(`AUTH_DEBUG: Token extracted from direct header`);
      }
    }

    if (!token) {
      console.error(`[AUTH ERROR] No token found in headers for ${req.method} ${req.originalUrl}`);
      console.log('AUTH_DEBUG: Full Headers:', JSON.stringify(req.headers, null, 2));
      return res.status(401).json({ message: 'Not authorized, no token' });
    }

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Get user from the token
    req.user = await User.findByPk(decoded.id, {
      attributes: { exclude: ['password_hash'] }
    });

    if (!req.user) {
      console.error(`[AUTH ERROR] User ${decoded.id} not found`);
      return res.status(401).json({ message: 'Not authorized, user not found' });
    }

    next();
  } catch (error) {
    console.error(`[AUTH ERROR] ${error.message}`);
    return res.status(401).json({ message: 'Not authorized, token failed' });
  }
};

const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({
        message: `User role ${req.user ? req.user.role : 'unknown'} is not authorized to access this route`
      });
    }
    next();
  };
};

module.exports = { protect, authorize };
