--导出数据,按用户导
-----------------------------
expdp system/manager@orcl schemas=system dumpfile=expdp.dmp DIRECTORY=db_bak 
select * from dba_directories;
expdp system/manager@orcl dumpfile=expdp.dmp（/data/u01/oracle/admin/orcl/dpdump/）
------------------------------
--还原数据,导到指定用户下
impdp system/manager DIRECTORY=db_bak DUMPFILE=expdp.dmp SCHEMAS=system;
impdp system/manager DUMPFILE=XM.dmp remap_schema=XM_SBM:WH_SBM
(XM_SBM源，导入至WH_SBM)
