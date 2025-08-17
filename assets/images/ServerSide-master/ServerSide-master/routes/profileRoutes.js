const express = require('express');
const router = express.Router();
const authMiddleware = require("../utlis/authMiddleware"); 

const {createProfile,forgotPin} =require('../controllers/profileContoller')
 

router.post('/createProfile', authMiddleware, createProfile);
router.post("/forgot-pin", forgotPin);



module.exports = router;