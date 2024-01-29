const net = require('net');
const fs = require('fs')
const { execSync, execFileSync } = require('child_process')
const path = require('path')


const handleFileModifiedEvent = (event, localRootDir, baseRsyncCommand) => {
  event.data.files.forEach((file) => {
    const localFilePath = localRootDir + file.name

    if (!file.exists) {
      return fs.rmSync(localFilePath, { recursive: true, force: true })
    }

    const dirToMake = file.type === 'd' ? localFilePath : path.dirname(localFilePath)
    fs.mkdirSync(dirToMake, { recursive: true });

    if (file.type === "f") {
      fs.writeFileSync(localFilePath, '')
    }

    const rsyncCommand = `${baseRsyncCommand}${file.absolutePath} ${localFilePath}`

    execSync(rsyncCommand)
    return console.log(rsyncCommand)
  })
}


const runClient = (serverPort, remoteHost, localRootDir, baseRsyncCommand) => {
  const client = new net.Socket();

  client.connect(serverPort, remoteHost, () => {
    console.log(`Connected to server: ${remoteHost}:${serverPort}`);
    const dataToSend = 'Hello from the client!';
    client.write(dataToSend);

    client.on('data', (eventPacket) => {
      const start = Date.now()
      const event = JSON.parse(eventPacket)
      console.log('DATAJSON', JSON.stringify(event))
      if (event.type === "file_modified") {
        handleFileModifiedEvent(event, localRootDir, baseRsyncCommand)
      }
      const end = Date.now()
      console.log('total time', (end - start) / 1000)
    });

    client.on('close', () => {
      console.log('Connection closed');
    });
  });

  client.on('error', (err) => {
    console.error(`Error: ${err.message}`);
  });

  // setTimeout(() => {
  //   client.end();
  // }, 5000);
}

module.exports = runClient

