# Sport Ticket Reservation and Purchase System

A comprehensive **full-stack sports ticket reservation and purchase platform** for football, volleyball, and basketball events.

The system allows users to **search, filter, reserve, purchase, cancel, and manage tickets**, while providing a dedicated **admin/support panel** for managing reservations and reviewing user reports.

This repository contains the complete implementation of **four mandatory project phases**, covering database design, SQL queries, backend APIs, frontend UI, Redis caching.

---

## Features

### User Features

* Sign up with name, email, password, and city
* Login using OTP verification
* Update profile information
* Search and filter tickets by:

  * Sport type
  * City
  * Home team
  * Away team
  * Seat category
  * Price range
* View detailed ticket information, including venue and amenities
* Reserve tickets with a **10-minute temporary lock**
* Pay for reserved tickets using a simulated local payment system
* View booking history
* Cancel reservations
* Check cancellation penalties
* Submit reports about ticket-related issues

### Admin / Support Features

* View all reservations
* View all user reports
* Approve reservations
* Cancel reservations
* Manage reservation statuses

### Database

* PostgreSQL with **raw SQL — no ORM**
* 11 normalized tables following **Third Normal Form (3NF)**
* Primary and foreign keys
* Unique constraints
* Check constraints
* Stored procedures
* Performance indexes
* Seed data with at least 10 records per main table

### Redis

* OTP storage with TTL
* Ticket search-result caching
* Cache invalidation when profile data changes


---

## Technologies

| Category         | Technology                            |
| ---------------- | ------------------------------------- |
| Backend          | Node.js, Express                      |
| Database         | PostgreSQL                            |
| Database Access  | Raw SQL                               |
| Caching / OTP    | Redis                                 |
| Authentication   | JWT                                   |
| Frontend         | HTML, Bootstrap 5, Vanilla JavaScript |
| Search           |                                       |
| Password Hashing | bcrypt                                |

---

## Database Schema

| Table                    | Description                           |
| ------------------------ | ------------------------------------- |
| `users`                  | Spectators and support staff          |
| `matches`                | Sports events and venues              |
| `tickets`                | Ticket categories and pricing         |
| `reservations`           | User reservations and expiration data |
| `payments`               | Payment transactions                  |
| `reports`                | User-submitted reports                |
| `ticket_change_requests` | Seat change and cancellation requests |
| `football_details`       | Football-specific ticket details      |
| `volleyball_details`     | Volleyball-specific ticket details    |
| `basketball_details`     | Basketball-specific ticket details    |
| `otps`                   | One-time passwords                    |

---

# Setup & Installation

## Prerequisites

Make sure the following are installed:

