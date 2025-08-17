const nodemailer = require("nodemailer");

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

const sendLoginSuccessEmail = async (to, name, profileType) => {
  const mailOptions = {
    from: `"EMP GOLD" <${process.env.EMAIL_USER}>`,
    to,
    subject: `EMP GOLD JEWELLERY Login Successful - EMP`,
    html: `
      <div style="font-family: 'Segoe UI', sans-serif; max-width: 600px; margin: auto; border: 1px solid #e8e8e8; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 8px rgba(0,0,0,0.05);">
        <div style="background: linear-gradient(90deg, #ffd700, #e5c100); color: white; padding: 20px 30px;">
          <h2 style="margin: 0;">💎 EMP GOLD JEWELLERY</h2>
          <p style="margin: 5px 0 0;">EMP – Secure Login Notification</p>
        </div>
        <div style="padding: 30px;">
          <h3 style="color: #333;">Dear ${name},</h3>
          <p style="color: #444;">You have successfully logged into your <strong style="color: #d4af37;">EMP GOLD JEWELLERY</strong> account under <strong> EMP GOLD </strong>.</p>
          <div style="margin: 20px 0;">
            <p style="color: #555;">✅ Login Successful<br/>🕒 ${new Date().toLocaleString()}</p>
          </div>
          <p style="color: #666;">
            If this action wasn't initiated by you, please contact our support team immediately to ensure the security of your account.
          </p>
          <div style="margin-top: 30px;">
            <a href="https://empgold.online/" style="padding: 10px 20px; background-color: #d4af37; color: white; text-decoration: none; border-radius: 5px;">Go to Dashboard</a>
          </div>
        </div>
        <div style="background-color: #f4f4f4; text-align: center; padding: 15px; font-size: 13px; color: #888;">
          &copy; ${new Date().getFullYear()} EMPAIR MARKETING PVT LTD. All rights reserved.
        </div>
      </div>
    `,
  };

  await transporter.sendMail(mailOptions);
};

module.exports = { sendLoginSuccessEmail };