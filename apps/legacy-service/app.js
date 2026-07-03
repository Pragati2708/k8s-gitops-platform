const express = require('express');
const app = express();

app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'legacy-service' });
});

// Simulated DB (like DB2)
let accounts = {
  "1001": { name: "Pragati Singh", balance: 5000 },
  "1002": { name: "Rahul Sharma", balance: 3000 }
};

// Check balance
app.get('/api/legacy/balance/:id', (req, res) => {
  const acc = accounts[req.params.id];

  if (!acc) {
    return res.status(404).send("Account not found");
  }

  res.json({
    accountId: req.params.id,
    name: acc.name,
    balance: acc.balance
  });
});

// Debit money
app.post('/api/legacy/debit', (req, res) => {
  const { id, amount } = req.body;

  if (!accounts[id]) {
    return res.status(404).send("Account not found");
  }

  if (accounts[id].balance < amount) {
    return res.status(400).send("Insufficient funds");
  }

  if (!id || !amount || amount <= 0) {
  return res.status(400).send("Invalid debit request");
}

  accounts[id].balance -= amount;

  console.log(`Debited ₹${amount} from ${accounts[id].name}`);

  res.send("Debited successfully");
});

// Credit money
app.post('/api/legacy/credit', (req, res) => {
  const { id, amount } = req.body;

  if (!accounts[id]) {
    return res.status(404).send("Account not found");
  }
  if (!id || !amount || amount <= 0) {
  return res.status(400).send("Invalid credit request");
}

  accounts[id].balance += amount;

  console.log(`Credited ₹${amount} to ${accounts[id].name}`);

  res.send("Credited successfully");
});

app.listen(3000, () => {
  console.log("Legacy banking service running on port 3000");
});