* [Node.js](https://nodejs.org/)
* PostgreSQL
* Redis *(optional, but recommended)*

---

## 1. Clone the Repository

```bash
git clone https://github.com/AMRHDT/sport-ticket-system.git
cd sport-ticket-system
```

---

## 2. Create the Database

Create a PostgreSQL database named:

```text
ticketing_db
```

Using `psql`:

```bash
psql -U postgres -d ticketing_db -f sql/schema.sql
psql -U postgres -d ticketing_db -f sql/seed.sql
```

Alternatively, execute the contents of:

```text
sql/schema.sql
sql/seed.sql
```

manually through **pgAdmin**.

---

## 3. Configure Environment Variables

Create a `.env` file in the project root:

```env
PORT=3000
DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@localhost:5432/ticketing_db
JWT_SECRET=my_super_secret_jwt_key_123
REDIS_URL=redis://localhost:6379
```

> **Important:** Never commit your real `.env` file or production secrets to Git.

---

## 4. Install Dependencies

```bash
npm install
```

---

## 5. Start Redis

Make sure Redis is running on:

```text
localhost:6379
```

Redis is used for OTP storage and ticket-search caching.

---

## 6. Start the Backend

Using npm:

```bash
npm start
```

Or with Nodemon:

```bash
npx nodemon server.js
```

---

## 7. Open the Application

Once the server is running, open:

```text
http://localhost:3000
```

---

# API Documentation

All API responses are returned as **JSON**.

## Authentication

### Sign Up

```http
POST /api/auth/signup
```

**Body:**

```json
{
  "fullname": "John",
  "email": "john@test.com",
  "password": "123456",
  "city": "Tehran"
}
```

### Request OTP

```http
POST /api/auth/request-otp
```

**Body:**

```json
{
  "email": "john@test.com"
}
```

### Verify OTP

```http
POST /api/auth/verify-otp
```

**Body:**

```json
{
  "email": "john@test.com",
  "otp": "123456"
}
```

### Update Profile

```http
PUT /api/auth/profile
```

**Headers:**

```http
Authorization: Bearer <token>
```

**Body:**

```json
{
  "fullname": "New Name",
  "city": "New City"
}
```

---

# Tickets

### Search Tickets

```http
GET /api/tickets/search
```

**Optional query parameters:**

```text
sport_type
city
home_team
away_team
seat_category
min_price
max_price
```

Example:

```http
GET /api/tickets/search?sport_type=football&city=Tehran
```

### Get Ticket Details

```http
GET /api/tickets/:id
```

### Get Cities / Venues

```http
GET /api/tickets/venues/list
```

---

# Reservations & Payments

### Reserve Ticket

```http
POST /api/reservations/reserve
```

**Headers:**

```http
Authorization: Bearer <token>
```

**Body:**

```json
{
  "ticket_id": 4
}
```

Reservations are temporarily locked for **10 minutes**.

### Pay for Ticket

```http
POST /api/reservations/pay
```

**Headers:**

```http
Authorization: Bearer <token>
```

**Body:**

```json
{
  "reservation_id": 11,
  "method": "card"
}
```

### Get User Bookings

```http
GET /api/reservations/bookings
```

**Headers:**

```http
Authorization: Bearer <token>
```

### Cancel Reservation

```http
POST /api/reservations/cancel
```

**Headers:**

```http
Authorization: Bearer <token>
```

**Body:**

```json
{
  "reservation_id": 2
}
```

### Check Cancellation Penalty

```http
GET /api/reservations/penalty/:id
```

**Headers:**

```http
Authorization: Bearer <token>
```

---

# Reports

### Submit Report

```http
POST /api/reports
```

**Headers:**

```http
Authorization: Bearer <token>
```

**Body:**

```json
{
  "ticket_id": 1,
  "category": "payment",
  "description": "Issue description"
}
```

---

# Admin API

Admin endpoints require a valid JWT belonging to a **support-role user**.

### Get All Reports

```http
GET /api/admin/reports
```

**Headers:**

```http
Authorization: Bearer <token>
```

### Get All Reservations

```http
GET /api/admin/reservations
```

**Headers:**

```http
Authorization: Bearer <token>
```

### Manage Reservation

```http
PUT /api/admin/reservations/:id
```

**Headers:**

```http
Authorization: Bearer <token>
```

**Body:**

```json
{
  "status": "approved"
}
```

or:

```json
{
  "status": "cancelled"
}
```

---

# Testing with cURL

## Request Login OTP

```bash
curl -X POST http://localhost:3000/api/auth/request-otp \
  -H "Content-Type: application/json" \
  -d '{"email":"ali@test.com"}'
```

## Verify OTP

```bash
curl -X POST http://localhost:3000/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"email":"ali@test.com","otp":"123456"}'
```

## Search Football Tickets

```bash
curl -X GET "http://localhost:3000/api/tickets/search?sport_type=football"
```

## Access a Protected Route

```bash
curl -X GET http://localhost:3000/api/reservations/bookings \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---


The ticket search system works as follows:

```text
                    ┌─────────────────────┐
                    │   Ticket Search API │
                    └──────────┬──────────┘
                               │
                     Elasticsearch available?
                         /              \
                       Yes               No
                        │                 │
                        ▼                 ▼
               Elasticsearch          PostgreSQL
                        │                 │
                        └────────┬────────┘
                                 ▼
                              Results

# Project Structure

```text
sport-ticket-system/
│
├── db/
│   └── pool.js
│
├── middleware/
│   └── auth.js
│
├── routes/
│   ├── auth.js
│   ├── tickets.js
│   ├── reservations.js
│   ├── reports.js
│   └── admin.js
│
├── utils/
│   ├── redis.js
│
├── public/
│   └── index.html
│
├── ERD & queries/
│   ├── schema.sql
│   ├── seed.sql
│   ├── queries.sql
│   └── procedures.sql
│
├── .env
├── .gitignore
├── package.json
└── server.js
```

---

# System Overview

```text
                         ┌──────────────┐
                         │    Client    │
                         │ HTML + JS +  │
                         │ Bootstrap 5  │
                         └───────┬──────┘
                                 │
                                 ▼
                         ┌──────────────┐
                         │  Express API │
                         └───────┬──────┘
                                 │
                 ┌───────────────┼───────────────┐
                 │               │               │
                 ▼               ▼               ▼
          ┌────────────┐  ┌────────────┐  ┌──────────────┐
          │ PostgreSQL │  │   Redis    │  │              │
          │  Database  │  │ Cache/OTP  │  │              │
          └────────────┘  └────────────┘  └──────────────┘
```

---

# Project Scope

This project demonstrates the integration of:

* Relational database design
* Database normalization
* Advanced SQL
* Stored procedures
* Backend REST APIs
* JWT authentication
* OTP-based login
* Redis caching
* Frontend development
* Reservation and payment workflows
* Role-based administration

The implementation covers **four mandatory project phases**, connecting the database layer to a complete full-stack application.
