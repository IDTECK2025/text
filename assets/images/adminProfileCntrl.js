const Profile = require("../models/ProfileModel.js");
const Admin = require("../models/AdminModel.js");
const jwt = require("jsonwebtoken");

exports.universalLogin = async (req, res) => {
  try {
    const { email, pin } = req.body;
    const profileType = req.path.split("-")[0].substring(1);

    if (!email || !pin) {
      return res.status(400).json({ error: "Email and PIN are required" });
    }

    const profileTypeMap = {
      subagent: "subagent",
      shareholder: "shareholder",
      agent: "agent",
      customer: "customer", 
    };

    const user = await Profile.findOne({
      email,
      pin,
      profileType: profileTypeMap[profileType] || profileType,
    });

    if (!user) {
      return res.status(401).json({ error: "Invalid email or PIN" });
    }

    // 🔍 Fetch matching paymentDetails from both models
    const customerId = user.customerId;

    // From Profile model
    const profilePayments = await Profile.aggregate([
      { $unwind: "$paymentDetails" },
      { $match: { "paymentDetails.customerId": customerId } },
      {
        $project: {
          _id: 0,
          amount: "$paymentDetails.amount",
          transactionId: "$paymentDetails.transactionId",
          date: "$paymentDetails.date",
        },
      },
    ]);

    // From Admin model
    const adminPayments = await Admin.aggregate([
      { $unwind: "$paymentDetails" },
      { $match: { "paymentDetails.customerId": customerId } },
      {
        $project: {
          _id: 0,
          amount: "$paymentDetails.amount",
          transactionId: "$paymentDetails.transactionId",
          date: "$paymentDetails.date",
        },
      },
    ]);

    const allPayments = [...profilePayments, ...adminPayments];
    const totalPaidAmount = allPayments.reduce((sum, payment) => {
      return sum + (Number(payment.amount) || 0);
    }, 0);

    const token = jwt.sign(
      {
        id: user._id,
        email: user.email,
        name: user.name,
        customerId: user.customerId,
        profileType: user.profileType,
      },
      process.env.JWT_SECRET,
      { expiresIn: "2h" }
    );

    return res.status(200).json({
      message: `${user.profileType} login successful ✅`,
      token,
      user: {
        name: user.name,
        lastName: user.lastName,
        panNumber: user.panNumber,
        state: user.state,
        address: user.address,
        country: user.country,
        nominee: user.nominee,
        post_code: user.post_code,
        district: user.district,
        aadhaarNumber: user.aadhaarNumber,
        nominieeNumber: user.nominieeNumber,
        contactNumber: user.contactNumber,
        email: user.email,
        dob: user.dob,
        signatureUrl: user.signatureUrl,
        customerId: user.customerId,
        profileType: user.profileType,
        schemeType: user.schemeType,
        schemeDate: user.schemeDate,
        membershipFee: user.membershipFee,
        createdAt: user.createdAt,
        paymentDetails: allPayments, // merged from both models
        totalPaidAmount,
      },
    });

  } catch (err) {
    console.error(`❌ ${req.path} Login error:`, err);
    res.status(500).json({ error: "Server error" });
  }
};


// exports.universalLogin = async (req, res) => {
//   try {
//     const { email, pin } = req.body;
//     const profileType = req.path.split("-")[0].substring(1);

//     if (!email || !pin) {
//       return res.status(400).json({ error: "Email and PIN are required" });
//     }

//     const profileTypeMap = {
//       subagent: "subagent",
//       shareholder: "shareholder",
//       agent: "agent",
//       customer: "customer", 
//     };

//     const user = await Profile.findOne({
//       email,
//       pin,
//       profileType: profileTypeMap[profileType] || profileType,
//     });

//     if (!user) {
//       return res.status(401).json({ error: "Invalid email or PIN" });
//     }

//     const totalPaidAmount = user.paymentDetails?.reduce((sum, payment) => {
//       return sum + (Number(payment.amount) || 0);
//     }, 0);

