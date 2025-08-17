const Profile = require('../models/ProfileModel');

const profileTypeMap = {
  shareholder: 'A',
  agent: 'B',
  subagent: 'C',
  customer: 'ZZ',
};

const generateCustomerId = async (cusId, profileType) => {
  const suffix = profileTypeMap[profileType];
  if (!suffix) {
    throw new Error(`Unsupported profileType '${profileType}'`);
  }

  // Build regex to match pattern like: EMPA12, EMPB5, EMPZZ1, etc.
  const regex = new RegExp(`^${cusId}${suffix}(\\d+)$`);

  // Find all matching IDs
  const profiles = await Profile.find({
    customerId: { $regex: regex }
  }).select('customerId');

  let maxNumber = 0;

  for (const { customerId } of profiles) {
    const match = customerId.match(regex);
    if (match) {
      const num = parseInt(match[1], 10);
      if (num > maxNumber) {
        maxNumber = num;
      }
    }
  }

  const nextNumber = maxNumber + 1;
  return `${cusId}${suffix}${nextNumber}`;
};

module.exports = generateCustomerId;
