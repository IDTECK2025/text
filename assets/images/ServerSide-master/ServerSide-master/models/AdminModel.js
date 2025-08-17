const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  name: String,
  phone: {
    type: String,
    required: true,
    unique: true,
  },
  email: {
    type: String,
    required: true,
    unique: true,
  },
  password: String,
  otp: String,
  otpExpiresAt: Date,
  customerId: {
    type: String,
    default: 'EMP',
  },
  admissionFee: [{
    customerId: String,
    amount: Number,
    date: {
      type: Date,
      default: Date.now,
    },
  }],
  paymentDetails: [{
    customerId: String,
    amount: Number,
    transactionId: String, 
    date: {
      type: Date,
      default: Date.now,
    },
  }],
});

module.exports = mongoose.model('users', UserSchema);
