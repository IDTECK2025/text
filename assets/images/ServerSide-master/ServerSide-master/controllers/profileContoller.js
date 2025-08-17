const Profile = require("../models/ProfileModel");
const generateCustomerId = require("../utlis/GenerateID.js");
const AdminProfile = require("../models/AdminModel");
const uploadSignature = require("../utlis/uploadSignature.js");
const { sendLoginPIN ,sendPinUpdateNotification} = require("../utlis/sendOTP.js");

exports.createProfile = async (req, res) => {
  try {
    const profileType = req.body.profileType;

    console.log("➡️ Profile Type:", profileType);
    console.log("➡️ Request Body:", req.body);
    console.log("➡️ Request User:", req.user);

    if (!req.files?.signature) {
      return res.status(400).json({ error: "No signature file uploaded" });
    }

    // Upload signature and get URL
    const signatureUrl = await uploadSignature(req.files.signature);

    // Generate customer ID
    const baseId = req.user?.customerId;
    console.log("🆔 baseId used for ID generation:", baseId);

    const customerId = await generateCustomerId(baseId, profileType);
    console.log("✅ Generated customerId:", customerId);

    // Generate random 4-digit PIN
    const pin = Math.floor(1000 + Math.random() * 9000);

    // Determine amount based on profile type
    const amount =
      profileType === "customer"
        ? 100
        : profileType === "agent"
          ? 250
          : profileType === "subagent"
            ? 100
            : 100;

    // Create new profile
    const profile = new Profile({
      profileType,
      customerId,
      createdBy: req.user?.id, // ✅ Set createdBy field
      ...req.body,
      amount,
      signatureUrl,
      pin,
    });

    await profile.save(); // Save profile

    // ✅ Push customerId and amount to admin's admissionFee array
    await AdminProfile.findOneAndUpdate(
      { customerId: 'EMP' }, // Use baseId instead of _id
      {
        $push: {
          admissionFee: {
            customerId,
            amount,
          },
        },
      },
      { new: true }
    );


    // Send PIN if email is provided
    if (req.body.email) {
      await sendLoginPIN(req.body.email, pin);
    }

    console.log("✅ Profile saved successfully:", customerId);

    return res.status(201).json({
      message: `${profileType} profile created successfully ✅`,
      customerId,
    });
  } catch (err) {
    console.error("❌ Error creating profile:", err);
    res.status(500).json({ error: "Server error occurred" });
  }
};


exports.forgotPin = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ error: "Email is required" });
    }

    // Check if user with email exists
    const profile = await Profile.findOne({ email });

    if (!profile) {
      return res.status(404).json({ error: "Profile with this email not found" });
    }

    // Generate new 4-digit PIN
    const newPin = Math.floor(1000 + Math.random() * 9000);

    // Update PIN in database
    profile.pin = newPin;
    await profile.save();

    // Send the new PIN via email
    await sendPinUpdateNotification(email, newPin);

    console.log(`✅ New PIN sent to ${email}: ${newPin}`);

    return res.status(200).json({
      message: "New PIN has been sent to your email",
    });
  } catch (err) {
    console.error("❌ Error resetting PIN:", err);
    return res.status(500).json({ error: "Server error occurred" });
  }
};