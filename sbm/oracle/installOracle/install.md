 CentOs 6.3_64静默安装oracle11g_r2 

oracle静默安装响应文件 

一。安装前的准备工作
```bash
#vi /etc/hosts  //添加IP地址对应的hostname
```
1.先安装好centos 6.3版本的系统 （略）
要求：
内存：至少1G
swap:如果1-2G物理内存，最好设置swap为1.5-2倍的物理内存大小
Available RAM	Swap Space Required
Between 1 GB and 2 GB	1.5 times the size of the RAM
Between 2 GB and 16 GB	Equal to the size of the RAM
More than 16 GB	16 GB
如果swap大小太小，可以删除或者重新制作一个分区，当成swap用一样的。
  #dd if=/dev/zero of=/swap bs=1M count=10000
  #mkswap /swap
  #swapon /swap  //挂载这个swap
  #swapon -s //查看swap分区



硬盘空间：
软件目录需要4G多点，数据库存入目录要2G左右，而且还要有400M左右的临时空间供安装时候的临时之用，这些空间对当今大容量磁盘来说已经毫无压力。
The following tables describe the disk space requirements for software files, and data files for each installation type on Linux x86-64:

Installation Type	Requirement for Software Files (GB)
Enterprise Edition	4.35
Standard Edition	4.22

Installation Type	Requirement for Data Files (GB)
Enterprise Edition	1.7
Standard Edition	1.5