//     const token = jwt.sign(
//       {
//         id: user._id,
//         email: user.email,
//         name: user.name,
//         customerId: user.customerId,
//         profileType: user.profileType,
//       },
//       process.env.JWT_SECRET,
//       { expiresIn: "2h" }
//     );

//     return res.status(200).json({
//       message: `${user.profileType} login successful ✅`,
//       token,
//       user: {
//         name: user.name,
//         lastName: user.lastName,
//         panNumber: user.panNumber,
//         state: user.state,
//         address: user.address,
//         country: user.country,
//         nominee: user.nominee,
//         post_code: user.post_code,
//         district: user.district,
//         aadhaarNumber: user.aadhaarNumber,
//         nominieeNumber: user.nominieeNumber,
//         contactNumber: user.contactNumber,
//         email: user.email,
//         dob: user.dob,
//         signatureUrl: user.signatureUrl,
//         customerId: user.customerId,
//         profileType: user.profileType,
//         schemeType: user.schemeType,
//         schemeDate: user.schemeDate,
//         membershipFee: user.membershipFee,
//         createdAt: user.createdAt,
//         paymentDetails: user.paymentDetails,
//         totalPaidAmount,
//       },
//     });
    
//   } catch (err) {
//     console.error(`❌ ${req.path} Login error:`, err);
//     res.status(500).json({ error: "Server error" });
//   }
// };

exports.getProfilesDetails = async (req, res) => {
  try {
    const { page = 1, limit = 10, profileType } = req.query;

    const query = {};

    if (profileType) {
      query.profileType = profileType;
    }

    const totalProfiles = await Profile.countDocuments(query);

    const profiles = await Profile.find(query)
      .skip((page - 1) * limit)
      .limit(parseInt(limit));

    res.status(200).json({
      profiles,
      totalPages: Math.ceil(totalProfiles / limit),
      currentPage: Number(page),
      totalProfiles,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server Error while fetching profiles" });
  }
};

exports.getDetails = async (req, res) => {
  try {
    const { page = 1, limit = 10, profileType, customerId } = req.query;

    const query = {};
    if (profileType) {
      query.profileType = profileType;
    }

    if (customerId) {
      // Regex to match customerId like EMP33A24B1A, EMP33A24B2A etc.
      const regex = new RegExp(`^${customerId}\\d+[A-Z]$`);
      query.customerId = regex;

      const matchedProfiles = await Profile.find({ customerId: regex });

      if (!matchedProfiles.length) {
        return res.status(404).json({
          message: `No customerIds found matching pattern for base ID '${customerId}'`
        });
      }

      // Extract number-letter suffixes
      const suffixes = matchedProfiles.map(p => {
        const match = p.customerId.match(new RegExp(`^${customerId}(\\d+)([A-Z])$`));
        return match ? { num: parseInt(match[1]), letter: match[2] } : null;
      }).filter(Boolean);

      const letters = suffixes.map(s => s.letter);
      const highestLetter = letters.sort().reverse()[0];

      const nextLetter = String.fromCharCode(highestLetter.charCodeAt(0) + 1);
      const nextIdRegex = new RegExp(`^${customerId}\\d+${nextLetter}$`);
      const existsNext = await Profile.findOne({ customerId: nextIdRegex });

      // console.log("Matched full profiles:", matchedProfiles);

      if (existsNext) {
        return res.status(200).json({
          message: `Next ID with suffix '${nextLetter}' already exists. Stopping.`,
          stopAt: nextLetter,
          matchedProfiles
        });
      } else {
        return res.status(200).json({
          message: `Next ID can be with suffix '${nextLetter}'`,
          nextLetter,
          matchedProfiles
        });
      }
    }

    // Regular pagination logic
    const totalProfiles = await Profile.countDocuments(query);
    const profiles = await Profile.find(query)
      .skip((page - 1) * limit)
      .limit(parseInt(limit));

    res.status(200).json({
      profiles,
      totalPages: Math.ceil(totalProfiles / limit),
      currentPage: Number(page),
      totalProfiles,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server Error while fetching profiles" });
  }
};
