PidNum=`ps -ef | grep tomcat | wc -l`;
if [ ${PidNum} -eq 1 ];then
    echo "tomcat 已关闭";
else
#PID=`ps -ef | grep tomcat | sed -n '1p' | awk -F " " '{print $2}'`;
TomcatPID=$(ps -ef |grep tomcat |grep -w 'apache-tomcat-bikecc'|grep -v 'grep'|awk '{print $2}')
    kill -9  ${TomcatPID};
    if [ ! $? ];then
            echo "关闭 tomcat 失败，请手动关闭";
            exit;
    fi;
fi;
echo "tomcat 关闭成功";
