#####  1、生成SSH密钥
```bash
$ssh-keygen
```
一路回车，会在 zealotpz 用户家目录下生成SSH私钥文件(id_rsa)和公钥文件(id_rsa.pub)
#####  2、复制id_rsa.pub到远程服务器用户家.ssh目录下(没有则新建),改文件名为:authorized_keys(多台主机隔行写入即可)
#####  3、在zealotpz用户下运行脚本（login.sh）get或者put：
```bash
!/bin/bash
sftp bike@127.0.0.1<<EOF
-get /home/bike/id_rsa.pub /Users/zealotpz/Bike/localhost/Ebike/123.txt
quit
EOF
```
#####--------
#####ssh密钥文件无效问题的解
Leave a commentGo to comments
有时候我们为了省事，或者出于安全方面的考虑，在登录ssh的时候不使用密码，而是密钥文件。而有些发行版的/etc/ssh/sshd_config里，StrictModes默认被设定为yes，这可能会导致密钥文件不被接受的问题。解决方法也很简单，就是设置好相关目录的权限：
```bash
$ chmod 700 ~/.ssh
$ chmod 600 ~/.ssh/authorized_keys
```
