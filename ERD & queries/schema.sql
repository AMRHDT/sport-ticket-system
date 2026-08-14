-- User Table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    fullname VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    hashed_pass VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('spectator', 'support')),
    city VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Match Table
CREATE TABLE matches (
    id SERIAL PRIMARY KEY,
    sport_type VARCHAR(20) NOT NULL CHECK (sport_type IN ('football', 'volleyball', 'basketball')),
    home_team VARCHAR(100) NOT NULL,
    away_team VARCHAR(100) NOT NULL,
    event_date TIMESTAMP NOT NULL,
    venue_city VARCHAR(100) NOT NULL
);

-- Ticket Table
CREATE TABLE tickets (
    id SERIAL PRIMARY KEY,
    match_id INT NOT NULL,
    seat_category VARCHAR(20) NOT NULL CHECK (seat_category IN ('regular', 'special', 'vip')),
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    remaining INT NOT NULL CHECK (remaining >= 0),

    CONSTRAINT fk_ticket_match 
        FOREIGN KEY (match_id) 
        REFERENCES matches(id) 
        ON DELETE CASCADE
);

-- Reservation Table
CREATE TABLE reservations (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    ticket_id INT NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('reserved', 'paid', 'cancelled')),
    reserved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expire_time TIMESTAMP NOT NULL,
    
    CONSTRAINT fk_reservation_user 
        FOREIGN KEY (user_id) 
        REFERENCES users(id) 
        ON DELETE CASCADE,
        
    CONSTRAINT fk_reservation_ticket 
        FOREIGN KEY (ticket_id) 
        REFERENCES tickets(id) 
        ON DELETE CASCADE,
        
    CONSTRAINT chk_expire_time 
        CHECK (expire_time > reserved_at)
);

-- Payment Table
CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    reservation_id INT NOT NULL UNIQUE,
    amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    method VARCHAR(20) NOT NULL CHECK (method IN ('card', 'wallet', 'crypto')),
    status VARCHAR(20) NOT NULL CHECK (status IN ('success', 'failed', 'pending')),
    paid_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_payment_reservation 
        FOREIGN KEY (reservation_id) 
        REFERENCES reservations(id) 
        ON DELETE CASCADE
);

-- Report Table
CREATE TABLE reports (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    ticket_id INT NOT NULL,
    category VARCHAR(30) NOT NULL CHECK (category IN ('payment', 'schedule', 'seat', 'cancellation')),
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_report_user 
        FOREIGN KEY (user_id) 
        REFERENCES users(id) 
        ON DELETE CASCADE,
        
    CONSTRAINT fk_report_ticket 
        FOREIGN KEY (ticket_id) 
        REFERENCES tickets(id) 
        ON DELETE CASCADE
);

-- TicketChangeRequest Table
CREATE TABLE ticket_change_requests (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    reservation_id INT NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('cancel', 'change_seat')),
    new_seat_info VARCHAR(100),
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_tcr_user 
        FOREIGN KEY (user_id) 
        REFERENCES users(id) 
        ON DELETE CASCADE,
        
    CONSTRAINT fk_tcr_reservation 
        FOREIGN KEY (reservation_id) 
        REFERENCES reservations(id) 
        ON DELETE CASCADE
);

-- FootballDetails Table (Weak Entity)
CREATE TABLE football_details (
    ticket_id INT PRIMARY KEY,
    league VARCHAR(100),
    stadium VARCHAR(100),
    section VARCHAR(20),
    row VARCHAR(10),
    seat VARCHAR(10),
    amenities TEXT,
    
    CONSTRAINT fk_football_ticket 
        FOREIGN KEY (ticket_id) 
        REFERENCES tickets(id) 
        ON DELETE CASCADE
);

-- VolleyballDetails Table (Weak Entity)
CREATE TABLE volleyball_details (
    ticket_id INT PRIMARY KEY,
    league VARCHAR(100),
    hall VARCHAR(100),
    section VARCHAR(20),
    row VARCHAR(10),
    seat VARCHAR(10),
    amenities TEXT,
    
    CONSTRAINT fk_volleyball_ticket 
        FOREIGN KEY (ticket_id) 
        REFERENCES tickets(id) 
        ON DELETE CASCADE
);

-- BasketballDetails Table (Weak Entity)
CREATE TABLE basketball_details (
    ticket_id INT PRIMARY KEY,
    league VARCHAR(100),
    hall VARCHAR(100),
    section VARCHAR(20),
    row VARCHAR(10),
    seat VARCHAR(10),
    amenities TEXT,
    
    CONSTRAINT fk_basketball_ticket 
        FOREIGN KEY (ticket_id) 
        REFERENCES tickets(id) 
        ON DELETE CASCADE
);

-- OTP Table (Weak Entity)
CREATE TABLE otps (
    user_id INT NOT NULL,
    code VARCHAR(6) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (user_id, code),
    
    CONSTRAINT fk_otp_user 
        FOREIGN KEY (user_id) 
        REFERENCES users(id) 
        ON DELETE CASCADE
);


-- Add cancelled_by_user_id to reservations
ALTER TABLE reservations 
ADD COLUMN cancelled_by_user_id INT,
ADD CONSTRAINT fk_reservation_cancelled_by 
    FOREIGN KEY (cancelled_by_user_id) 
    REFERENCES users(id) 
    ON DELETE SET NULL;