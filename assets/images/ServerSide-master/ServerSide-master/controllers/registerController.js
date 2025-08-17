const Form = require('../models/AdminModel.js');
const { sendOTP } = require("../utlis/sendOTP.js");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

exports.register = async (req, res) => {
  const { name, phone, email, createdBy } = req.body;

  try {
    // ✅ Cleanup expired users who don't have a password set
    await Form.deleteMany({
      otpExpiresAt: { $lt: new Date() },
      password: { $exists: false }
    });

    // ✅ Check if the user already exists
    const existing = await Form.findOne({ $or: [{ email }, { phone }] });
    if (existing) return res.status(400).send("User already exists");

    // ✅ Generate OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const otpExpiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes from now

    // ✅ Create new user
    const newUser = new Form({
      name,
      phone,
      email,
      otp,
      otpExpiresAt,
      createdBy,
    });

    await newUser.save();
    await sendOTP(email, otp);

    // Schedule cleanup for this specific user after OTP expires
    setTimeout(async () => {
      try {
        // Check if the user has set a password
        const user = await Form.findOne({ email, phone });

        if (user && !user.password) {
          // User didn't set password within the timeframe, delete them
          await Form.deleteOne({ _id: user._id });
          console.log(`User ${email} deleted due to OTP expiration without password setup`);
        } else if (user && user.password) {
          console.log(`User ${email} set password successfully, data retained`);
        }
      } catch (err) {
        console.error("Error in cleanup timeout:", err);
      }
    }, 15 * 60 * 1000 + 1000); // Check 1 second after the 15-minute expiration

    res.status(200).send("OTP sent to email");
  } catch (err) {
    console.error(err);
    res.status(500).send("Server error");
  }
};

exports.verification = async (req, res) => {
  const { email, otp, password } = req.body;

  try {
    const user = await Form.findOne({ email });
    if (!user) return res.status(400).send("User not found");

    if (user.otp !== otp || user.otpExpiresAt < new Date()) {
      return res.status(400).send("Invalid or expired OTP");
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    user.password = hashedPassword;
    user.otp = null;
    user.otpExpiresAt = null;

    await user.save();
    res.status(200).send("Account created successfully");
  } catch (err) {
    res.status(500).send("Server error");
  }
};

exports.login = async (req, res) => {
  const { phone, password } = req.body;

  try {
    const user = await Form.findOne({ phone });
    if (!user) return res.status(400).send("User not found");

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(401).send("Invalid password");

    const token = jwt.sign(
      {
        id: user._id,
        phone: user.phone,
        customerId: user.customerId,
      },
      process.env.JWT_SECRET,
    );

    res.status(200).json({
      message: "Login successful",
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        customerId: user.customerId, // optional: remove if not in your model
      },
    });
  } catch (err) {
    console.error(err);
    res.status(500).send("Server error");
  }
};
