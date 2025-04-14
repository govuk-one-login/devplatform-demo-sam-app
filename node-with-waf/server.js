const http = require('http');
const url = require('url');
const hostname = '0.0.0.0';
const port = 8000;

const server = http.createServer(function (request, response) {
    console.log("Test2")
    const parsedURL = url.parse(
        request.url,
        true
    );
    let delay
    let statusCode

    if (parsedURL.pathname === '/testResponse') {
        if (!isNaN(parsedURL.query.delay)) {
            delay = parsedURL.query.delay;
          } else {
            delay = 0;
          }

          if (!isNaN(parsedURL.query.statusCode)) {
            statusCode = parsedURL.query.statusCode;
          } else {
            statusCode = 200;
          }

        if ('delay' in parsedURL.query || 'statueCode' in parsedURL.query) {
            setTimeout(() => {
                response.statusCode = statusCode;
                response.setHeader('Content-Type', 'application/json');
                response.end(JSON.stringify({ error: `Intentional ${statusCode} error` }));
            }, delay);
            return;
        }
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
