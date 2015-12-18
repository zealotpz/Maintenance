#!/bin/bash
BIKEMT_SDIR=/home/bikemt/apache-tomcat-bikemt
StartTomcat=/home/bikemt/apache-tomcat-bikemt/bin/
#获取时间并格式化
time=`date +"%Y%m%d%H%M" `
#备份文件名
filename=bikemt_$time.war
#获取 tomcat 进程并杀掉
TomcatPID=$(ps -ef |grep tomcat |grep -w 'apache-tomcat-bikemt'|grep -v 'grep'|awk '{print $2}')
if [ "$TomcatPID" = "" ]
   then
    echo "tomcat 已关闭";
else
    echo "bikemt tomcat 进程ID:$TomcatPID"
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
mkdir -p /home/bikemt/war_backup/ && cp ${BIKEMT_SDIR}/webapps/bikemt.war /home/bikemt/war_backup/$filename
echo "-----------------------   备份成功！  ---------------------------"
rm -rf ${bikemt_SDIR}/logs/*
rm -rf ${bikemt_SDIR}/bin/logs/*
rm -rf ${bikemt_SDIR}/webapps/*
echo "-----------------------   删除成功！  ---------------------------"
cp /home/bikemt/war_new/bikemt.war ${BIKEMT_SDIR}/webapps/
echo "-----------------------   新 war 拷贝成功！  --------------------------"
echo "-----------------------   开始启动 bikemt Tomcat  --------------------------"
#获取环境变量，否则提示找不到 NEST_HOME
export NEST_HOME=/home/bike/NEST_FILE
cd $StartTomcat
nohup ./startup.sh &
TomcatNEWID=$(ps -ef |grep tomcat |grep -w 'apache-tomcat-bikemt'|grep -v 'grep'|awk '{print $2}')
echo "bikemt tomcat 新进程为:$TomcatNEWID"
