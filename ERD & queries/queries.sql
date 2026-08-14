-- ============================================
-- Query 1: کاربرانی که هیچ بلیطی رزرو نکرده‌اند
-- ============================================
SELECT fullname
FROM users
WHERE id NOT IN (
    SELECT DISTINCT user_id FROM reservations
);

-- نگار رستمی
-- پشتیبان ۱
-- پشتیبان ۲


-- ============================================
-- Query 2: کاربرانی که حداقل یک بلیط خریده‌اند
-- ============================================
SELECT DISTINCT u.fullname
FROM users u
JOIN reservations r ON u.id = r.user_id
WHERE r.status = 'paid';

-- زهرا حسینی
-- سارا موسوی
-- علی محمدی
-- مریم احمدی


-- ============================================
-- Query 3: مجموع پرداخت‌های هر کاربر در ماه‌های مختلف
-- ============================================
SELECT u.fullname, 
       TO_CHAR(p.paid_at, 'YYYY-MM') AS month, 
       SUM(p.amount) AS total_paid
FROM payments p
JOIN reservations r ON p.reservation_id = r.id
JOIN users u ON r.user_id = u.id
WHERE p.status = 'success'
GROUP BY u.fullname, TO_CHAR(p.paid_at, 'YYYY-MM')
ORDER BY u.fullname, month;

-- حسین رضایی | 2025-06 | 100000.00
-- زهرا حسینی | 2025-06 | 80000.00
-- سارا موسوی | 2025-06 | 90000.00
-- علی محمدی | 2025-06 | 350000.00
-- مریم احمدی | 2025-06 | 300000.00


-- ============================================
-- Query 4: کاربرانی که در هر شهر فقط یک بار خرید کرده‌اند
-- ============================================
SELECT u.fullname, u.city, COUNT(r.id) AS purchase_count
FROM users u
JOIN reservations r ON u.id = r.user_id
WHERE r.status = 'paid'
GROUP BY u.fullname, u.city
HAVING COUNT(r.id) = 1;

-- زهرا حسینی | تبریز | 1
-- سارا موسوی | شیراز | 1
-- مریم احمدی | اصفهان | 1


-- ============================================
-- Query 5: کاربری که جدیدترین بلیط را خریداری کرده
-- ============================================
SELECT u.fullname, u.email, u.city, r.reserved_at
FROM users u
JOIN reservations r ON u.id = r.user_id
WHERE r.status = 'paid'
ORDER BY r.reserved_at DESC
LIMIT 1;

-- علی محمدی | ali@test.com | تهران | 2025-06-25 16:00:00


-- ============================================
-- Query 6: کاربرانی که مجموع پرداخت‌شان > میانگین کل
-- ============================================
SELECT u.fullname, u.email
FROM users u
JOIN reservations r ON u.id = r.user_id
JOIN payments p ON r.id = p.reservation_id
WHERE p.status = 'success'
GROUP BY u.fullname, u.email
HAVING SUM(p.amount) > (SELECT AVG(total) 
                        FROM (SELECT SUM(p2.amount) AS total
                              FROM payments p2
                              WHERE p2.status = 'success'
                              GROUP BY p2.reservation_id) AS sub);

-- علی محمدی | ali@test.com
-- مریم احمدی | maryam@test.com


-- ============================================
-- Query 7: تعداد بلیط‌های فروخته‌شده به ازای هر نوع ورزش
-- ============================================
SELECT m.sport_type, COUNT(r.id) AS tickets_sold
FROM matches m
JOIN tickets t ON m.id = t.match_id
JOIN reservations r ON t.id = r.ticket_id
WHERE r.status = 'paid'
GROUP BY m.sport_type
ORDER BY tickets_sold DESC;

-- football | 2
-- volleyball | 2
-- basketball | 1


-- ============================================
-- Query 8: ۳ کاربر با بیشترین خرید در هفته اخیر
-- ============================================
SELECT u.fullname, COUNT(r.id) AS purchase_count
FROM users u
JOIN reservations r ON u.id = r.user_id
WHERE r.status = 'paid'
  AND r.reserved_at >= (SELECT MAX(reserved_at) FROM reservations WHERE status = 'paid') - INTERVAL '7 days'
GROUP BY u.fullname
ORDER BY purchase_count DESC
LIMIT 3;

-- علی محمدی | 2
-- زهرا حسینی | 1
-- سارا موسوی | 1


-- ============================================
-- Query 9: تعداد بلیط‌های فروخته‌شده در استان تهران به تفکیک شهر
-- ============================================
SELECT m.venue_city, COUNT(r.id) AS tickets_sold
FROM matches m
JOIN tickets t ON m.id = t.match_id
JOIN reservations r ON t.id = r.ticket_id
WHERE r.status = 'paid'
  AND m.venue_city = 'تهران'
GROUP BY m.venue_city;

-- تهران | 4


-- ============================================
-- Query 10: شهر قدیمی‌ترین کاربری که خرید داشته
-- ============================================
SELECT u.city
FROM users u
JOIN reservations r ON u.id = r.user_id
ORDER BY u.created_at, u.id
LIMIT 1;

-- تهران


-- ============================================
-- Query 11: نام پشتیبان‌های سایت
-- ============================================
SELECT fullname, email
FROM users
WHERE role = 'support';

-- پشتیبان ۱ | support1@test.com
-- پشتیبان ۲ | support2@test.com


