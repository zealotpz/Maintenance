PidNum=`ps -ef | grep nest | wc -l`;
if [ ${PidNum} -eq 1 ];then
    echo "nest 进程已关闭";
else
#PID=`ps -ef | grep tomcat | sed -n '1p' | awk -F " " '{print $2}'`;
NestPID=$(ps x|grep nest |awk '{print $1}')
    kill -9  ${NestPID};
    if [ ! $? ];then
            echo "关闭 nest 进程失败，请手动关闭";
            exit;
    fi;
fi;
echo "nest 进程关闭成功";

