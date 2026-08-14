--Users
INSERT INTO users (fullname, email, hashed_pass, role, city) VALUES
('علی محمدی', 'ali@test.com', 'hash001', 'spectator', 'تهران'),
('مریم احمدی', 'maryam@test.com', 'hash002', 'spectator', 'اصفهان'),
('حسین رضایی', 'hossein@test.com', 'hash003', 'spectator', 'تهران'),
('زهرا حسینی', 'zahra@test.com', 'hash004', 'spectator', 'تبریز'),
('محمد کریمی', 'mohammad@test.com', 'hash005', 'spectator', 'مشهد'),
('سارا موسوی', 'sara@test.com', 'hash006', 'spectator', 'شیراز'),
('امیر جعفری', 'amir@test.com', 'hash007', 'spectator', 'تهران'),
('نگار رستمی', 'negar@test.com', 'hash008', 'spectator', 'اصفهان'),
('پشتیبان ۱', 'support1@test.com', 'hash009', 'support', 'تهران'),
('پشتیبان ۲', 'support2@test.com', 'hash010', 'support', 'مشهد');

--Matches
INSERT INTO matches (sport_type, home_team, away_team, event_date, venue_city) VALUES
('football', 'استقلال', 'پرسپولیس', '2025-06-25 19:30', 'تهران'),
('football', 'سپاهان', 'ذوب‌آهن', '2025-06-27 17:00', 'اصفهان'),
('football', 'تراکتور', 'فولاد', '2025-06-28 18:00', 'تبریز'),
('football', 'ملوان', 'نساجی', '2025-06-29 19:00', 'رشت'),
('volleyball', 'پیکان', 'سایپا', '2025-06-30 16:00', 'تهران'),
('volleyball', 'شهداب', 'هراز', '2025-07-01 17:00', 'یزد'),
('volleyball', 'گیتی‌پسند', 'رعد', '2025-07-02 15:00', 'اصفهان'),
('basketball', 'شیمیدر', 'مهرام', '2025-07-03 18:00', 'تهران'),
('basketball', 'ذوب‌آهن', 'کاله', '2025-07-04 17:00', 'اصفهان'),
('basketball', 'آویژه', 'مس کرمان', '2025-07-05 19:00', 'مشهد');

--Tickets
INSERT INTO tickets (match_id, seat_category, price, remaining) VALUES
(1, 'regular', 150000, 1000),
(1, 'special', 300000, 500),
(1, 'vip', 500000, 200),
(2, 'regular', 100000, 800),
(2, 'special', 250000, 300),
(5, 'regular', 80000, 500),
(5, 'vip', 200000, 100),
(8, 'regular', 120000, 400),
(8, 'special', 220000, 200),
(10, 'regular', 90000, 600);

--Football Details
INSERT INTO football_details (ticket_id, league, stadium, section, row, seat, amenities) VALUES
(1, 'لیگ برتر', 'آزادی', 'A', '5', '12', '{"roof": true, "parking": true}'),
(2, 'لیگ برتر', 'آزادی', 'B', '3', '8', '{"roof": false, "catering": true}'),
(3, 'لیگ برتر', 'آزادی', 'VIP', '1', '1', '{"lounge": true, "parking": true}'),
(4, 'لیگ برتر', 'نقش‌جهان', 'C', '7', '15', '{"roof": true}'),
(5, 'لیگ برتر', 'نقش‌جهان', 'D', '2', '20', '{"roof": false}');

--Volleyball Details 
INSERT INTO volleyball_details (ticket_id, league, hall, section, row, seat, amenities) VALUES
(6, 'لیگ برتر', 'سالن ۱۲ هزار نفری', 'A', '3', '5', '{"near_court": true}'),
(7, 'لیگ برتر', 'سالن ۱۲ هزار نفری', 'VIP', '1', '2', '{"vip_lounge": true}');

--Basketball Details
INSERT INTO basketball_details (ticket_id, league, hall, section, row, seat, amenities) VALUES
(8, 'لیگ برتر', 'سالن آزادی', 'B', '4', '10', '{"parking": true}'),
(9, 'لیگ برتر', 'سالن آزادی', 'A', '2', '5', '{"catering": true}'),
(10, 'لیگ برتر', 'سالن مشهد', 'C', '6', '8', '{"parking": false}');