-- ============================================
-- Query 12: کاربرانی که حداقل ۲ بلیط خریده‌اند
-- ============================================
SELECT u.fullname, COUNT(r.id) AS tickets_bought
FROM users u
JOIN reservations r ON u.id = r.user_id
WHERE r.status = 'paid'
GROUP BY u.fullname
HAVING COUNT(r.id) >= 2;

-- علی محمدی | 2


-- ============================================
-- Query 13: کاربرانی که حداکثر ۲ بلیط فوتبال خریده‌اند
-- ============================================
SELECT u.fullname, COUNT(r.id) AS football_tickets
FROM users u
JOIN reservations r ON u.id = r.user_id
JOIN tickets t ON r.ticket_id = t.id
JOIN matches m ON t.match_id = m.id
WHERE r.status = 'paid'
  AND m.sport_type = 'football'
GROUP BY u.fullname
HAVING COUNT(r.id) <= 2;

-- علی محمدی | 1
-- مریم احمدی | 1


-- ============================================
-- Query 14: کاربرانی که از هر سه ورزش بلیط خریده‌اند
-- ============================================
SELECT u.fullname, u.email
FROM users u
JOIN reservations r ON u.id = r.user_id
JOIN tickets t ON r.ticket_id = t.id
JOIN matches m ON t.match_id = m.id
WHERE r.status = 'paid'
GROUP BY u.fullname, u.email
HAVING COUNT(DISTINCT m.sport_type) = 3;

-- (بدون خروجی - هیچکس از هر سه ورزش خرید نکرده)


-- ============================================
-- Query 15: بلیط‌های خریداری‌شده امروز
-- ============================================
SELECT u.fullname, m.home_team, m.away_team, t.seat_category, t.price, r.reserved_at
FROM reservations r
JOIN users u ON r.user_id = u.id
JOIN tickets t ON r.ticket_id = t.id
JOIN matches m ON t.match_id = m.id
WHERE r.status = 'paid'
  AND DATE(r.reserved_at) = (SELECT MAX(DATE(reserved_at)) FROM reservations WHERE status = 'paid')
ORDER BY r.reserved_at;

-- علی محمدی | پیکان | سایپا | vip | 200000.00 | 2025-06-25 16:00:00


-- ============================================
-- Query 16: دومین بلیط پرفروش
-- ============================================
SELECT t.id, m.home_team, m.away_team, t.seat_category, t.price, COUNT(r.id) AS sold_count
FROM tickets t
JOIN matches m ON t.match_id = m.id
JOIN reservations r ON t.id = r.ticket_id
WHERE r.status = 'paid'
GROUP BY t.id, m.home_team, m.away_team, t.seat_category, t.price
ORDER BY sold_count DESC
LIMIT 1 OFFSET 1;

-- 1 | استقلال | پرسپولیس | regular | 150000.00 | 1


-- ============================================
-- Query 17: پشتیبان با بیشترین تعداد لغو
-- ============================================
SELECT u.fullname, 
       COUNT(r.id) AS cancelled_count,
       ROUND(COUNT(r.id) * 100.0 / (SELECT COUNT(*) FROM reservations WHERE cancelled_by_user_id IS NOT NULL), 2) AS cancel_percentage
FROM users u
JOIN reservations r ON u.id = r.cancelled_by_user_id
WHERE u.role = 'support'
GROUP BY u.fullname
ORDER BY cancelled_count DESC
LIMIT 1;

-- پشتیبان ۱ | 2 | 66.67


-- ============================================
-- Query 18: تغییر نام کاربر با بیشترین کنسلی به "ردینگتون"
-- ============================================
UPDATE users
SET fullname = 'ردینگتون'
WHERE id = (
    SELECT user_id FROM (
        SELECT r.user_id, COUNT(r.id) AS cnt
        FROM reservations r
        WHERE r.status = 'cancelled'
        GROUP BY r.user_id
        ORDER BY cnt DESC
        LIMIT 1
    ) AS sub
);


-- ============================================
-- Query 19: حذف بلیط‌های کنسل‌شده کاربر ردینگتون
-- ============================================
DELETE FROM reservations
WHERE user_id = (SELECT id FROM users WHERE fullname = 'ردینگتون')
  AND status = 'cancelled';


-- ============================================
-- Query 20: حذف تمام بلیط‌های کنسل‌شده
-- ============================================
DELETE FROM reservations
WHERE status = 'cancelled';


-- ============================================
-- Query 21: کاهش ۱۰٪ قیمت بلیط‌های آزادی فروخته‌شده 
-- ============================================
UPDATE tickets
SET price = price * 0.9
WHERE id IN (
    SELECT t.id
    FROM tickets t
    JOIN reservations r ON t.id = r.ticket_id
    JOIN football_details fd ON t.id = fd.ticket_id
    WHERE r.status = 'paid'
      AND fd.stadium = 'آزادی'
      AND DATE(r.reserved_at) = '2025-06-20'
);


-- ============================================
-- Query 22: موضوع و تعداد گزارش‌های بلیط با بیشترین گزارش
-- ============================================
SELECT t.id, m.home_team, m.away_team, rpt.category, COUNT(rpt.id) AS report_count
FROM reports rpt
JOIN tickets t ON rpt.ticket_id = t.id
JOIN matches m ON t.match_id = m.id
WHERE t.id = (
    SELECT ticket_id
    FROM reports
    GROUP BY ticket_id
    ORDER BY COUNT(id) DESC
    LIMIT 1
)
GROUP BY t.id, m.home_team, m.away_team, rpt.category
ORDER BY report_count DESC;

-- 9 | شیمیدر | مهرام | seat | 1