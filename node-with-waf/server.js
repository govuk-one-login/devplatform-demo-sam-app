const http = require('http');
const hostname = '0.0.0.0';
const port = 8000;
const server = http.createServer(function (request, response) {
    response.statusCode = 200;
    response.setHeader("Content-Type", "application/json" );
    const requestHeaders = JSON.stringify(request.headers);
    response.end(requestHeaders);
});

server.listen(port, hostname, ()=> {
    console.log(`Server running at http://${hostname}:${port}/`);
});
