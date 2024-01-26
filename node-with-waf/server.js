const http = require('http');
const hostname = '0.0.0.0';
const port = 8000;
const server = http.createServer(function (request, response) {
    response.statusCode = 200;
    response.setHeader("Content-Type", "application/json" );
    const requestHeaders = JSON.stringify(request.headers);
    let txmaAuditDecoded = '';
    if(request.headers.hasOwnProperty('txma-audit-encoded')) {
        txmaAuditDecoded = atob(request['headers']['txma-audit-encoded']);
    }
    response.end(requestHeaders + ',{"txmaAuditDecoded":' + txmaAuditDecoded + '}');
});

server.listen(port, hostname, ()=> {
    console.log(`Server running at http://${hostname}:${port}/`);
});
