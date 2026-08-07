const express = require('express');
const pool = require('../db/pool');
const redisClient = require('../utils/redis');
const auth = require('../middleware/auth');

const router = express.Router();

// ============================================
// 5. Search Tickets
// ============================================
router.get('/search', async (req, res) => {
    try {
        const { sport_type, city, home_team, away_team, seat_category, min_price, max_price } = req.query;

        // Check cache first (Redis)
        const cacheKey = `search:${JSON.stringify(req.query)}`;
        const cached = await redisClient.getCache(cacheKey);
        if (cached) {
            return res.json(JSON.parse(cached));
        }

        // SQL query
        let query = `
            SELECT t.id, m.sport_type, m.home_team, m.away_team, m.event_date, 
                   m.venue_city, t.seat_category, t.price, t.remaining
            FROM tickets t
            JOIN matches m ON t.match_id = m.id
            WHERE 1=1
        `;
        const params = [];
        let paramIndex = 1;

        if (sport_type) {
            query += ` AND m.sport_type = $${paramIndex++}`;
            params.push(sport_type);
        }
        if (city) {
            query += ` AND m.venue_city ILIKE $${paramIndex++}`;
            params.push(`%${city}%`);
        }
        if (home_team) {
            query += ` AND m.home_team ILIKE $${paramIndex++}`;
            params.push(`%${home_team}%`);
        }
        if (away_team) {
            query += ` AND m.away_team ILIKE $${paramIndex++}`;
            params.push(`%${away_team}%`);
        }
        if (seat_category) {
            query += ` AND t.seat_category = $${paramIndex++}`;
            params.push(seat_category);
        }
        if (min_price) {
            query += ` AND t.price >= $${paramIndex++}`;
            params.push(parseFloat(min_price));
        }
        if (max_price) {
            query += ` AND t.price <= $${paramIndex++}`;
            params.push(parseFloat(max_price));
        }
        query += ' ORDER BY m.event_date ASC, t.price ASC';

        const result = await pool.query(query, params);

        // Cache result (Redis) for 60 seconds
        redisClient.setCache(cacheKey, JSON.stringify(result.rows), 60);

        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// ============================================
// 6. Get Ticket Details
// ============================================
router.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;

        const ticketResult = await pool.query(
            `SELECT t.*, m.sport_type, m.home_team, m.away_team, m.event_date, m.venue_city
             FROM tickets t
             JOIN matches m ON t.match_id = m.id
             WHERE t.id = $1`,
            [id]
        );
        if (ticketResult.rows.length === 0) return res.status(404).json({ error: 'Ticket not found' });

        const ticket = ticketResult.rows[0];

        let details = null;
        if (ticket.sport_type === 'football') {
            const det = await pool.query('SELECT * FROM football_details WHERE ticket_id = $1', [id]);
            details = det.rows[0];
        } else if (ticket.sport_type === 'volleyball') {
            const det = await pool.query('SELECT * FROM volleyball_details WHERE ticket_id = $1', [id]);
            details = det.rows[0];
        } else if (ticket.sport_type === 'basketball') {
            const det = await pool.query('SELECT * FROM basketball_details WHERE ticket_id = $1', [id]);
            details = det.rows[0];
        }

        res.json({ ...ticket, details });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// ============================================
// 7. Get Venues and Cities
// ============================================
router.get('/venues/list', async (req, res) => {
    try {
        const cities = await pool.query('SELECT DISTINCT venue_city FROM matches ORDER BY venue_city');
        res.json(cities.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

module.exports = router;