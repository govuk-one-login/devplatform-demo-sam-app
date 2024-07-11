const http = require('http');
const hostname = '0.0.0.0';
const port = 8000;

//boolan needed for 503 error
let serverAvailable = true;

const server = http.createServer(function (request, response) {
    //503 error - will render the server inaccesible for 60 seconds. No calls will be accepted until time is up.
        if (request.url === '/giveme503') {
            serverAvailable = false; // Turn off server availability
            setTimeout(() => {
                serverAvailable = true; // Turn on server availability after some time
                console.log('Server is now available');
            }, 60000); // Turn on server after 60 seconds
            response.statusCode = 200; //after 60 seconds server will start accepting calls
            response.setHeader('Content-Type', 'application/json');
            response.end(JSON.stringify({ message: 'Server will be unavailable for 60 seconds' }));
            return;
        }
        if (!serverAvailable) {
            response.statusCode = 503;
            response.setHeader('Content-Type', 'application/json');
            response.end(JSON.stringify({ error: 'Intentional 503: Service Unavailable' }));
            return;
        }
    //502 error - Bad Gateway error
    if (request.url === '/giveme502') {
        response.statusCode = 502;
        response.setHeader('Content-Type', 'application/json');
        response.end(JSON.stringify({ error: 'Intentional 502: Bad Gateway' }));
    //504 error - Gateway Timeout - 30 sec deley
    } else if (request.url === '/giveme504') {
        setTimeout(() => {
            response.statusCode = 504;
            response.setHeader('Content-Type', 'application/json');
            response.end(JSON.stringify({ error: 'Intential 504: Gateway Timeout' }));
        }, 30000);
    } else {
        response.statusCode = 200; //working state of the app - no endpoints
        response.setHeader('Content-Type', 'application/json');
        const requestHeaders = JSON.stringify(request.headers);
        response.end(requestHeaders);
    }
});

server.listen(port, hostname, () => {
    console.log(`Server running at http://${hostname}:${port}/`);
});
//debugging any errors should appear here
server.on('error', (error) => {
    console.error('Server error:', error);
});