2.下载oracle11g_r2_x64的oracle版本(官网下载地址http://www.oracle.com/technetwork/database/enterprise-edition/downloads/112010-linx8664soft-100572.html)

3.安装前的软件准备
参考官网安装手册
如果是64位系统，按照如下安装要求把i686软件也装上，否则安装时会报很多错误，无法成功安装
The following or later version of packages for Oracle Linux 6, and Red Hat Enterprise Linux 6 must be installed:

binutils-2.20.51.0.2-5.11.el6 (x86_64)
compat-libcap1-1.10-1 (x86_64) 
compat-libstdc++-33-3.2.3-69.el6 (x86_64)
compat-libstdc++-33-3.2.3-69.el6.i686 
gcc-4.4.4-13.el6 (x86_64)
gcc-c++-4.4.4-13.el6 (x86_64)
glibc-2.12-1.7.el6 (i686)
glibc-2.12-1.7.el6 (x86_64) 
glibc-devel-2.12-1.7.el6 (x86_64) 
glibc-devel-2.12-1.7.el6.i686
ksh
libgcc-4.4.4-13.el6 (i686)
libgcc-4.4.4-13.el6 (x86_64)
libstdc++-4.4.4-13.el6 (x86_64)
libstdc++-4.4.4-13.el6.i686
libstdc++-devel-4.4.4-13.el6 (x86_64)
libstdc++-devel-4.4.4-13.el6.i686
libaio-0.3.107-10.el6 (x86_64)
libaio-0.3.107-10.el6.i686
libaio-devel-0.3.107-10.el6 (x86_64) 
libaio-devel-0.3.107-10.el6.i686
make-3.81-19.el6
sysstat-9.0.4-11.el6 (x86_64)
Oracle ODBC Drivers

You should install ODBC Driver Manager for UNIX. You can download and install the Driver Manager from the following URL:

http://www.unixodbc.org

To use ODBC, you must also install the following additional ODBC RPMs, depending on your operating sytem:


On Oracle Linux 6 and Red Hat Enterprise Linux 6:

unixODBC-2.2.14-11.el6 (x86_64) or later

unixODBC-2.2.14-11.el6.i686 or later

unixODBC-devel-2.2.14-11.el6 (x86_64) or later

unixODBC-devel-2.2.14-11.el6.i686 or later

以上这些软件包都是要事先安装好的，有人会问为什么要安装这些包，，，，这，，我也说不好，官方就是这么要求的，好比是只有先排队，才能买到票的道理一样，咱们不要深究这些。


4.修改内核参数。
```bash
  #vi /etc/sysctl.conf  请根据自己实际情况修改，内核参数如下：

fs.aio-max-nr = 1048576
 fs.file-max = 6815744
 kernel.shmall = 2097152
 kernel.shmmax = 536870912
 kernel.shmmni = 4096
 kernel.sem = 250 32000 100 128 
net.ipv4.ip_local_port_range = 9000 65500 
net.core.rmem_default = 262144
 net.core.rmem_max = 4194304
 net.core.wmem_default = 262144
 net.core.wmem_max = 1048576


  # /sbin/sysctl -p
```
参数说明 //网上摘抄

1、kernel.shmall参数是控制共享内存页数

kernel.shmall的单位是页面数，当前的x86体系上这个单位是4K ，oracle的默认安装参数是kernel.shmall = 2097152  则一共是8G的共享内存总量

总的来说，这个参数和你具体硬件关系不太大，只是大于8G的时候调整到合适你的内存容量大小，小于8G就不用了

 

对于32位系统，一页=4k，也就是4096字节。RHEL6.2 X64通过查询也是4096

查询操作系统页面大小
```bash
$getconf PAGESIZE

4096

kernel.shmall= 内存大小/页面大小

48*1024*1024*1024/4096=12582912(安装机器48G内存)

kernel.shmall=12582912

12582912*4096/1024/1024/1024=48G
```
 

2、kernel.shmmax

shmmax 指的是单个共享内存段的最大尺寸， 设置shmmax=1G，sga分配了1.2G，当启动实例的时候就分配2块共享内存给Oracle .如果物理内存是2 G, 假设这台DB Server上还有Apache 在运行，那么shmmax 中设置的内存也会被Apache 来使用，那么分配的2 块共享内存段给Oracle 是否就是2 * 1G , 还是仅仅满足SGA需求的1.2 G就停止分配， 其他的内存的一部分分配给Oracle PGA 和软件Apache 来使用？

一般情况下可以设置最大共享内存为物理内存的一半，如果物理内存是2G，则可以设置最大共享内存为1073741824，如上；如物理内存是1G，则可以设置最大共享内存为512 * 1024 * 1024 = 536870912；以此类推。

在redhat上最大共享内存不建议超过

4*1024*1024*1024-1=4294967295

3、kernel.shmmni参数是控制共享内存段总数

shmmni内核参数是 共享内存段的最大数量（注意这个参数不是 shmmin,是 shmmni, shmmin 表示内存段最小大小 ） 。shmmni 缺省值 4096 ，一般肯定是够用了 。

```bash
  #vi /etc/security/limits.conf
  
  oracle soft nproc 2047
  oracle hard nproc 16384 
  oracle soft nofile 1024
  oracle hard nofile 65536 
  oracle soft stack 102405
```
创建oracle帐号和组
```bash
  #groupadd oinstall 
  #groupadd dba
  #useradd -g oinstall -G dba oracle
```
6。创建相关数据库目录
我们最好把安装数据库单独放到一个独立或多个分区的磁盘上（raid+lvm），这样即可以确保数据安全，和性能保障，又可以随时增减容量而不影响当前业务。
```bash
  #mkdir /u01
  #mount /dev/sda3 /u01
  #mkdir /u01/app
  #mkdir /u01/app/oracle/oradata //存放数据库的数据目录
  #mkdir /u01/app/oracle/oradata_back //存放数据库备份文件
  #chown -R oracle.oinstall /u01/app
  #chmod 775 /u01/app
```
7。修改oracle环境变量
```bash
  TMP=/tmp; export TMP  
  TMPDIR=$TMP; export TMPDIR 
  ORACLE_BASE=/u01/app/oracle; export ORACLE_BASE  
  ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1; export  ORACLE_HOME  
  ORACLE_SID=racl; export ORACLE_SID  
  ORACLE_TERM=xterm; export ORACLE_TERM  
  PATH=$ORACLE_HOME/bin:/usr/sbin:$PATH; export PATH  
  LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib;  
  export LD_LIBRARY_PATH  
  CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib;  
  export CLASSPATH
```
二。静默安装文件
解压oracle文件，进入response目录下
```bash
  #cp * /etc
  #vi /etc/db_install.rsp
```
//相关修改可以参考我上一篇”oracle静默安装文件db_install.rsp详解“

开始安装oracle软件：
$cd /opt/database
 $./runInstaller -silent -responseFile /etc/db_install.rsp
 安装过程中，如果提示[WARNING]不必理会，此时安装程序仍在进行，如果出现[FATAL]，则安装程序已经停止了。打开另一个终端，执行
 #tail -100 f /u01/app/oracle/oraInventory/logs/installActions......log
 可以实时跟踪查看安装日志，了解安装的进度。
 当出现
  以下配置脚本需要以 "root" 用户的身份执行。
   #!/bin/sh
   #要运行的 Root 脚本

  /u01/app/oracle/oraInventory/orainstRoot.sh
  /u01/app/oracle/product/11.2.0/db_1/root.sh
  要执行配置脚本, 请执行以下操作:
     1. 打开一个终端窗口
     2. 以 "root" 身份登录
     3. 运行脚本
     4. 返回此窗口并按 "Enter" 键继续

  Successfully Setup Software.
 表示安装成功了。按照其提示操作。
   $exit  //退回到root
   #/u01/app/oracle/oraInventory/orainstRoot.sh
   #/u01/app/oracle/product/11.2.0/db_1/root.sh

三。静默配置监听

 $netca /silent /responsefile /etc/netca.rsp
 正在对命令行参数进行语法分析:
 参数"silent" = true
 参数"responsefile" = /etc/netca.rsp
 完成对命令行参数进行语法分析。
 Oracle Net Services 配置:
 完成概要文件配置。
 Oracle Net 监听程序启动:
  正在运行监听程序控制:
    /u01/app/oracle/product/11.2.0/db_1/bin/lsnrctl start LISTENER
  监听程序控制完成。
  监听程序已成功启动。
 监听程序配置完成。
 成功完成 Oracle Net Services 配置。退出代码是0

 成功运行后，在/u01/app/oracle/product/11.2.0/db_1/network/admin目录下生成sqlnet.ora和listener.ora两个文件。

 通过netstat -tlnp 命令，看到
 tcp  0   0 :::1521        :::*      LISTEN      5477/tnslsnr
 说明监听器已经在1521端口上开始工作了。
 

四。静默建立新库（同时也建立一个对应的实例）
  修改/etc/dbca.rsp，设置如下：
 RESPONSEFILE_VERSION = "11.2.0"  //不能更改
 OPERATION_TYPE = "createDatabase"
 GDBNAME = "wang.bobower"  //全局数据库的名字=SID+主机域名
 SID = "wang"    //对应的实例名字
 TEMPLATENAME = "General_Purpose.dbc" //建库用的模板文件
 SYSPASSWORD = "123456"   //SYS管理员密码
 SYSTEMPASSWORD = "123456"  //SYSTEM管理员密码
 DATAFILEDESTINATION = /u01/app/oracle/oradata //数据文件存放目录
 RECOVERYAREADESTINATION=/u01/app/oracle/oradata_back //恢复数据存放目录
 CHARACTERSET = "ZHS16GBK"   //字符集，重要!!! 建库后一般不能更改，所以建库前要确定清楚。
 TOTALMEMORY = "5120"    //oracle内存5120MB

 静默建库命令如下
 $dbca -silent -responseFile /etc/dbca.rsp
 复制数据库文件
 1% 已完成
 3% 已完成
 11% 已完成
 18% 已完成
 26% 已完成
 37% 已完成
 正在创建并启动 Oracle 实例
 40% 已完成
 45% 已完成
 50% 已完成
 55% 已完成
 56% 已完成
 60% 已完成
 62% 已完成
 正在进行数据库创建





66% 已完成
 70% 已完成
 73% 已完成
 85% 已完成
 96% 已完成
 100% 已完成
 有关详细信息, 请参阅日志文件 "/u01/app/oracle/cfgtoollogs/dbca/wang/wang.log"。

 查看日志文件
 $ cat /u01/app/oracle/cfgtoollogs/dbca/wang/wang.log
 复制数据库文件
 DBCA_PROGRESS : 1%
 DBCA_PROGRESS : 3%
 DBCA_PROGRESS : 11%
 DBCA_PROGRESS : 18%
 DBCA_PROGRESS : 26%
 DBCA_PROGRESS : 37%
 正在创建并启动 Oracle 实例
 DBCA_PROGRESS : 40%
 DBCA_PROGRESS : 45%
 DBCA_PROGRESS : 50%
 DBCA_PROGRESS : 55%
 DBCA_PROGRESS : 56%
 DBCA_PROGRESS : 60%
 DBCA_PROGRESS : 62%
 正在进行数据库创建
 DBCA_PROGRESS : 66%
 DBCA_PROGRESS : 70%
 DBCA_PROGRESS : 73%
 DBCA_PROGRESS : 85%
 DBCA_PROGRESS : 96%
 DBCA_PROGRESS : 100%
 数据库创建完成。有关详细信息, 请查看以下位置的日志文件:
 /u01/app/oracle/cfgtoollogs/dbca/wang
 数据库信息:
 全局数据库名:wang.bobower
 系统标识符 (SID):wang

 建库后实例检查：
 $ ps -ef | grep ora_ | grep -v grep

oracle    9743  0.0  1.7 743204 18664 ?        Ss   23:47   0:00 ora_pmon_wang
oracle    9745  0.4  1.4 740956 15356 ?        Ss   23:47   0:01 ora_vktm_wang
oracle    9749  0.0  1.4 740956 15504 ?        Ss   23:47   0:00 ora_gen0_wang
oracle    9751  0.0  1.4 740956 15320 ?        Ss   23:47   0:00 ora_diag_wang
oracle    9753  0.0  2.1 741492 23412 ?        Ss   23:47   0:00 ora_dbrm_wang
oracle    9755  0.0  1.4 740956 15524 ?        Ss   23:47   0:00 ora_psp0_wang
oracle    9757  0.0  1.7 741468 18820 ?        Ss   23:47   0:00 ora_dia0_wang
oracle    9759  0.0  2.6 740956 28544 ?        Ss   23:47   0:00 ora_mman_wang
oracle    9761  0.0  2.1 746712 23984 ?        Ss   23:47   0:00 ora_dbw0_wang
oracle    9763  0.0  1.8 756508 20752 ?        Ss   23:47   0:00 ora_lgwr_wang
oracle    9765  0.0  1.6 741468 18120 ?        Ss   23:47   0:00 ora_ckpt_wang
oracle    9767  0.0  7.1 747664 77796 ?        Ss   23:47   0:00 ora_smon_wang
oracle    9769  0.0  2.2 741476 25052 ?        Ss   23:47   0:00 ora_reco_wang
oracle    9771  0.1  5.9 746928 64728 ?        Ss   23:47   0:00 ora_mmon_wang
oracle    9773  0.0  2.0 740956 21864 ?        Ss   23:47   0:00 ora_mmnl_wang
oracle    9775  0.0  1.4 742876 15428 ?        Ss   23:47   0:00 ora_d000_wang
oracle    9777  0.0  1.3 742020 14616 ?        Ss   23:47   0:00 ora_s000_wang
oracle    9831  0.0  1.5 740956 17436 ?        Ss   23:47   0:00 ora_qmnc_wang
oracle    9846  0.0  4.1 745608 44952 ?        Ss   23:47   0:00 ora_cjq0_wang
oracle    9848  0.0  3.0 742540 33700 ?        Ss   23:48   0:00 ora_q000_wang
oracle    9850  0.0  1.6 740952 18496 ?        Ss   23:48   0:00 ora_q001_wang
oracle    9861  0.0  1.4 740956 15696 ?        Ss   23:52   0:00 ora_smco_wang
oracle    9863  0.0  1.8 740984 20516 ?        Ss   23:52   0:00 ora_w000_wang


 查看监听状态
```bash
 $ lsnrctl status
 LSNRCTL for Linux: Version 11.2.0.1.0 - Production on 14-MAR-2012 07:09:03

 Copyright (c) 1991, 2009, Oracle.  All rights reserved.

 Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=IPC)(KEY=EXTPROC1521)))
 STATUS of the LISTENER
 ------------------------
 Alias                     LISTENER
 Version                   TNSLSNR for Linux: Version 11.2.0.1.0 - Production
 Start Date                14-MAR-2012 06:16:50
 Uptime                    0 days 0 hr. 52 min. 15 sec
 Trace Level               off
 Security                  ON: Local OS Authentication
 SNMP                      OFF
 Listener Parameter File   /u01/app/oracle/product/11.2.0/db_1/network/admin/listener.ora
 Listener Log File         /u01/app/oracle/diag/tnslsnr/oracle11gcentos6/listener/alert/log.xml
 Listening Endpoints Summary...
   (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1521)))
   (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=localhost)(PORT=1521)))
 Services Summary...
 Service "hello.dlxg.gov.cn" has 1 instance(s).
   Instance "hello", status READY, has 1 handler(s) for this service...
 Service "helloXDB.dlxg.gov.cn" has 1 instance(s).
   Instance "hello", status READY, has 1 handler(s) for this service...
 The command completed successfully
```
13 修改数据库为归档模式(归档模式才能热备份，增量备份)
```bash
 $ export ORACLE_SID=wang
 $ sqlplus / as sysdba
 SQL*Plus: Release 11.2.0.1.0 Production on Wed Mar 14 07:18:16 2012

 Copyright (c) 1982, 2009, Oracle.  All rights reserved.


 Connected to:
 Oracle Database 11g Enterprise Edition Release 11.2.0.1.0 - 64bit Production
 With the Partitioning, OLAP, Data Mining and Real Application Testing options

 SQL> shutdown immediate;

 Database closed.
 Database dismounted.
 ORACLE instance shut down.

 SQL> startup mount

 ORACLE instance started.

 Total System Global Area 1603411968 bytes
 Fixed Size                  2213776 bytes
 Variable Size             402655344 bytes
 Database Buffers         1191182336 bytes
 Redo Buffers                7360512 bytes
 Database mounted.

 SQL> alter database archivelog;

 Database altered.

 SQL> alter database flashback on;

 Database altered.

 SQL> alter database open;

 Database altered.

 SQL> execute utl_recomp.recomp_serial();

 PL/SQL procedure successfully completed.

 SQL> alter system archive log current;

 System altered.

 SQL> exit
 Disconnected from Oracle Database 11g Enterprise Edition Release 11.2.0.1.0 - 64bit Production
 With the Partitioning, OLAP, Data Mining and Real Application Testing options
``` 
14 修改oracle启动配置文件
 $vim /etc/oratab
racl:/u01/app/oracle/product/11.2.0/db_1:Y  //把“N”改成“Y”

 这样就可以通过dbstart 启动此实例，也可以通过dbshut关闭此实例了。
 $ dbshut /u01/app/oracle/product/11.2.0/db_1/
 Processing Database instance "hello": log file /u01/app/oracle/product/11.2.0/db_1/shutdown.log
 此时所有oracle的进程关闭，监听器也停止。

 $dbstart /u01/app/oracle/product/11.2.0/db_1/
 Processing Database instance "hello": log file /u01/app/oracle/product/11.2.0/db_1/startup.log

 此时监听器工作，hello实例运行，再次查看监听器状态。
 $ lsnrctl status

 LSNRCTL for Linux: Version 11.2.0.1.0 - Production on 14-MAR-2012 07:35:52

 Copyright (c) 1991, 2009, Oracle.  All rights reserved.

 Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=IPC)(KEY=EXTPROC1521)))
 STATUS of the LISTENER
 ------------------------
 Alias                     LISTENER
 Version                   TNSLSNR for Linux: Version 11.2.0.1.0 - Production
 Start Date                14-MAR-2012 07:35:38
 Uptime                    0 days 0 hr. 0 min. 13 sec

 Trace Level               off
 Security                  ON: Local OS Authentication
 SNMP                      OFF
 Listener Parameter File   /u01/app/oracle/product/11.2.0/db_1/network/admin/listener.ora
 Listener Log File        /u01/app/oracle/diag/tnslsnr/oracle11gcentos6/listener/alert/log.xml
 Listening Endpoints Summary...
   (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1521)))
   (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=localhost)(PORT=1521)))
 Services Summary...
 Service "hello.dlxg.gov.cn" has 1 instance(s).
   Instance "hello", status READY, has 1 handler(s) for this service...
 Service "helloXDB.dlxg.gov.cn" has 1 instance(s).
   Instance "hello", status READY, has 1 handler(s) for this service...
 The command completed successfully

