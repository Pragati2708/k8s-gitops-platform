const express = require('express');
const app = express();

app.use(express.json());

app.post('/notify', (req, res) => {
  const { message } = req.body;

  console.log("📩 Notification:", message);

  res.send("Notification sent");
});

app.listen(3002, () => {
  console.log("Notification service running on port 3002");
});