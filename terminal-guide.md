# Ubuntu Terminal Guide

A quick reference for common and advanced Ubuntu terminal commands.

---

# 📂 Navigation

| Description | Command |
|-------------|---------|
| Print working directory | `pwd` |
| List files in the current directory | `ls` |
| List all files, including hidden, with details | `ls -la` |
| Change directory | `cd <dir>` |
| Go up one directory | `cd ..` |
| Go to your home directory | `cd ~` |

### Print working directory
~~~bash
pwd
~~~

### List files in the current directory
~~~bash
ls
~~~

### List all files, including hidden, with details
~~~bash
ls -la
~~~

### Change directory
~~~bash
cd <dir>
~~~

### Go up one directory
~~~bash
cd ..
~~~

### Go to your home directory
~~~bash
cd ~
~~~

# 📄 File & Directory Management

| Description | Command |
|-------------|---------|
| Create an empty file | `touch file.txt` |
| Create a new directory | `mkdir myfolder` |
| Copy a file | `cp file1 file2` |
| Copy a directory recursively | `cp -r dir1 dir2` |
| Move or rename a file/directory | `mv oldname newname` |
| Remove a file | `rm file.txt` |
| Remove a directory and its contents | `rm -r folder` |

### Create an empty file
~~~bash
touch file.txt
~~~

### Create a new directory
~~~bash
mkdir myfolder
~~~

### Copy a file
~~~bash
cp file1 file2
~~~

### Copy a directory recursively
~~~bash
cp -r dir1 dir2
~~~

### Move or rename a file/directory
~~~bash
mv oldname newname
~~~

### Remove a file
~~~bash
rm file.txt
~~~

### Remove a directory and its contents
~~~bash
rm -r folder
~~~

# 📦 Package Management (APT)

| Description | Command |
|-------------|---------|
| Refresh package lists | `sudo apt update` |
| Upgrade all upgradable packages | `sudo apt upgrade` |
| Install a package | `sudo apt install <package>` |
| Remove a package | `sudo apt remove <package>` |
| Search for a package | `sudo apt search <term>` |

### Refresh package lists
~~~bash
sudo apt update
~~~

### Upgrade all upgradable packages
~~~bash
sudo apt upgrade
~~~

### Install a package
~~~bash
sudo apt install <package>
~~~

### Remove a package
~~~bash
sudo apt remove <package>
~~~

### Search for a package
~~~bash
sudo apt search <term>
~~~

# 🔍 File Viewing & Editing

| Description | Command |
|-------------|---------|
| View file contents | `cat file.txt` |
| View file with scroll support | `less file.txt` |
| Edit file in Nano editor | `nano file.txt` |
| Edit file in Vim editor | `vim file.txt` |

### View file contents
~~~bash
cat file.txt
~~~

### View file with scroll support
~~~bash
less file.txt
~~~

### Edit file in Nano editor
~~~bash
nano file.txt
~~~

### Edit file in Vim editor
~~~bash
vim file.txt
~~~

# ⚙️ System Info & Monitoring

| Description | Command |
|-------------|---------|
| Show system information | `uname -a` |
| Show disk usage | `df -h` |
| Show memory usage | `free -h` |
| Show running processes | `top` |
| Interactive process viewer | `htop` |
| Install htop | `sudo apt install htop` |

### Show system information
~~~bash
uname -a
~~~

### Show disk usage
~~~bash
df -h
~~~

### Show memory usage
~~~bash
free -h
~~~

### Show running processes
~~~bash
top
~~~

### Interactive process viewer
~~~bash
htop
~~~

### Install htop
~~~bash
sudo apt install htop
~~~

# 🔐 Permissions

| Description | Command |
|-------------|---------|
| Change file permissions | `chmod 755 file` |
| Change file owner and group | `chown user:group file` |
| Run a command as superuser | `sudo <command>` |

### Change file permissions
~~~bash
chmod 755 file
~~~

### Change file owner and group
~~~bash
chown user:group file
~~~

### Run a command as superuser
~~~bash
sudo <command>
~~~

# 🌐 Networking

