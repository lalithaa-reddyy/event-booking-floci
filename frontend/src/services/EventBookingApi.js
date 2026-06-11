// Mock events data (seeded in DynamoDB)
const MOCK_EVENTS = [
  {
    eventId: 'event-001',
    name: 'Summer Music Festival 2026',
    description: 'Three-day electronic music festival featuring top international DJs',
    category: 'Music',
    date: '2026-07-15',
    location: 'Central Park, New York',
    capacity: 5000,
    ticketPrice: 99.99,
    ticketsSold: 0,
  },
  {
    eventId: 'event-002',
    name: 'Tech Conference 2026',
    description: 'Annual technology conference with keynote speakers',
    category: 'Technology',
    date: '2026-09-20',
    location: 'San Francisco Convention Center',
    capacity: 3000,
    ticketPrice: 299.99,
    ticketsSold: 0,
  },
  {
    eventId: 'event-003',
    name: 'Food Carnival 2026',
    description: 'Street food festival with cuisines from around the world',
    category: 'Food',
    date: '2026-08-10',
    location: 'Golden Gate Park, San Francisco',
    capacity: 2000,
    ticketPrice: 49.99,
    ticketsSold: 0,
  },
  {
    eventId: 'event-004',
    name: 'Basketball Championship 2026',
    description: 'Championship playoff game featuring top basketball teams',
    category: 'Sports',
    date: '2026-06-15',
    location: 'Madison Square Garden, New York',
    capacity: 20000,
    ticketPrice: 150.0,
    ticketsSold: 0,
  },
];

class EventBookingApi {
  static getEvents() {
    return Promise.resolve(MOCK_EVENTS);
  }

  static searchEvents(query) {
    const results = MOCK_EVENTS.filter(
      (event) =>
        event.name.toLowerCase().includes(query.toLowerCase()) ||
        event.category.toLowerCase().includes(query.toLowerCase()) ||
        event.location.toLowerCase().includes(query.toLowerCase())
    );
    return Promise.resolve(results);
  }

  static getEventDetail(eventId) {
    const event = MOCK_EVENTS.find((e) => e.eventId === eventId);
    return Promise.resolve(event);
  }

  static bookTickets(eventId, quantity) {
    const user = JSON.parse(localStorage.getItem('user') || '{}');
    const userEmail = user.email || 'demo@example.com';

    // Get API endpoint from env
    const apiEndpoint = process.env.REACT_APP_API_ENDPOINT;
    if (!apiEndpoint) {
      throw new Error('API endpoint not configured. Please set REACT_APP_API_ENDPOINT environment variable.');
    }
    const bookingEndpoint = `${apiEndpoint}/book`;

    return fetch(bookingEndpoint, {
      method: 'POST',
      mode: 'cors',
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify({
        eventId,
        quantity: parseInt(quantity),
        userEmail,
      }),
    })
      .then((response) => {
        if (!response.ok) {
          throw new Error(`API error: ${response.status} ${response.statusText}`);
        }
        return response.json();
      })
      .then((data) => {
        if (data.error) {
          throw new Error(data.error);
        }
        // Store booking in localStorage for display
        const booking = {
          bookingId: data.bookingId,
          eventName: MOCK_EVENTS.find((e) => e.eventId === eventId)?.name || 'Event',
          quantity: parseInt(quantity),
          totalPrice: data.totalPrice,
          status: data.status || 'PENDING',
        };

        const bookings = JSON.parse(localStorage.getItem('bookings') || '[]');
        bookings.push({
          ...booking,
          userId: userEmail,
          email: userEmail,
          createdAt: new Date().toISOString(),
        });
        localStorage.setItem('bookings', JSON.stringify(bookings));

        return booking;
      })
      .catch((error) => {
        console.error('Booking API error:', error);
        throw error;
      });
  }

  static getBookingHistory() {
    const bookings = JSON.parse(localStorage.getItem('bookings') || '[]');
    const totalBookings = bookings.length;
    const totalSpent = bookings.reduce((sum, b) => sum + (b.totalPrice || 0), 0);
    const confirmedBookings = bookings.filter(b => b.status === 'CONFIRMED').length;
    const processingBookings = bookings.filter(b => b.status === 'PROCESSING').length;

    return Promise.resolve({
      bookings,
      statistics: {
        totalBookings,
        totalSpent: parseFloat(totalSpent.toFixed(2)),
        confirmedBookings,
        processingBookings
      }
    });
  }
}

export default EventBookingApi;
