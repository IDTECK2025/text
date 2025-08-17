const express = require('express');
const router = express.Router();
const {processCustomerPayment} = require('../controllers/paymentCntrls');

router.post('/processPayment', processCustomerPayment);



module.exports = router;