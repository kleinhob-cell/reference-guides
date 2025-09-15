# Ubuntu Terminal Guide

A quick reference for common and advanced Ubuntu terminal commands.

---

## 📂 Navigation

| Command | Description |
|---------|-------------|
| `pwd` | Print working directory (where you are) |
| `ls` | List files in the current directory |
| `ls -la` | List all files, including hidden, with details |
| `cd <dir>` | Change directory |
| `cd ..` | Go up one directory |
| `cd ~` | Go to your home directory |

---

## 📄 File & Directory Management

| Command | Description |
|---------|-------------|
| `touch file.txt` | Create an empty file |
| `mkdir myfolder` | Create a new directory |
| `cp file1 file2` | Copy a file |
| `cp -r dir1 dir2` | Copy a directory recursively |
| `mv oldname newname` | Move or rename a file/directory |
| `rm file.txt` | Remove a file |
| `rm -r folder` | Remove a directory and its contents |

---

## 📦 Package Management (APT)

| Command | Description |
|---------|-------------|
| `sudo apt update` | Refresh package lists |
| `sudo apt upgrade` | Upgrade all upgradable packages |
| `sudo apt install <package>` | Install a package |
| `sudo apt remove <package>` | Remove a package |
| `sudo apt search <term>` | Search for a package |

---

## 🔍 File Viewing & Editing

| Command | Description |
|---------|-------------|
| `cat file.txt` | View file contents |
| `less file.txt` | View file with scroll support |
| `nano file.txt` | Edit file in Nano editor |
| `vim file.txt` | Edit file in Vim editor |

---

## ⚙️ System Info & Monitoring

| Command | Description |
|---------|-------------|
| `uname -a` | Show system information |
| `df -h` | Show disk usage |
| `free -h` | Show memory usage |
| `top` | Show running processes |
| `htop` | Interactive process viewer (install with `sudo apt install htop`) |

---

## 🔐 Permissions

| Command | Description |
|---------|-------------|
| `chmod 755 file` | Change file permissions |
| `chown user:group file` | Change file owner and group |
| `sudo` | Run a command as superuser |

---

## 🌐 Networking

| Command | Description |
|---------|-------------|
| `ping example.com` | Test network connectivity |
| `curl http://example.com` | Fetch a web page |
| `wget http://example.com/file.zip` | Download a file |
| `ifconfig` / `ip addr` | Show network interfaces |

---

## 🗜️ Archiving & Compression

| Command | Description |
|---------|-------------|
| `tar -cvf archive.tar file1 file2` | Create a tar archive |
| `tar -xvf archive.tar` | Extract a tar archive |
| `tar -czvf archive.tar.gz folder` | Create a compressed tar.gz archive |
| `tar -xzvf archive.tar.gz` | Extract a tar.gz archive |
| `unzip file.zip` | Extract a zip file |

---

## 🛠 Useful Shortcuts

- **Ctrl + C** → Cancel running command
- **Ctrl + L** → Clear terminal screen
- **Tab** → Auto-complete file/folder names
- **↑ / ↓** → Scroll through command history

---

## 📚 Tips

- Use `man <command>` to read the manual for any command.
- Combine commands with `&&` to run sequentially.
- Redirect output to a file with `>` (overwrite) or `>>` (append).

---

## ⚡ Advanced Commands & Power Tools

| Command | Description |
|---------|-------------|
| `grep "pattern" file.txt` | Search for a pattern in a file |
| `grep -r "pattern" /path` | Search recursively in a directory |
| `find /path -name "*.txt"` | Find files by name |
| `find /path -type f -size +10M` | Find files larger than 10 MB |
| `locate filename` | Quickly find files (requires `mlocate` package) |
| `awk '{print $1}' file.txt` | Print the first column of a file |
| `awk -F, '{print $2}' file.csv` | Print the second column of a CSV |
| `sed 's/foo/bar/g' file.txt` | Replace all occurrences of "foo" with "bar" |
| `sort file.txt` | Sort lines alphabetically |
| `sort -n file.txt` | Sort lines numerically |
| `uniq file.txt` | Remove duplicate lines (adjacent) |
| `history` | Show command history |
| `!!` | Repeat the last command |
| `!n` | Repeat command number `n` from history |
| `xargs` | Build and execute commands from input |
| `du -sh *` | Show size of each item in current directory |
| `rsync -av source/ destination/` | Sync files/directories efficiently |
| `scp file.txt user@host:/path` | Securely copy file to remote server |
| `ssh user@host` | Connect to a remote server via SSH |

---

_Last updated: {{DATE}}_

_Edited in VS Code_
