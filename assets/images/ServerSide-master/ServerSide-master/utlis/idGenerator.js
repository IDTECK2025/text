const Profile = require('../models/ProfileModel');

const getNextLetter = (char) => {
  // If no char or at 'Z', wrap back to 'A'
  if (!char || char === 'Z') return 'A';
  return String.fromCharCode(char.charCodeAt(0) + 1);
};

const generateCustomerId = async (profileType, baseId = null) => {
  //
  // ── CASE 1: CUSTOMER ───────────────────────────────────────────────────
  //
  if (profileType === 'customer') {
    const prefix = 'EMPZZ';
    // find the highest existing EMPZZ###  
    const last = await Profile.findOne({
      profileType: 'customer',
      customerId: { $regex: `^${prefix}\\d{3}$` }
    })
      .sort({ customerId: -1 })
      .select('customerId');

    if (!last) {
      return `${prefix}001`;
    }

    const lastNum = parseInt(last.customerId.slice(prefix.length), 10);
    const nextNum = (lastNum + 1).toString().padStart(3, '0');
    return `${prefix}${nextNum}`;
  }

  //
  // ── CASE 2: SHAREHOLDER or AGENT ───────────────────────────────────────
  //
  if ((profileType === 'shareholder' || profileType === 'agent') && !baseId) {
    baseId = 'EMP';
  }

  //
  // ── CASE 3: SUBAGENT or USER ───────────────────────────────────────────
  //
  if ((profileType === 'subagent' || profileType === 'user') && !baseId) {
    throw new Error(
      `Base ID is required to generate a '${profileType}' ID; pass the parent customerId`
    );
  }

  //
  // ── VALIDATE we now have a baseId ──────────────────────────────────────
  //
  if (!baseId) {
    throw new Error(
      `Unknown profileType '${profileType}'; cannot generate customerId without a baseId`
    );
  }

  //
  // ── BUILD REGEX & FETCH ALL MATCHES ───────────────────────────────────
  //
  const idRegex = new RegExp(`^${baseId}(\\d+)([A-Z])$`);

  // **NO** profileType filter here: scan every existing ID namespace
  const profiles = await Profile.find({
    customerId: { $regex: idRegex }
  }).select('customerId');

  //
  // ── FIRST‐TIME SEED (no prior IDs with this base) ─────────────────────
  //
  if (profiles.length === 0) {
    // take last char of `baseId`, bump to next letter, start at “1”
    const lastChar = baseId[baseId.length - 1];
    const nextLetter = getNextLetter(lastChar);
    return `${baseId}1${nextLetter}`;
  }

  //
  // ── REUSE THE SAME LETTER, JUST INCREMENT THE NUMBER ─────────────────
  //
  let maxNumber = 0;
  let consistentLetter = null;

  for (const { customerId } of profiles) {
    const [, numPart, letterPart] = customerId.match(idRegex);
    const num = parseInt(numPart, 10);
    if (num > maxNumber) {
      maxNumber = num;
      consistentLetter = letterPart;
    }
  }

  const nextNumber = maxNumber + 1;
  return `${baseId}${nextNumber}${consistentLetter}`;
};

module.exports = generateCustomerId;

