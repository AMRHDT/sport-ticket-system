const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const pool = require('../db/pool');
const redisClient = require('../utils/redis');
const auth = require('../middleware/auth');
require('dotenv').config();

const router = express.Router();

// ============================================
// 1. Signup - Register new user
// ============================================
router.post('/signup', async (req, res) => {
    try {
        const { fullname, email, password, city } = req.body;

        // Check if user exists
        const existing = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
        if (existing.rows.length > 0) {
            return res.status(400).json({ error: 'Email already registered' });
        }

        // Hash password
        const hashedPass = await bcrypt.hash(password, 10);

        // Save user
        const result = await pool.query(
            `INSERT INTO users (fullname, email, hashed_pass, role, city) 
             VALUES ($1, $2, $3, 'spectator', $4) RETURNING id, fullname, email, role`,
            [fullname, email, hashedPass, city]
        );

        const user = result.rows[0];

        // Generate JWT
        const token = jwt.sign(
            { id: user.id, email: user.email, role: user.role },
            process.env.JWT_SECRET,
            { expiresIn: '7d' }
        );

        res.status(201).json({ message: 'Signup successful', token, user });

    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// ============================================
// 2. Request OTP - Request OTP code for login
// ============================================
router.post('/request-otp', async (req, res) => {
    try {
        const { email } = req.body;

        // Check if user exists
        const result = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }

        // Generate 6-digit code
        const otp = Math.floor(100000 + Math.random() * 900000).toString();

        // Save in Redis with TTL=300s (5 minutes)
        await redisClient.setOTP(email, otp);

        // In practice, email/SMS would be sent here
        console.log(`📧 OTP for ${email}: ${otp}`);

        res.json({ message: 'OTP sent', otp }); // otp returned for testing only

    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// ============================================
// 3. Verify OTP - Verify OTP and login
// ============================================
router.post('/verify-otp', async (req, res) => {
    try {
        const { email, otp } = req.body;

        const storedOtp = await redisClient.getOTP(email);

        if (!storedOtp || storedOtp !== otp) {
            return res.status(400).json({ error: 'Invalid or expired OTP' });
        }

        await redisClient.deleteOTP(email);

        const result = await pool.query(
            'SELECT id, fullname, email, role FROM users WHERE email = $1',
            [email]
        );
        const user = result.rows[0];

        const token = jwt.sign(
            { id: user.id, email: user.email, role: user.role },
            process.env.JWT_SECRET,
            { expiresIn: '7d' }
        );

        res.json({ message: 'Login successful', token, user });

    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// ============================================
// 4. Update Profile - Update user profile
// ============================================
router.put('/profile', auth, async (req, res) => {
    try {
        const { fullname, city } = req.body;
        const userId = req.user.id;

        await pool.query(
            'UPDATE users SET fullname = $1, city = $2 WHERE id = $3',
            [fullname, city, userId]
        );

        await redisClient.deleteCache(`user:${userId}`);

        res.json({ message: 'Profile updated successfully' });

    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

module.exports = router;