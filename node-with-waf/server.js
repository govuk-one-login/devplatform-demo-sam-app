const http = require('http');
const hostname = '0.0.0.0';
const port = 8000;

let serverAvailable = true;

const server = http.createServer(function (request, response) {
    //503 error
        if (request.url === '/giveme503') {
            serverAvailable = false; // Turn off server availability
            setTimeout(() => {
                serverAvailable = true; // Turn on server availability after some time
                console.log('Server is now available');
            }, 60000); // Turn on server after 60 seconds
            response.statusCode = 200;
            response.setHeader('Content-Type', 'application/json');
            response.end(JSON.stringify({ message: 'Server will be unavailable for 60 seconds' }));
            return;
        }
        if (!serverAvailable) {
            response.statusCode = 503;
            response.setHeader('Content-Type', 'application/json');
            response.end(JSON.stringify({ error: 'Service Unavailable' }));
            return;
        }
    //502 error
    if (request.url === '/giveme502') {
        response.statusCode = 502;
        response.setHeader('Content-Type', 'application/json');
        response.end(JSON.stringify({ error: 'Intentional 502 error: Bad Gateway' }));
    //504 error
    } else if (request.url === '/giveme504') {
        setTimeout(() => {
            response.statusCode = 504;
            response.setHeader('Content-Type', 'application/json');
            response.end(JSON.stringify({ error: 'Intential 504 error: Gateway Timeout' }));
        }, 30000);
    } else {
        response.statusCode = 200;
        response.setHeader('Content-Type', 'application/json');
        const requestHeaders = JSON.stringify(request.headers);
        response.end(requestHeaders);
    }
});

server.listen(port, hostname, () => {
    console.log(`Server running at http://${hostname}:${port}/`);
});
server.on('error', (error) => {
    console.error('Server error:', error);
});
