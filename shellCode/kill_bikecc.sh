#查找bikecc的tomcat进程并杀掉，备份 war 包并重新发布
#!/bin/bash
BIKECC_SDIR=/home/bike/apache-tomcat-bikecc
StartTomcat=/home/bike/apache-tomcat-bikecc/bin/
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

echo "-------------------  开始备份并删除日志文件与旧 war 包  ----------------------";
cp ${BIKECC_SDIR}/webapps/*.war /home/bike/war_backup
echo "-----------------------   备份成功！  ---------------------------"
rm -rf ${BIKECC_SDIR}/logs/*
rm -rf ${BIKECC_SDIR}/bin/logs/*
rm -rf ${BIKECC_SDIR}/webapps/*
echo "-----------------------   删除成功！  ---------------------------"
cp /home/bike/war_new/whbike.war ${BIKECC_SDIR}/webapps/
echo "-----------------------   新 war 拷贝成功！  --------------------------"
echo "-----------------------   开始启动 bikecc Tomcat  --------------------------"
cd $StartTomcat
nohup ./catalina.sh start &
sleep 4 #等候4秒
TomcatNEWID=$(ps -ef |grep tomcat |grep -w 'apache-tomcat-bikecc'|grep -v 'grep'|awk '{print $2}')
echo "bikecc tomcat 新进程为:$TomcatNEWID"

