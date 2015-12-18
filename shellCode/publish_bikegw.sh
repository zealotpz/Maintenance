#!/bin/bash
bikegw_SDIR=/home/bikegw/apache-tomcat-bikegw
StartTomcat=/home/bikegw/apache-tomcat-bikegw/bin/
#获取时间并格式化
time=`date +"%Y%m%d%H%M" `
#备份文件名
filename=bikegw_$time.war
#获取 tomcat 进程并杀掉
TomcatPID=$(ps -ef |grep tomcat |grep -w 'apache-tomcat-bikegw'|grep -v 'grep'|awk '{print $2}')
if [ "$TomcatPID" = "" ]
   then
    echo "tomcat 已关闭";
else
    echo "bikegw tomcat 进程ID:$TomcatPID"
    kill -9  ${TomcatPID};
    if [ ! $? ];then
            echo "关闭 tomcat 失败，请手动关闭";
            exit;
    fi;
fi;
echo "tomcat 关闭成功";

sleep 3

echo "-------------------  开始备份并删除日志文件与旧 war 包  ----------------------";
#拷贝文件至至war_backup目录，没有则新建目录
mkdir -p /home/bikegw/war_backup/ && cp ${bikegw_SDIR}/webapps/bikegw.war /home/bikegw/war_backup/$filename
echo "-----------------------   备份成功！  ---------------------------"
rm -rf ${bikegw_SDIR}/logs/*
rm -rf ${bikegw_SDIR}/bin/logs/*
rm -rf ${bikegw_SDIR}/webapps/*
echo "-----------------------   删除成功！  ---------------------------"
cp /home/bikegw/war_new/bikegw.war ${bikegw_SDIR}/webapps/
echo "-----------------------   新 war 拷贝成功！  --------------------------"
echo "-----------------------   开始启动 bikegw Tomcat  --------------------------"
export NEST_HOME=/home/bike/NEST_FILE
cd $StartTomcat
nohup ./startup.sh &
sleep 4 #等候4秒
TomcatNEWID=$(ps -ef |grep tomcat |grep -w 'apache-tomcat-bikegw'|grep -v 'grep'|awk '{print $2}')
echo "bikegw tomcat 新进程为:$TomcatNEWID"
