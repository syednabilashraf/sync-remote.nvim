const net = require('net');
const startWatcher = require('./watch.js')

const remoteDir = "/home/nabil.ashraf/remotecms"
const port = 7001;

const server = net.createServer((socket) => {
  console.log(`Client connected: ${socket.remoteAddress}:${socket.remotePort}`);
  startWatcher(remoteDir, socket)

  socket.on('data', (data) => {
    console.log(`Received data from client: ${data.toString()}`);
    const response = JSON.stringify({
      type: "connection_established",
      data: "hello from server"
    });
    socket.write(response);
  });

  socket.on('close', () => {
    console.log('Client disconnected');
  });
});

server.listen(port, () => {
  console.log(`Server is listening on port ${port}`);
});

