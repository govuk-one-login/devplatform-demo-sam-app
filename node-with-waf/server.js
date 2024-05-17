const http = require('http');
const hostname = '0.0.0.0';
const port = 8000;
const server = http.createServer(function (request, response) {
    response.statusCode = 200;
    response.setHeader("Content-Type", "application/json" );
    //if(request.headers.hasOwnProperty('txma-audit-encoded')) {
        //request.headers.txmaAuditDecoded = atob(request['headers']['txma-audit-encoded']);
    //}
    if(request.url == 'giveme502'){
        response.statusCode = 502
    }
    const requestHeaders = JSON.stringify(request.headers);
    response.end(requestHeaders);
});

server.listen(port, hostname, ()=> {
    console.log(`Server running at http://${hostname}:${port}/`);
});