以上就是安装的全部过程，如果想使用OEM管理和监控数据库，就要启动dbconsole了，如下：
$emctl start dbconsole
报这种错误：出现如下错误：
Environment variable ORACLE_UNQNAME not defined. Please set ORACLE_UNQNAME to database unique name.
网上说ORACLE_UNQNAME就是ORACL_SID，但我export ORACLE_SID=xxx设置后重新运行还是不行，不过报的是另外的错。


根据网上解决方法，可以重新创建 EM 资料档案库：
一。首先可以重建试下。

尝试解决步骤：

 1，修改DBSNMP密码：

重新配置DBCONSOLE，需要输入DBSNMP密码，但任何密码都会显示错误，需要预先修改。
sql>alter user dbsnmp identified by xxx;

2，删除早期DBCONSOLE创建的用户：

sql>drop role MGMT_USER;
sql>drop user MGMT_VIEW cascade;
sql>drop user sysman cascade;

3，删除早期DBCONSOLE创建的对象：
sql>drop PUBLIC SYNONYM MGMT_TARGET_BLACKOUTS;
sql>drop public synonym SETEMVIEWUSERCONTEXT;



$emca -config dbcontrol db -repos create
按照提示做下去，一般会成功创建新资料档案库的，如果还是报错。
查看日志发现如下错误：
oracle.sysman.assistants.util.sqlEngine.SQLFatalErrorException: ORA-00955:nameis already used by an existing object
二。接下来使用如下方法：


Drop the Repository using RepManager：

<ORACLE_HOME>/sysman/admin/emdrep/bin/RepManager<hostname><listener_port> <sid> -action drop

例 如：
$cd /u01/app/oracle/product/11.2.0/db_1/sysman/admin/emdrep/bin
$./RepManager bobower 1521 racl -action drop

三。最后再重新建库。

$emca -config dbcontrol db -repos create

这样基本就是搞定了。
最后启动em
$ emctl start dbconsole
$netstat -tunpl |grep 1158
