const express = require('express');
const pool = require('../db/pool');
const auth = require('../middleware/auth');

const router = express.Router();

// ============================================
// 12. Report Ticket Issue
// ============================================
router.post('/', auth, async (req, res) => {
    try {
        const { ticket_id, category, description } = req.body;
        const userId = req.user.id;

        const result = await pool.query(
            `INSERT INTO reports (user_id, ticket_id, category, description, status)
             VALUES ($1, $2, $3, $4, 'pending') RETURNING *`,
            [userId, ticket_id, category, description]
        );

        res.status(201).json({ message: 'Report submitted', report: result.rows[0] });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

module.exports = router;