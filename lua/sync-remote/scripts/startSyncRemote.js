const { execSync } = require('child_process');
const runClient = require('../client/client.js')

const arguments = process.argv.slice(2);
// node startSyncRemote nabil.ashraf 172.27.220.10 /home/nabil.ashraf/remotecms/ /home/syednabilashraf/remotecms/

const remoteUser = arguments[0]
const remoteHost = arguments[1]
// const remoteRootDir = arguments[2]
const localRootDir = arguments[3]
// const remoteUser = 'nabil.ashraf';
// const remoteHost = '172.27.220.10';
// const remoteRootDir = "/home/nabil.ashraf/remotecms/"
// const localRootDir = "/home/syednabilashraf/remotecms/"

let port = null;
const localServerDir = `${__dirname}/../server/app/`;
const remoteServerDir = '~/.sync-remote/';
// const clientExecutablePath = `${__dirname}/../client/client.js`
const baseRsyncCommand = `rsync -rzu --filter=':- .gitignore' --exclude='.git' --include='**.gitignore' -e 'ssh -o ControlPath=~/.ssh/control-syncremote' ${remoteUser}@${remoteHost}:`

const commands = {
  createControlMaster: `ssh -f -N -M -o ControlPath=~/.ssh/control-syncremote ${remoteUser}@${remoteHost}`,
  installServer: `rsync -rzu -e 'ssh -o ControlPath=~/.ssh/control-syncremote' ${localServerDir} ${remoteUser}@${remoteHost}:${remoteServerDir}`,
  runServer: `bash ${__dirname}/../server/run.sh ${remoteUser} ${remoteHost}`,
  getServerPortBufer: `ssh -f -o ControlPath=~/.ssh/control-syncremote ${remoteUser}@${remoteHost} "cat ${remoteServerDir}/port.log && rm ${remoteServerDir}/port.log"`
}

const getPort = (buffer) => {
  return buffer.toString().split(' ').pop()
}

try {
  execSync(commands.createControlMaster, { stdio: 'inherit' })
  console.log('Transferring server.js to remote machine...');

  const start = Date.now()
  execSync(commands.installServer);

  execSync(commands.runServer, { stdio: 'inherit' });

  const portBuffer = execSync(commands.getServerPortBufer)
  port = getPort(portBuffer)
  if (!port) {
    throw new Error("Failed to read port")
  }
  console.log("PORT", port)
  const end2 = Date.now()
  console.log('Finished executing server', (end2 - start) / 1000)
  runClient(port, remoteHost, localRootDir, baseRsyncCommand)

  // process.exit()
} catch (error) {
  console.error('Error:', error.message);
}

