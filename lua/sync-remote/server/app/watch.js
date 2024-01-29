const watchman = require('fb-watchman');
const path = require('path')

const ignoredFiles = [".swo", ".swp", ".swx"]

const isFileWatched = (file) => file.name.includes('.gitignore') || (!file.name.includes('.git') && !ignoredFiles.includes(path.extname(file.name)))

const processFileForClient = (event) => (file) => {
  let fileAbsolutePath = `${event.root}/${file.name}`
  let fileRelativePath = file.name

  if (file.type === 'd') {
    fileAbsolutePath += '/'
    fileRelativePath += '/'
  }
  return { ...file, absolutePath: fileAbsolutePath, name: fileRelativePath }
}

const handleWatchEvent = (event, socket) => {
  if (event.is_fresh_instance) {
    return;
  }
  const modifiedFiles = event.files
    .filter(isFileWatched)
    .map(processFileForClient(event))
    .reverse();

  if (modifiedFiles.length) {
    const responseEvent = {
      type: "file_modified",
      data: {
        root: event.root,
        files: modifiedFiles
      }
    }

    socket.write(JSON.stringify(responseEvent));
  }
}

const startWatcher = (remoteDir, socket) => {
  const client = new watchman.Client();
  client.command(['watch', remoteDir], (watchError, _watchEvent) => {
    if (watchError) {
      console.error('Error during watch command:', watchError);
      return socket.end();
    }
    console.log(`Started watching ${remoteDir}`)

    client.command(['subscribe', remoteDir, 'syncRemoteSub', {
      fields: ['name', 'size', 'exists', 'type'],
    }], (subscribeError, _subscribeEvent) => {
      if (subscribeError) {
        return console.error('Error during subscribe command:', subscribeError);
      }
          client.on('subscription', (event) => {
        handleWatchEvent(kaku, socket)
      });
    });
  })
}

module.exports = startWatcher


