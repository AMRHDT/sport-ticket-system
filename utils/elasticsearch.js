const { Client } = require('@elastic/elasticsearch');

let client = null;
try {
    client = new Client({ node: 'http://localhost:9200' });
} catch (err) {
    console.log('Elasticsearch not available. Search will use SQL.');
}

module.exports = {
    client: client,
    isAvailable: () => client !== null,
    indexTicket: async (ticket) => {
        if (!client) return;
        try {
            await client.index({
                index: 'tickets',
                id: ticket.id.toString(),
                body: ticket,
            });
        } catch (err) {
            console.error('Elasticsearch index error:', err.message);
        }
    },
};