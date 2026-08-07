const pool = require('./db/pool');
const es = require('./utils/elasticsearch');

(async () => {
    try {
        const { rows } = await pool.query(
            `SELECT t.id, t.match_id, t.seat_category, t.price, t.remaining,
                    m.sport_type, m.home_team, m.away_team, m.event_date, m.venue_city
             FROM tickets t
             JOIN matches m ON t.match_id = m.id`
        );
        for (const ticket of rows) {
            await es.indexTicket(ticket);
        }
        console.log(`Indexed ${rows.length} tickets.`);
        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
})();