--Reservations
INSERT INTO reservations (user_id, ticket_id, status, reserved_at, expire_time, cancelled_by_user_id) VALUES
(1, 1, 'paid', '2025-06-20 10:00', '2025-06-20 10:10', NULL),
(1, 3, 'reserved', '2025-06-21 14:00', '2025-06-21 14:10', NULL),
(2, 2, 'paid', '2025-06-19 09:00', '2025-06-19 09:10', NULL),
(3, 5, 'cancelled', '2025-06-18 11:00', '2025-06-18 11:10', 9),
(4, 6, 'paid', '2025-06-22 08:00', '2025-06-22 08:10', NULL),
(5, 8, 'cancelled', '2025-06-17 15:00', '2025-06-17 15:10', 10),
(6, 10, 'paid', '2025-06-23 12:00', '2025-06-23 12:10', NULL),
(7, 4, 'reserved', '2025-06-24 09:00', '2025-06-24 09:10', NULL),
(1, 7, 'paid', '2025-06-25 16:00', '2025-06-25 16:10', NULL),
(2, 9, 'cancelled', '2025-06-26 10:00', '2025-06-26 10:10', 9);

--Payments
INSERT INTO payments (reservation_id, amount, method, status, paid_at) VALUES
(1, 150000, 'card', 'success', '2025-06-20 10:05'),
(3, 300000, 'wallet', 'success', '2025-06-19 09:05'),
(5, 80000, 'card', 'success', '2025-06-22 08:05'),
(7, 90000, 'crypto', 'success', '2025-06-23 12:05'),
(9, 200000, 'card', 'success', '2025-06-25 16:05'),
(6, 150000, 'wallet', 'failed', '2025-06-20 10:02'),
(8, 300000, 'card', 'pending', NULL),
(2, 500000, 'card', 'pending', NULL),
(4, 100000, 'wallet', 'success', '2025-06-27 18:05'),
(10, 220000, 'crypto', 'failed', '2025-06-26 11:00');

--Reports
INSERT INTO reports (user_id, ticket_id, category, description, status) VALUES
(1, 1, 'payment', 'مبلغ پرداختی اشتباه بود', 'pending'),
(2, 2, 'seat', 'صندلی جا به جا شده بود', 'reviewed'),
(3, 5, 'schedule', 'زمان مسابقه تغییر کرد', 'pending'),
(4, 6, 'cancellation', 'بلیط بدون اطلاع کنسل شد', 'reviewed'),
(5, 8, 'payment', 'مبلغ برگشت نخورد', 'pending'),
(6, 10, 'seat', 'صندلی رزرو شده موجود نبود', 'pending'),
(7, 4, 'schedule', 'مسابقه به تعویق افتاد', 'reviewed'),
(1, 3, 'cancellation', 'رزرو من بدون دلیل لغو شد', 'pending'),
(2, 7, 'payment', 'دو بار از حسابم کم شد', 'pending'),
(8, 9, 'seat', 'جایگاه با توضیحات مغایرت داشت', 'reviewed');

--Ticket Change Requests
INSERT INTO ticket_change_requests (user_id, reservation_id, type, new_seat_info, status) VALUES
(1, 1, 'change_seat', 'A-6-15', 'pending'),
(2, 3, 'cancel', NULL, 'approved'),
(3, 5, 'cancel', NULL, 'rejected'),
(4, 6, 'change_seat', 'B-2-8', 'pending'),
(5, 8, 'change_seat', 'C-4-10', 'approved'),
(6, 10, 'cancel', NULL, 'pending'),
(7, 4, 'change_seat', 'D-5-12', 'pending'),
(1, 9, 'change_seat', 'VIP-2-3', 'approved'),
(2, 2, 'cancel', NULL, 'rejected'),
(8, 7, 'change_seat', 'A-1-1', 'pending');

--OTPs
INSERT INTO otps (user_id, code, expires_at, is_used) VALUES
(1, '123456', '2025-06-22 12:00', false),
(1, '234567', '2025-06-21 11:00', true),
(2, '345678', '2025-06-23 10:00', false),
(3, '456789', '2025-06-20 09:00', true),
(4, '567890', '2025-06-24 08:00', false),
(5, '678901', '2025-06-25 07:00', true),
(9, '789012', '2025-06-26 06:00', false),
(10, '890123', '2025-06-27 05:00', false),
(9, '901234', '2025-06-28 04:00', true),
(10, '012345', '2025-06-29 03:00', false);