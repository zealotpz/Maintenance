
###Oracle锁表的原因及解锁方法

    整个系统突然挂掉，su 无法切换用户，修改用户最大进程数后可以登录，重启服务后系统仍不正常，
  后发现为 plsql 上修改 T_XXX_XXXX 表时有事务未提交，因此排查原因为更改数据没有提交事务，数据库就将表锁住。
  
  
产生的原因最大的可能就是更改数据没有提交事务，数据库就将表锁住！所以在更新时不要用select * from a for update这样的语句很容易锁表，可能用select *,t.rowid from t 这样的语句代替，这个也是数据库推荐使用的语句。
解锁的方法：

1、查看锁表进程：
```sql
SQL：select * from v$session t1, v$locked_object t2 where t1.sid = t2.SESSION_ID;
```
2、将锁住的进程杀掉
```sql
SQL：alter system kill session SID,serial#;
```
