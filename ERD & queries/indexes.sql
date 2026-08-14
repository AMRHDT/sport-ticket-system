-- ============================================
-- Indexes for Query Optimization
-- ============================================

CREATE INDEX idx_users_email ON users(email);

CREATE INDEX idx_matches_sport_date ON matches(sport_type, event_date);

CREATE INDEX idx_tickets_price_category ON tickets(price, seat_category);

CREATE INDEX idx_reservations_user ON reservations(user_id);

CREATE INDEX idx_reservations_status_date ON reservations(status, reserved_at);

CREATE INDEX idx_reports_category ON reports(category);

-- ============================================
-- Query Optimization Test
-- ============================================
EXPLAIN ANALYZE 
SELECT u.fullname, m.sport_type, t.seat_category, t.price
FROM users u
JOIN reservations r ON u.id = r.user_id
JOIN tickets t ON r.ticket_id = t.id
JOIN matches m ON t.match_id = m.id
WHERE r.status = 'paid'
  AND m.sport_type = 'football'
ORDER BY r.reserved_at DESC;