#!/bin/bash
#本地文件存放目录
LOCAL_DIR=/Users/zealotpz/Bike/localhost/Ebike
BIKEGW_DIR=/Users/zealotpz/SvnFile/bikeGW-nre
BIKECC_DIR=/Users/zealotpz/SvnFile/bikecc-nre
BIKEMT_DIR=/Users/zealotpz/SvnFile/nest/develop/5代码/01code/trunk/nest-nre
SERVICEIP=
#================= 网关-5080 maven install bike-gw =================
cd ${BIKEGW_DIR}
echo "--------------------- 开始打包<bikegw>bikegw.war  --------------------"
mvn clean install
if [ $? -eq 0 ]; then
#成功
echo "-------------------- <网关>bikegw.war 打包成功！！ --------------------"
cp -f ${BIKEGW_DIR}/target/web-context.war ${LOCAL_DIR}/bikegw.war
echo "---------------------<网关>bikegw.war 复制EBIKE成功 --------------------"
#-----------------------开始上传至服务器
echo "-------------------- 开始上传 网关 至测试服务器  --------------------"
sftp bikegw@${SERVICEIP}<<EOF
-put ${LOCAL_DIR}/bikegw.war /home/bikegw/war_new
quit
EOF
echo "-----------------------  上传成功！  ------------------------------"
echo "-----------------------  开始备份并删除！  ---------------------------"
#  参数-tt 为脚本调用 ssh，否则无法登录；登录后调用服务器脚本
ssh -tt bikegw@${SERVICEIP} "/home/bikegw/publish_bikegw.sh"<<EOF
quit
EOF
else
#失败
echo "-------------------- !!<网关>bikegw.war 打包失败 --------------------"
fi
