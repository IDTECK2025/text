const express = require('express');
const router = express.Router();

const { register ,verification ,login} = require('../controllers/registerController.js');

router.post("/register", register);
router.post("/verify-otp", verification);
router.post("/login", login);

module.exports = router;