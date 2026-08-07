const express = require('express');
const pool = require('../db/pool');
const redisClient = require('../utils/redis');
const auth = require('../middleware/auth');

const router = express.Router();

// ============================================
// 8. Reserve Ticket
// ============================================
router.post('/reserve', auth, async (req, res) => {
    try {
        const { ticket_id } = req.body;
        const userId = req.user.id;

        // Check availability
        const ticket = await pool.query('SELECT remaining, price FROM tickets WHERE id = $1', [ticket_id]);
        if (ticket.rows.length === 0) return res.status(404).json({ error: 'Ticket not found' });
        if (ticket.rows[0].remaining <= 0) return res.status(400).json({ error: 'Sold out' });

        // Temporary reservation for 10 minutes
        const expireTime = new Date(Date.now() + 10 * 60 * 1000);
        const result = await pool.query(
            `INSERT INTO reservations (user_id, ticket_id, status, reserved_at, expire_time)
             VALUES ($1, $2, 'reserved', NOW(), $3) RETURNING *`,
            [userId, ticket_id, expireTime]
        );

        // Decrease remaining
        await pool.query('UPDATE tickets SET remaining = remaining - 1 WHERE id = $1', [ticket_id]);

        res.json({ message: 'Ticket reserved successfully', reservation: result.rows[0] });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// ============================================
// 9. Payment
// ============================================
router.post('/pay', auth, async (req, res) => {
    try {
        const { reservation_id, method } = req.body; // method: card, wallet, crypto
        const userId = req.user.id;

        const reservation = await pool.query(
            'SELECT * FROM reservations WHERE id = $1 AND user_id = $2 AND status = $3',
            [reservation_id, userId, 'reserved']
        );
        if (reservation.rows.length === 0) return res.status(400).json({ error: 'Invalid reservation' });

        // Assume payment success
        const ticket = await pool.query('SELECT price FROM tickets WHERE id = $1', [reservation.rows[0].ticket_id]);
        const amount = ticket.rows[0].price;

        await pool.query(
            `INSERT INTO payments (reservation_id, amount, method, status, paid_at)
             VALUES ($1, $2, $3, 'success', NOW())`,
            [reservation_id, amount, method]
        );

        await pool.query("UPDATE reservations SET status = 'paid' WHERE id = $1", [reservation_id]);

        res.json({ message: 'Payment successful', amount });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});


// ============================================
// 9. Check Cancellation Penalty
// ============================================
router.get('/penalty/:id', auth, async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.user.id;

        // Check reservation exists and belongs to user
        const reservation = await pool.query(
            `SELECT r.*, m.event_date, m.sport_type
             FROM reservations r
             JOIN tickets t ON r.ticket_id = t.id
             JOIN matches m ON t.match_id = m.id
             WHERE r.id = $1 AND r.user_id = $2 AND r.status IN ('reserved', 'paid')`,
            [id, userId]
        );

        if (reservation.rows.length === 0) {
            return res.status(404).json({ error: 'Reservation not found or already cancelled' });
        }

        const eventDate = new Date(reservation.rows[0].event_date);
        const now = new Date();
        const hoursUntilEvent = (eventDate - now) / (1000 * 60 * 60);

        // Penalty rules
        let penaltyPercent = 0;
        let message = '';

        if (hoursUntilEvent > 72) {
            penaltyPercent = 0;
            message = 'No penalty – full refund';
        } else if (hoursUntilEvent > 48) {
            penaltyPercent = 10;
            message = '10% penalty';
        } else if (hoursUntilEvent > 24) {
            penaltyPercent = 25;
            message = '25% penalty';
        } else if (hoursUntilEvent > 0) {
            penaltyPercent = 50;
            message = '50% penalty';
        } else {
            penaltyPercent = 100;
            message = 'Event already started – no refund';
        }

        res.json({
            reservation_id: id,
            hours_until_event: Math.max(0, Math.round(hoursUntilEvent)),
            penalty_percent: penaltyPercent,
            message: message,
        });

    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// ============================================
// 10. Get User Bookings
// ============================================
router.get('/bookings', auth, async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT r.id, r.status, r.reserved_at, t.seat_category, t.price,
                    m.sport_type, m.home_team, m.away_team, m.event_date, m.venue_city
             FROM reservations r
             JOIN tickets t ON r.ticket_id = t.id
             JOIN matches m ON t.match_id = m.id
             WHERE r.user_id = $1
             ORDER BY r.reserved_at DESC`,
            [req.user.id]
        );
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// ============================================
// 11. Cancel Ticket
// ============================================
router.post('/cancel', auth, async (req, res) => {
    try {
        const { reservation_id } = req.body;
        const userId = req.user.id;

        const result = await pool.query(
            `UPDATE reservations SET status = 'cancelled', cancelled_by_user_id = $1
             WHERE id = $2 AND user_id = $1 AND status IN ('reserved', 'paid') RETURNING *`,
            [userId, reservation_id]
        );

        if (result.rows.length === 0) return res.status(400).json({ error: 'Cancellation not possible' });

        // Return capacity
        await pool.query(
            'UPDATE tickets SET remaining = remaining + 1 WHERE id = $1',
            [result.rows[0].ticket_id]
        );

        res.json({ message: 'Ticket cancelled', reservation: result.rows[0] });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

module.exports = router;