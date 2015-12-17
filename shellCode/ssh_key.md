#####  1、生成SSH密钥
```bash
$ssh-keygen
```
一路回车，会在 zealotpz 用户家目录下生成SSH私钥文件(id_rsa)和公钥文件(id_rsa.pub)
#####  2、复制id_rsa.pub到远程服务器用户家目录.ssh下（没有则新建目录），改文件名为：authorized_keys（多台主机隔行写入即可）
#####  3、在zealotpz用户下运行脚本（login.sh）get或者put：
```bash
!/bin/bash
sftp bike@127.0.0.1<<EOF
-get /home/bike/id_rsa.pub /Users/zealotpz/Bike/localhost/Ebike/123.txt
quit
EOF
···
