const mongoose = require('mongoose');
const { type } = require('os');

const profileSchema = new mongoose.Schema({
  profileType: {
    type: String,
    enum: ['shareholder', 'customer', 'agent', 'subagent'],
    required: true
  },
  customerId: {
    type: String,
    unique: true,
    sparse: true
  },
  name: { type: String, required: true },
  lastName: { type: String, required: true },
  panNumber: { type: String, required: true },
  state: { type: String, required: true },
  address: { type: String, required: true },
  country: { type: String, required: true },
  nominee: { type: String, required: true },
  post_code: { type: String, required: true },
  district: { type: String, required: true },
  aadhaarNumber: { type: String, required: true },
  nominieeNumber: { type: String, required: true },
  contactNumber: { type: String, required: true },
  email: { type: String, unique: true, required: true },
  pin: { type: String, unique: true, required: true },
  dob: { type: Date, required: true },
  signatureUrl: { type: String, required: true },

  // 👇 New conditionally required fields
  schemeType: {
    type: String,
    required: function () {
      return this.profileType === 'customer' || this.profileType === 'user';
    }
  },
  schemeDate: {
    type: Date,
    required: function () {
      return this.profileType === 'customer' || this.profileType === 'user';
    }
  },

  createdAt: { type: Date, default: Date.now },
  createdBy: { type: String, required: true },
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


profileSchema.index({ customerId: 1 });

module.exports = mongoose.model('profileDetails', profileSchema);