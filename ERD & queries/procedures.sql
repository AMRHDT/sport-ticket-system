-- ============================================
-- Procedure 1: لیست بلیط‌های خریداری‌شده کاربر با ایمیل/شماره
-- ============================================
CREATE OR REPLACE FUNCTION get_user_tickets(user_email VARCHAR)
RETURNS TABLE(
    fullname VARCHAR,
    sport_type VARCHAR,
    home_team VARCHAR,
    away_team VARCHAR,
    seat_category VARCHAR,
    price DECIMAL,
    reserved_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT u.fullname, m.sport_type, m.home_team, m.away_team, 
           t.seat_category, t.price, r.reserved_at
    FROM users u
    JOIN reservations r ON u.id = r.user_id
    JOIN tickets t ON r.ticket_id = t.id
    JOIN matches m ON t.match_id = m.id
    WHERE u.email = user_email
      AND r.status = 'paid'
    ORDER BY r.reserved_at;
END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM get_user_tickets('ali@test.com');


-- ============================================
-- Procedure 2: کاربرانی که توسط پشتیبان لغو رزرو شده‌اند
-- ============================================
CREATE OR REPLACE FUNCTION get_cancelled_users_by_support(support_email VARCHAR)
RETURNS TABLE(user_fullname VARCHAR, ticket_id INT, cancelled_at TIMESTAMP) 
AS $$
BEGIN
    RETURN QUERY
    SELECT u.fullname, r.ticket_id, r.reserved_at
    FROM users u
    JOIN reservations r ON u.id = r.user_id
    JOIN users s ON r.cancelled_by_user_id = s.id
    WHERE s.email = support_email
      AND s.role = 'support'
    ORDER BY r.reserved_at;
END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM get_cancelled_users_by_support('support1@test.com');


-- ============================================
-- Procedure 3: بلیط‌های خریداری‌شده در یک شهر
-- ============================================
CREATE OR REPLACE FUNCTION get_tickets_by_city(city_name VARCHAR)
RETURNS TABLE(fullname VARCHAR, sport_type VARCHAR, home_team VARCHAR, away_team VARCHAR, seat_category VARCHAR, price DECIMAL, venue_city VARCHAR, reserved_at TIMESTAMP) 
AS $$
BEGIN
    RETURN QUERY
    SELECT u.fullname, m.sport_type, m.home_team, m.away_team, t.seat_category, t.price, m.venue_city, r.reserved_at
    FROM users u
    JOIN reservations r ON u.id = r.user_id
    JOIN tickets t ON r.ticket_id = t.id
    JOIN matches m ON t.match_id = m.id
    WHERE r.status = 'paid'
      AND m.venue_city = city_name
    ORDER BY r.reserved_at;
END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM get_tickets_by_city('تهران');


-- ============================================
-- Procedure 4: جستجوی پیشرفته با عبارت
-- ============================================
CREATE OR REPLACE FUNCTION search_tickets(keyword VARCHAR)
RETURNS TABLE(fullname VARCHAR, sport_type VARCHAR, home_team VARCHAR, away_team VARCHAR, venue_city VARCHAR, seat_category VARCHAR, price DECIMAL, reserved_at TIMESTAMP) 
AS $$
BEGIN
    RETURN QUERY
    SELECT u.fullname, m.sport_type, m.home_team, m.away_team, m.venue_city, t.seat_category, t.price, r.reserved_at
    FROM users u
    JOIN reservations r ON u.id = r.user_id
    JOIN tickets t ON r.ticket_id = t.id
    JOIN matches m ON t.match_id = m.id
    WHERE r.status = 'paid'
      AND (u.fullname ILIKE '%' || keyword || '%'
        OR m.home_team ILIKE '%' || keyword || '%'
        OR m.away_team ILIKE '%' || keyword || '%'
        OR m.venue_city ILIKE '%' || keyword || '%'
        OR t.seat_category ILIKE '%' || keyword || '%')
    ORDER BY r.reserved_at;
END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM search_tickets('استقلال');


-- ============================================
-- Procedure 5: کاربران همشهری یک کاربر
-- ============================================
CREATE OR REPLACE FUNCTION get_same_city_users(input_email VARCHAR)
RETURNS TABLE(user_fullname VARCHAR, user_email VARCHAR, user_city VARCHAR) 
AS $$
BEGIN
    RETURN QUERY
    SELECT u.fullname, u.email, u.city
    FROM users u
    WHERE u.city = (SELECT u2.city FROM users u2 WHERE u2.email = input_email)
      AND u.email != input_email
    ORDER BY u.fullname;
END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM get_same_city_users('ali@test.com');


-- ============================================
-- Procedure 6: n کاربر با بیشترین خرید از تاریخ مشخص
-- ============================================
CREATE OR REPLACE FUNCTION get_top_buyers(from_date TIMESTAMP, n INT)
RETURNS TABLE(fullname VARCHAR, email VARCHAR, tickets_bought BIGINT) 
AS $$
BEGIN
    RETURN QUERY
    SELECT u.fullname, u.email, COUNT(r.id) AS tickets_bought
    FROM users u
    JOIN reservations r ON u.id = r.user_id
    WHERE r.status = 'paid'
      AND r.reserved_at >= from_date
    GROUP BY u.fullname, u.email
    ORDER BY tickets_bought DESC
    LIMIT n;
END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM get_top_buyers('2025-06-01', 3);


-- ============================================
-- Procedure 7: بلیط‌های کنسل‌شده یک ورزش خاص
-- ============================================
CREATE OR REPLACE FUNCTION get_cancelled_tickets_by_sport(sport VARCHAR)
RETURNS TABLE(fullname VARCHAR, sport_type VARCHAR, home_team VARCHAR, away_team VARCHAR, seat_category VARCHAR, price DECIMAL, reserved_at TIMESTAMP, cancelled_by VARCHAR) 
AS $$
BEGIN
    RETURN QUERY
    SELECT u.fullname, m.sport_type, m.home_team, m.away_team, t.seat_category, t.price, r.reserved_at, s.fullname
    FROM users u
    JOIN reservations r ON u.id = r.user_id
    JOIN tickets t ON r.ticket_id = t.id
    JOIN matches m ON t.match_id = m.id
    LEFT JOIN users s ON r.cancelled_by_user_id = s.id
    WHERE r.status = 'cancelled'
      AND m.sport_type = sport
    ORDER BY r.reserved_at;
END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM get_cancelled_tickets_by_sport('football');


-- ============================================
-- Procedure 8: کاربران با بیشترین گزارش در یک موضوع
-- ============================================
CREATE OR REPLACE FUNCTION get_top_reporters_by_category(report_category VARCHAR)
RETURNS TABLE(fullname VARCHAR, email VARCHAR, report_count BIGINT) 
AS $$
BEGIN
    RETURN QUERY
    SELECT u.fullname, u.email, COUNT(rpt.id) AS report_count
    FROM users u
    JOIN reports rpt ON u.id = rpt.user_id
    WHERE rpt.category = report_category
    GROUP BY u.fullname, u.email
    ORDER BY report_count DESC;
END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM get_top_reporters_by_category('payment');