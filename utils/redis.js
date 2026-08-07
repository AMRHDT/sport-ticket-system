const redis = require('redis');

const client = redis.createClient({
    host: 'localhost',
    port: 6379,
});

client.on('error', (err) => console.log('Redis Client Error', err));

// Simple wrapper functions
module.exports = {
    setOTP: (email, otp) => {
        return new Promise((resolve, reject) => {
            client.setex(`otp:${email}`, 300, otp, (err, reply) => {
                if (err) reject(err);
                else resolve(reply);
            });
        });
    },
    getOTP: (email) => {
        return new Promise((resolve, reject) => {
            client.get(`otp:${email}`, (err, reply) => {
                if (err) reject(err);
                else resolve(reply);
            });
        });
    },
    deleteOTP: (email) => {
        return new Promise((resolve, reject) => {
            client.del(`otp:${email}`, (err, reply) => {
                if (err) reject(err);
                else resolve(reply);
            });
        });
    },
    deleteCache: (key) => {
        client.del(key);
    },
    getCache: (key) => {
        return new Promise((resolve, reject) => {
            client.get(key, (err, reply) => {
                if (err) reject(err);
                else resolve(reply);
            });
        });
    },
    setCache: (key, value, ttl = 60) => {
        client.setex(key, ttl, value);
    }
};