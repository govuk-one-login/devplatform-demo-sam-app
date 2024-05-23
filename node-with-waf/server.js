const http = require('http');
const hostname = '0.0.0.0';
const port = 8000;

const server = http.createServer(function (request, response) {
    if (request.url === '/giveme502') {
        response.statusCode = 502;
        response.setHeader('Content-Type', 'application/json');
        response.end(JSON.stringify({ error: 'Intentional 502 error: Bad Gateway' }));
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
