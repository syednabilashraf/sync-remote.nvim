![License
](https://img.shields.io/github/license/syednabilashraf/sync-remote.nvim?color=%23000080&style=for-the-badge)

# sync-remote.nvim

Remote development plugin for Neovim.

## Prerequisites
- [rsync](https://github.com/WayneD/rsync/blob/master/INSTALL.md)

```
sudo apt install rsync
```

## Installation


### Using [Lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
-- plugins/sync-remote.lua:
return {
    'syednabilashraf/sync-remote.nvim'
    }
```

### Using [Packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use {
'syednabilashraf/sync-remote.nvim'
}
```
    
## Configuration
Create a ```.nvim/config.txt``` file at the root of your project with the following content:

```
remote_root    [username@][hostname]:[remote_path]
local_root     ~/example_path/
```

Config fields summary:
- ```username```       username to connect with host
- ```hostname```       the host name or remote ip address
- ```remote_path```    the remote folder to be synced
- ```remote_root```    combination of username, hostname and remote_path. Example: johndoe@172.26.221.11:/home/project
- ```local_root```     the local folder to be synced. Example: ~/home/project

## Commands

- ```:SyncRemoteFileUp``` syncs the active file from local to remote
- ```:SyncRemoteUp``` syncs all files from local_root to remote_root
- ```:SyncRemoteDown``` syncs all files from remote_root to local_root
