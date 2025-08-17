const express = require('express');
const router = express.Router();
const {universalLogin,getProfilesDetails,getDetails} = require('../controllers/adminProfileCntrl');

router.post('/alllogin', universalLogin);

router.get('/profilesDetails', getProfilesDetails);
router.get('/getdetails', getDetails);


module.exports = router;
