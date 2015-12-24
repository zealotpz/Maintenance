#查找bikecc的tomcat进程并杀掉，备份 war 包并重新发布
#!/bin/bash
BIKECC_SDIR=/home/bike/apache-tomcat-bikecc
StartTomcat=/home/bike/apache-tomcat-bikecc/bin/
newfile=/home/bikegw/war_new/bikecc.war
#获取时间并格式化
time=`date +"%Y%m%d%H%M" `
#备份文件名
filename=bikecc_$time.war
#获取 tomcat 进程并杀掉
TomcatPID=$(ps -ef |grep tomcat |grep -w 'apache-tomcat-bikecc'|grep -v 'grep'|awk '{print $2}')
if [ "$TomcatPID" = "" ]
   then
    echo "tomcat 已关闭";
else
    echo "bikecc tomcat 进程ID:$TomcatPID"
    kill -9  ${TomcatPID};
    if [ ! $? ];then
            echo "关闭 tomcat 失败，请手动关闭";
            exit;
    fi;
fi;
echo "tomcat 关闭成功";

sleep 3
if [ ! -f "$newfile" ]; then
  echo "bikecc.war不存在，请上传文件！"
else
   echo "-------------------  开始备份并删除日志文件与旧 war 包  ----------------------";
   #拷贝文件至至war_backup目录，没有则新建目录
   mkdir -p /home/bikecc/war_backup/ && cp ${BIKECC_SDIR}/webapps/bikecc.war /home/bikecc/war_backup/$filename
   echo "-----------------------   备份成功！  ---------------------------"
   rm -rf ${BIKECC_SDIR}/logs/*
   rm -rf ${BIKECC_SDIR}/bin/logs/*
   rm -rf ${BIKECC_SDIR}/webapps/*
   echo "-----------------------   删除成功！  ---------------------------"
   cp /home/bike/war_new/whbike.war ${BIKECC_SDIR}/webapps/
   echo "-----------------------   新 war 拷贝成功！  --------------------------"
   echo "-----------------------   开始启动 bikecc Tomcat  --------------------------"
   #获取环境变量，否则提示找不到 NEST_HOME
   export NEST_HOME=/home/bike/NEST_FILE
   cd $StartTomcat
   nohup ./startup.sh &
   sleep 4 #等候4秒
   TomcatNEWID=$(ps -ef |grep tomcat |grep -w 'apache-tomcat-bikecc'|grep -v 'grep'|awk '{print $2}')
   echo "bikecc tomcat 新进程为:$TomcatNEWID"
fi
