const express = require('express');
const axios = require('axios');

const app = express();
app.use(express.json());

const LEGACY_URL = "http://legacy-service:3000";
const NOTIFICATION_URL = "http://notification-service:3002";

app.post('/transfer', async (req, res) => {
  const { from, to, amount } = req.body;

  try {
    console.log(`Initiating transfer ₹${amount} from ${from} to ${to}`);

    // Debit
    await axios.post(`${LEGACY_URL}/debit`, {
      id: from,
      amount: amount
    });

    // Credit
    await axios.post(`${LEGACY_URL}/credit`, {
      id: to,
      amount: amount
    });

    // Notify
    await axios.post(`${NOTIFICATION_URL}/notify`, {
      message: `₹${amount} transferred from ${from} to ${to}`
    });

    console.log("Transaction successful + Notification sent");

    res.send("Transaction successful");

  } catch (error) {
    console.log("Transaction failed:", error.message);
    res.status(500).send("Transaction failed");
  }
});

app.listen(3001, () => {
  console.log("Transaction service running on port 3001");
});