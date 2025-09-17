# 📂 Navigation

| Description | Command |
|-------------|---------|
| Print working directory | ~~~bash<br>pwd<br>~~~ |
| List files in the current directory | ~~~bash<br>ls<br>~~~ |
| List all files, including hidden, with details | ~~~bash<br>ls -la<br>~~~ |
| Change directory | ~~~bash<br>cd <dir><br>~~~ |
| Go up one directory | ~~~bash<br>cd ..<br>~~~ |
| Go to your home directory | ~~~bash<br>cd ~<br>~~~ |

# 📄 File & Directory Management

| Description | Command |
|-------------|---------|
| Create an empty file | ~~~bash<br>touch file.txt<br>~~~ |
| Create a new directory | ~~~bash<br>mkdir myfolder<br>~~~ |
| Copy a file | ~~~bash<br>cp file1 file2<br>~~~ |
| Copy a directory recursively | ~~~bash<br>cp -r dir1 dir2<br>~~~ |
| Move or rename a file/directory | ~~~bash<br>mv oldname newname<br>~~~ |
| Remove a file | ~~~bash<br>rm file.txt<br>~~~ |
| Remove a directory and its contents | ~~~bash<br>rm -r folder<br>~~~ |

# 📦 Package Management (APT)

| Description | Command |
|-------------|---------|
| Refresh package lists | ~~~bash<br>sudo apt update<br>~~~ |
| Upgrade all upgradable packages | ~~~bash<br>sudo apt upgrade<br>~~~ |
| Install a package | ~~~bash<br>sudo apt install <package><br>~~~ |
| Remove a package | ~~~bash<br>sudo apt remove <package><br>~~~ |
| Search for a package | ~~~bash<br>sudo apt search <term><br>~~~ |

# 🔍 File Viewing & Editing

| Description | Command |
|-------------|---------|
| View file contents | ~~~bash<br>cat file.txt<br>~~~ |
| View file with scroll support | ~~~bash<br>less file.txt<br>~~~ |
| Edit file in Nano editor | ~~~bash<br>nano file.txt<br>~~~ |
| Edit file in Vim editor | ~~~bash<br>vim file.txt<br>~~~ |

# ⚙️ System Info & Monitoring

| Description | Command |
|-------------|---------|
| Show system information | ~~~bash<br>uname -a<br>~~~ |
| Show disk usage | ~~~bash<br>df -h<br>~~~ |
| Show memory usage | ~~~bash<br>free -h<br>~~~ |
| Show running processes | ~~~bash<br>top<br>~~~ |
| Interactive process viewer | ~~~bash<br>htop<br>~~~ |
| Install htop | ~~~bash<br>sudo apt install htop<br>~~~ |

# 🔐 Permissions

| Description | Command |
|-------------|---------|
| Change file permissions | ~~~bash<br>chmod 755 file<br>~~~ |
| Change file owner and group | ~~~bash<br>chown user:group file<br>~~~ |
| Run a command as superuser | ~~~bash<br>sudo <command><br>~~~ |

# 🌐 Networking

| Description | Command |
|-------------|---------|
| Test network connectivity | ~~~bash<br>ping example.com<br>~~~ |
| Fetch a web page | ~~~bash<br>curl http://example.com<br>~~~ |
| Download a file | ~~~bash<br>wget http://example.com/file.zip<br>~~~ |
| Show network interfaces (deprecated) | ~~~bash<br>ifconfig<br>~~~ |
| Show network interfaces (modern) | ~~~bash<br>ip addr<br>~~~ |

# 🗜️ Archiving & Compression

| Description | Command |
|-------------|---------|
| Create a tar archive | ~~~bash<br>tar -cvf archive.tar file1 file2<br>~~~ |
| Extract a tar archive | ~~~bash<br>tar -xvf archive.tar<br>~~~ |
| Create a compressed tar.gz archive | ~~~bash<br>tar -czvf archive.tar.gz folder<br>~~~ |
| Extract a tar.gz archive | ~~~bash<br>tar -xzvf archive.tar.gz<br>~~~ |
| Extract a zip file | ~~~bash<br>unzip file.zip<br>~~~ |

# ⚡ Advanced Commands & Power Tools

| Description | Command |
|-------------|---------|
| Search for a pattern in a file | ~~~bash<br>grep "pattern" file.txt<br>~~~ |
| Search recursively in a directory | ~~~bash<br>grep -r "pattern" /path<br>~~~ |
| Find files by name | ~~~bash<br>find /path -name "*.txt"<br>~~~ |
| Find files larger than 10 MB | ~~~bash<br>find /path -type f -size +10M<br>~~~ |
| Quickly find files (requires mlocate) | ~~~bash<br>locate filename<br>~~~ |
| Print the first column of a file | ~~~bash<br>awk '{print $1}' file.txt<br>~~~ |
| Print the second column of a CSV | ~~~bash<br>awk -F, '{print $2}' file.csv<br>~~~ |
| Replace all occurrences of "foo" with "bar" | ~~~bash<br>sed 's/foo/bar/g' file.txt<br>~~~ |
| Sort lines alphabetically | ~~~bash<br>sort file.txt<br>~~~ |
| Sort lines numerically | ~~~bash<br>sort -n file.txt<br>~~~ |
| Remove duplicate lines (adjacent) | ~~~bash<br>uniq file.txt<br>~~~ |
| Show command history | ~~~bash<br>history<br>~~~ |
| Repeat the last command | ~~~bash<br>!!<br>~~~ |
| Repeat command number n from history | ~~~bash<br>!n<br>~~~ |
| Build and execute commands from input | ~~~bash<br>xargs<br>~~~ |
| Show size of each item in current directory | ~~~bash<br>du -sh *<br>~~~ |
| Sync files/directories efficiently | ~~~bash<br>rsync -av source/ destination/<br>~~~ |
| Securely copy file to remote server | ~~~bash<br>scp file.txt user@host:/path<br>~~~ |
| Connect to a remote server via SSH | ~~~bash<br>ssh user@host<br>~~~ |
