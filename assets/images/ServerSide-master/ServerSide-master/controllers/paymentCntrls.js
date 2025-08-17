const Form = require("../models/AdminModel.js");
const moment = require("moment");

exports.processCustomerPayment = async (req, res) => {
  try {
    const { customerId, schemeAmount } = req.body;

    if (!customerId || !schemeAmount) {
      return res
        .status(400)
        .json({ message: "customerId and schemeAmount are required" });
    }

    // Detect Levels
    const hasA = customerId.includes("A");
    const hasB = customerId.includes("B");
    const hasC = customerId.includes("C");

    let method = 4;
    if (hasA && hasB && hasC) method = 1;
    else if (hasA && hasB) method = 2;
    else if (hasA) method = 3;

    // Transaction ID Prefixes
    const timestamp = moment().format("YYYYMMDD_HHmmss");
    const prefixMap = {
      1: "TXN_",
      2: "TXNAG_",
      3: "TXNSH_",
      4: "TXNAD_",
    };
    const txnPrefix = `${prefixMap[method]}${timestamp}`;
    const count = await Profile.countDocuments({
      "paymentDetails.transactionId": { $regex: `^${txnPrefix}` },
    });
    const transactionId = `${txnPrefix}_${count + 1}`;
    console.log("Generated transactionId:", transactionId);

    // Form Handling
    const formId = customerId.substring(0, 3); // Always 'EMP'
    const formRecord = await Form.findOne({ customerId: formId });
    if (!formRecord) {
      return res.status(404).json({ message: "Form record not found" });
    }

    // Save 85% or 100% to Form
    if (method === 4) {
      await Form.updateOne(
        { customerId: formId },
        {
          $push: {
            paymentDetails: {
              customerId,
              amount: schemeAmount,
              transactionId,
            },
          },
        }
      );
    } else {
      const amount85 = (schemeAmount * 85) / 100;
      await Form.updateOne(
        { customerId: formId },
        {
          $push: {
            paymentDetails: {
              customerId,
              amount: amount85,
              transactionId,
            },
          },
        }
      );
    }

    // Commission Handling
    const payouts = [];

    if (method === 1 || method === 2 || method === 3) {
      const matchA = customerId.match(/(EMPA\d+)/);
      const matchB = customerId.match(/(EMPA\d+B\d+)/);
      const matchC = customerId.match(/(EMPA\d+B\d+C\d+)/);

      if (method === 1) {
        if (!matchA || !matchB || !matchC) {
          return res.status(400).json({ message: "Invalid EMPA/B/C format" });
        }
        payouts.push({ id: matchA[1], percent: 6 });
        payouts.push({ id: matchB[1], percent: 5 });
        payouts.push({ id: matchC[1], percent: 4 });
      }

      if (method === 2) {
        if (!matchA || !matchB) {
          return res.status(400).json({ message: "Invalid EMPA/B format" });
        }
        payouts.push({ id: matchA[1], percent: 5 });
        payouts.push({ id: matchB[1], percent: 10 });
      }

      if (method === 3) {
        if (!matchA) {
          return res.status(400).json({ message: "Invalid EMPA format" });
        }
        payouts.push({ id: matchA[1], percent: 15 });
      }

      // Process payouts
      for (const p of payouts) {
        const profile = await Profile.findOne({ customerId: p.id });
        if (!profile) {
          return res.status(404).json({ message: `Profile not found for ${p.id}` });
        }

        const amount = (schemeAmount * p.percent) / 100;
        await Profile.updateOne(
          { customerId: p.id },
          {
            $push: {
              paymentDetails: {
                customerId,
                amount,
                transactionId,
              },
            },
          }
        );
      }
    }

    return res.status(200).json({
      message: "Payment processed successfully!",
      transactionId,
    });
  } catch (error) {
    console.error("Payment processing error:", error);
    return res.status(500).json({ message: "Internal server error" });
  }
};