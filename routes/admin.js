const express = require('express');
const pool = require('../db/pool');
const auth = require('../middleware/auth');

const router = express.Router();

// Only support role has access
router.use(auth, async (req, res, next) => {
    if (req.user.role !== 'support') return res.status(403).json({ error: 'Access denied' });
    next();
});

// ============================================
// 13. Admin - Manage Reservation (Approve/Cancel/Modify)
// ============================================
router.put('/reservations/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body;

        if (!['approved', 'cancelled', 'modified'].includes(status)) {
            return res.status(400).json({ error: 'Invalid status' });
        }

        const result = await pool.query(
            `UPDATE reservations SET status = $1, cancelled_by_user_id = $2
             WHERE id = $3 RETURNING *`,
            [status === 'approved' ? 'paid' : 'cancelled', req.user.id, id]
        );

        res.json({ message: 'Update successful', reservation: result.rows[0] });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// ============================================
// 14. Admin - Reports List
// ============================================
router.get('/reports', async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT rpt.*, u.fullname AS reporter
             FROM reports rpt
             JOIN users u ON rpt.user_id = u.id
             ORDER BY rpt.created_at DESC`
        );
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// ============================================
// 15. Admin - Get All Reservations
// ============================================
router.get('/reservations', async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT r.id, r.status, r.reserved_at, u.fullname AS user_name, 
                    m.sport_type, m.home_team, m.away_team, t.seat_category
             FROM reservations r
             JOIN users u ON r.user_id = u.id
             JOIN tickets t ON r.ticket_id = t.id
             JOIN matches m ON t.match_id = m.id
             ORDER BY r.reserved_at DESC
             LIMIT 50`
        );
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

module.exports = router;