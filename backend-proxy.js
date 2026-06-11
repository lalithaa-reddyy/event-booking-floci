const express = require('express');
const app = express();

app.use(express.json());

// CORS middleware
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', 'Content-Type');
  res.header('Access-Control-Allow-Methods', 'GET,POST,OPTIONS');
  
  if (req.method === 'OPTIONS') {
    return res.sendStatus(200);
  }
  next();
});

// Mock endpoints (replace with real Lambda calls if needed)
app.get('/events', (req, res) => {
  res.json({ events: [
    { eventId: 'event-001', name: 'Summer Music Festival 2026', ticketPrice: 99.99, capacity: 5000, date: '2026-07-15' },
    { eventId: 'event-002', name: 'Tech Conference 2026', ticketPrice: 299.99, capacity: 3000, date: '2026-09-20' },
    { eventId: 'event-003', name: 'Food Carnival 2026', ticketPrice: 49.99, capacity: 2000, date: '2026-08-10' },
    { eventId: 'event-004', name: 'Basketball Championship 2026', ticketPrice: 150.00, capacity: 20000, date: '2026-06-15' }
  ]});
});

app.post('/book', (req, res) => {
  const { eventId, quantity, userEmail } = req.body;
  res.json({ 
    success: true, 
    bookingId: 'BOOK-' + Date.now(),
    totalPrice: quantity * 99.99,
    status: 'PENDING'
  });
});

app.get('/history', (req, res) => {
  res.json({ bookings: [] });
});

app.listen(3001, () => console.log('Proxy running on http://localhost:3001'));
