!/bin/bash
#本地文件存放目录
LOCAL_DIR=/Users/zealotpz/Bike/localhost/Ebike
#需打包项目路径
BIKEGW_DIR=/Users/zealotpz/SvnFile/bikeGW-nre
BIKECC_DIR=/Users/zealotpz/SvnFile/bikecc-nre
BIKEMT_DIR=/Users/zealotpz/SvnFile/nest/develop/5代码/01code/trunk/nest-nre
#服务器ip
SERVICEIP=123.456.789
#================= 网关-5080 maven install bike-gw =================
cd ${BIKEGW_DIR}
echo "--------------------- 开始打包<网关>bikegw.war  --------------------"
mvn clean install
if [ $? -eq 0 ]; then
#成功
echo "---------------------<网关>bikegw.war 打包成功！！ --------------------"
else
#失败
echo "-------------------- !!<网关>bikegw.war 打包失败 --------------------"
fi
cp -f ${BIKEGW_DIR}/target/web-context.war ${LOCAL_DIR}/bikegw.war
echo "---------------------<网关>bikegw.war 复制EBIKE成功 --------------------"
#-----------------------开始上传至服务器
echo "-------------------- 开始上传至测试服务器  --------------------"
sftp bike@${SERVICEIP}<<EOF
-put ${LOCAL_DIR}/bikegw.war /home/bike/
quit
EOF
echo "-----------------------  上传成功！  ------------------------------"

#================= Bikemt-7080 maven install bike-gw =================
cd ${BIKEMT_DIR}
echo "--------------------- 开始打包<bikemt>bikemt.war  --------------------"
mvn clean install
if [ $? -eq 0 ]; then
#成功
echo "---------------------<bikemt>bikemt.war 打包成功！！ --------------------"
else
#失败
echo "-------------------- !!<bikemt>bikemt.war 打包失败 --------------------"
fi
cp -f ${BIKEMT_DIR}/target/web-context.war ${LOCAL_DIR}/bikemt.war
echo "---------------------<bikemt>bikemt.war 复制EBIKE成功 --------------------"
#-----------------------开始上传至服务器
echo "-------------------- 开始上传 bikemt 至测试服务器  --------------------"
sftp bike@${SERVICEIP}<<EOF
-put ${LOCAL_DIR}/bikemt.war /home/bike/
quit
EOF
echo "-----------------------  上传成功！  ------------------------------"

#================= Bikecc-8080 maven install bike-gw =================
cd ${BIKECC_DIR}
echo "--------------------- 开始打包<bikecc>bikecc.war  --------------------"
mvn clean install
if [ $? -eq 0 ]; then
#成功
echo "---------------------<后台调度>bikecc.war 打包成功！！ --------------------"
else
#失败
echo "-------------------- !!<后台调度>bikecc.war 打包失败 --------------------"
fi
cp -f ${BIKECC_DIR}/target/web-context.war ${LOCAL_DIR}/bikecc.war
echo "---------------------<后台调度>bikecc.war 复制EBIKE成功 --------------------"
#-----------------------开始上传至服务器
echo "-------------------- 开始上传 后台调度 至测试服务器  --------------------"
sftp bike@${SERVICEIP}<<EOF
-put ${LOCAL_DIR}/bikecc.war /home/bike/
quit
EOF
echo "-----------------------  上传成功！  ------------------------------"