| Description | Command |
|-------------|---------|
| Test network connectivity | `ping example.com` |
| Fetch a web page | `curl http://example.com` |
| Download a file | `wget http://example.com/file.zip` |
| Show network interfaces (deprecated) | `ifconfig` |
| Show network interfaces (modern) | `ip addr` |

### Test network connectivity
~~~bash
ping example.com
~~~

### Fetch a web page
~~~bash
curl http://example.com
~~~

### Download a file
~~~bash
wget http://example.com/file.zip
~~~

### Show network interfaces (deprecated)
~~~bash
ifconfig
~~~

### Show network interfaces (modern)
~~~bash
ip addr
~~~

# 🗜️ Archiving & Compression

| Description | Command |
|-------------|---------|
| Create a tar archive | `tar -cvf archive.tar file1 file2` |
| Extract a tar archive | `tar -xvf archive.tar` |
| Create a compressed tar.gz archive | `tar -czvf archive.tar.gz folder` |
| Extract a tar.gz archive | `tar -xzvf archive.tar.gz` |
| Extract a zip file | `unzip file.zip` |

### Create a tar archive
~~~bash
tar -cvf archive.tar file1 file2
~~~

### Extract a tar archive
~~~bash
tar -xvf archive.tar
~~~

### Create a compressed tar.gz archive
~~~bash
tar -czvf archive.tar.gz folder
~~~

### Extract a tar.gz archive
~~~bash
tar -xzvf archive.tar.gz
~~~

### Extract a zip file
~~~bash
unzip file.zip
~~~

# ⚡ Advanced Commands & Power Tools

| Description | Command |
|-------------|---------|
| Search for a pattern in a file | `grep "pattern" file.txt` |
| Search recursively in a directory | `grep -r "pattern" /path` |
| Find files by name | `find /path -name "*.txt"` |
| Find files larger than 10 MB | `find /path -type f -size +10M` |
| Quickly find files (requires mlocate) | `locate filename` |
| Print the first column of a file | `awk '{print $1}' file.txt` |
| Print the second column of a CSV | `awk -F, '{print $2}' file.csv` |
| Replace all occurrences of "foo" with "bar" | `sed 's/foo/bar/g' file.txt` |
| Sort lines alphabetically | `sort file.txt` |
| Sort lines numerically | `sort -n file.txt` |
| Remove duplicate lines (adjacent) | `uniq file.txt` |
| Show command history | `history` |
| Repeat the last command | `!!` |
| Repeat command number n from history | `!n` |
| Build and execute commands from input | `xargs` |
| Show size of each item in current directory | `du -sh *` |
| Sync files/directories efficiently | `rsync -av source/ destination/` |
| Securely copy file to remote server | `scp file.txt user@host:/path` |
| Connect to a remote server via SSH | `ssh user@host` |

### Search for a pattern in a file
~~~bash
grep "pattern" file.txt
~~~

### Search recursively in a directory
~~~bash
grep -r "pattern" /path
~~~

### Find files by name
~~~bash
find /path -name "*.txt"
~~~

### Find files larger than 10 MB
~~~bash
find /path -type f -size +10M
~~~

### Quickly find files (requires mlocate)
~~~bash
locate filename
~~~

### Print the first column of a file
~~~bash
awk '{print $1}' file.txt
~~~

### Print the second column of a CSV
~~~bash
awk -F, '{print $2}' file.csv
~~~

### Replace all occurrences of "foo" with "bar"
~~~bash
sed 's/foo/bar/g' file.txt
~~~

### Sort lines alphabetically
~~~bash
sort file.txt
~~~

### Sort lines numerically
~~~bash
sort -n file.txt
~~~

### Remove duplicate lines (adjacent)
~~~bash
uniq file.txt
~~~

### Show command history
~~~bash
history
~~~

### Repeat the last command
~~~bash
!!
~~~

### Repeat command number n from history
~~~bash
!n
~~~

### Build and execute commands from input
~~~bash
xargs
~~~

### Show size of each item in current directory
~~~bash
du -sh *
~~~

### Sync files/directories efficiently
~~~bash
rsync -av source/ destination/
~~~

### Securely copy file to remote server
~~~bash
scp file.txt user@host:/path
~~~

### Connect to a remote server via SSH
~~~bash
ssh user@host
~~~

