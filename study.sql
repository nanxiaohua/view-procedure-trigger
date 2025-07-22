show databases;
use itheima;
show tables;
select * from student;
-- 创建视图
create or replace view stu_v_1 as select id,name from student where id<=10;                                                   
-- 查询视图
show create view stu_v_1;
select * from stu_v_1;
select * from stu_v_1 where id<3;
-- 修改视图(的两种方法)
create or replace view stu_v_1 as select id,name,no from student where id<=10;
alter view stu_v_1 as select id,name from student where id<=10;
-- 删除视图
drop view if exists stu_v_1;

-- --------------------------------------------------------------------------------------------
create or replace view stu_v_1 as select id,name from student where id<=20;
select * from stu_v_1;
insert into stu_v_1 values(6,'Tom');
insert into stu_v_1 values(30,'Tom');                                                                    -- 插入未报错，执行select * from 该视图，发现查不到插入的该条记录(因创建该视图时，条件where id<=20)。该条记录实际被插入到基表当中(因视图不存储数据)。
create or replace view stu_v_1 as select id,name from student where id<=20 with cascaded check option;   -- 替换(修改)为该视图
insert into stu_v_1 values(6,'Tom');                                                                     -- 删掉基表中插入的两条记录。插入6Tom，插入未报错，select * from该视图可见该记录
insert into stu_v_1 values(30,'Tom');                                                                    -- 插入30Tom时会报错(check option阻止插入)。【注：这里cascaded也可换成local】

-- 视图的检查选项之cascaded
create or replace view stu_v_1 as select id,name from student where id<=20;                              -- 无with cascaded check option，在对stu_v_1视图进行增删改操作时，不会检查条件
insert into stu_v_1 values(5,'Tom');                                                                     -- 插入未报错
insert into stu_v_1 values(25,'Tom');                                                                    -- 插入未报错，因为stu_v_1视图无with check option
create or replace view stu_v_2 as select id,name from stu_v_1 where id>=10 with cascaded check option;   -- 创建基于视图stu_v_1的stu_v_2，而且有with cascaded check option，所以在对stu_v_2进行操作时，v2和v1的条件都需满足
insert into stu_v_2 values(7,'Tom');                                                                     -- 插入报错，因check option会检查该记录不满足stu_v_2的条件
insert into stu_v_2 values(26,'Tom');                                                                    -- 插入报错，因check option会检查该记录不满足stu_v_1的条件
insert into stu_v_2 values(15,'Tom');                                                                    -- 插入未报错，因该记录同时满足两个视图的条件
create or replace view stu_v_3 as select id,name from stu_v_2 where id<=15;                              -- 创建基于视图stu_v_2的stu_v_3，无with cascaded check option
insert into stu_v_3 values(11,'Tom');                                                                    -- 插入未报错
insert into stu_v_3 values(17,'Tom');                                                                    -- 插入未报错，因v3无with check option(操作v3本身无限制)，但v3基于v2(v2有级联检查，且基于v1)，所以递归往上检查：满足v2和v1的条件即可执行成功
insert into stu_v_3 values(28,'Tom');                                                                    -- 插入报错，满足v2(id>=10)，但不满足v1(id<=20) 

-- 视图的检查选项之local
create or replace view stu_v_4 as select id,name from student where id<=15;                               -- 操作v4无限制(v4无check option)
create or replace view stu_v_5 as select id,name from stu_v_4 where id>=10 with local check option;       -- 操作v5须满足v5条件(v5有local check option)，且v5基于v4(v4无check option，不需检查v4条件)。【总结来说，操作v5时，满足v5条件即可】
create or replace view stu_v_6 as select id,name from stu_v_5 where id<20;                                -- 操作v6本身无限制，但v6基于v5(v5有local check option，需满足v5条件)，v5基于v4(v4无check option，不需检查v4条件)。【总结来说，操作v6时，满足v5条件即可】......建完视图后，把基表中插入的几条记录都删掉(保留1234)
insert into stu_v_4 values(5,'Tom');                                                                      -- 插入未报错。【注：该记录实际被插入到基表student中】
insert into stu_v_4 values(16,'Tom');                                                                     -- 插入未报错。【注：该记录实际被插入到基表student中】
insert into stu_v_5 values(13,'Tom');                                                                     -- 插入未报错
insert into stu_v_5 values(17,'Tom');                                                                     -- 插入未报错
insert into stu_v_6 values(14,'Tom');                                                                     -- 插入未报错
create or replace view stu_v_4 as select id,name from student where id<=15 with local check option;       -- 重建v4视图。此时，操作v5时须满足v4、v5条件；操作v6时须满足v4、v5条件
insert into stu_v_5 values(18,'Tom');                                                                     -- 插入报错。v5有local check option(操作v5须满足v5条件)，且v5基于v4(v4有local check option，须满足v4条件)

-- 创建视图，使用聚合函数
create view stu_v_count as select count(*) from student;
insert into stu_v_count values(10);                                                                       -- 该视图的数据跟基表的数据不是一一对应的，使用了聚合函数count()，所以不能对该视图进行更新

-- 案例-----------------------------------------------------------------------------------------------------------------------------------------------------------------
 CREATE TABLE wz_user(
  id int NOT NULL,
  name varchar(10) DEFAULT NULL,
  phone char(11) DEFAULT NULL,
  email varchar(50) DEFAULT NULL,
  profession varchar(20) DEFAULT NULL,
  age int DEFAULT NULL,
  gender int DEFAULT NULL COMMENT '男1女2',
  status char(1) DEFAULT NULL,
  createtime timestamp NULL DEFAULT NULL,
  PRIMARY KEY (id),
  KEY idx_user_pro_age_sta (profession,age,status)
);
insert into wz_user values
	(1,'吕布','17799990000','lvbu666@163.com','软件工程',23,1,'6','2001-02-02 00:00:00'),
	(2,'曹操','17799990001','caocao666@qq.com','通讯工程',33,1,'0','2001-03-05 00:00:00'),
	(3,'赵云','17799990002','17799990@139.com','英语',34,1,'2','2002-03-02 00:00:00'),
    (4,'孙悟空','17799990003','17799990@sina.com','工程造价',54,1,'0','2001-07-02 00:00:00'),
    (5,'花木兰','17799990004','19980729@sina.com','软件工程',23,2,'1','2001-04-22 00:00:00'),
    (6,'大乔','17799990005','daqiao666@sina.com','舞蹈',22,2,'0','2001-02-07 00:00:00'),
    (7,'露娜','17799990006','luna_love@sina.com','应用数学',24,2,'0','2001-02-08 00:00:00'),
    (8,'程咬金','17799990007','chengyaojin@163.com','化工',38,1,'5','2001-05-23 00:00:00'),
    (9,'项羽','17799990008','xiangyu666@qq.com','金属材料',43,1,'0','2001-09-18 00:00:00'),
    (10,'白起','17799990009','baiqi666@sina.com','机械工程及其自动化',27,1,'2','2001-08-16 00:00:00'),
    (11,'韩信','17799990010','hanxin520@163.com','无机非金属材料工程',27,1,'0','2001-06-12 00:00:00'),
    (12,'荆轲','17799990011','jingke123@163.com','会计',29,1,'0','2001-05-11 00:00:00'),
    (13,'兰陵王','17799990012','lanlingwang666@126.com','工程造价',44,1,'1','2001-04-09 00:00:00'),
    (14,'狂铁','17799990013','kuangtie@sina.com','应用数学',43,1,'2','2001-04-10 00:00:00'),
    (15,'貂蝉','17799990014','84958948374@99.com','软件工程',40,2,'3','2001-02-12 00:00:00'),
    (16,'妲己','17799990015','2783238293@qq.com','软件工程',31,2,'0','2001-01-30 00:00:00'),
    (17,'芈月','17799990016','xiaomin2001@sina.com','工业经济',35,2,'0','2000-05-03 00:00:00'),
    (18,'嬴政','17799990017','8839434342@qq.com','化工',38,1,'1','2001-08-08 00:00:00'),
    (19,'狄仁杰','17799990018','jujiamlm8166@163.com','国际贸易',30,1,'0','2007-03-12 00:00:00'),
    (20,'安琪拉','17799990019','jdodm1h@136.com','城市规划',51,2,'0','2001-08-15 00:00:00'),
    (21,'典韦','17799990020','ycaunanjian@163.com','城市规划',52,1,'2','2000-04-12 00:00:00'),
    (22,'廉颇','17799990021','lianpo321@126.com','土木工程',19,1,'3','2002-07-18 00:00:00'),
    (23,'后羿','17799990022','altycj2000@139.com','城市园林',20,1,'0','2002-03-10 00:00:00'),
    (24,'姜子牙','17799990023','37483844@qq.com','工程造价',29,1,'4','2003-05-26 00:00:00');                                                                      -- 数据准备
-- 1.为了保证数据库表的安全性，开发人员在操作wz_user表时，只能看到用户的基本字段，屏蔽手机号和邮箱两个字段
create view wz_user_view as select id,name,profession,age,gender,status,createtime from wz_user;
-- 查询每个学生所选修的课程(三张表联查)，这个功能在很多业务中都有使用到，为了简化操作，定义一个视图
select s.name,s.no,c.name from student s,student_course sc,course c where s.id=sc.studentid and sc.courseid=c.id;
create view stu_course_view as select s.name student_name,s.no student_no,c.name course_name from student s,student_course sc,course c where s.id=sc.studentid and sc.courseid=c.id;
select * from stu_course_view;                                                                                                                       -- 后续业务中，只需查询这个视图即可，很方便


-- 存储过程基本语法--------------------------------------------------------------------------------------------------------------------------------------
-- 创建存储过程(第一种方法)
delimiter $$
create procedure p1()
begin
	select count(*) from student;
end $$
-- 创建存储过程(第二种方法)
delimiter //                                                                      -- 先修改分隔符(避免存储过程体内的分号被误解析)。delimiter之后一定要有空格
create procedure p1()                                                             -- 创建存储过程
begin
	select count(*) from student;
end //                                                                            -- 这里用//结束整个存储过程
delimiter ;                                                                       -- 恢复默认分隔符
-- 调用存储过程
call p1();
-- 查看存储过程
select * from information_schema.ROUTINES where ROUTINE_SCHEMA='itheima';         -- 查询指定数据库的存储过程及状态信息
show create procedure p1;                                                         -- 当然，在这个图形化界面，可以直接在数据库下面的stored procedures目录中查看
-- 删除
drop procedure if exists p1;

-- 变量--
-- 查看系统变量
show variables;                                                                    -- 查看系统变量(默认session级别，相当于show session variables)
show session variables;
show session variables like 'auto%';                                               -- 模糊匹配查找（当前会话界面）的变量:auto...
show global variables like 'auto%';                                                -- 模糊匹配查找(全局)变量:auto...
select @@autocommit;                                                               -- autocommmit(事务的自动提交)为1。【注：1为自动提交，0为手动提交】
select @@session.autocommit;                                                       -- 不指定级别则默认session级别，注意session后加.
select @@global.autocommit;
-- 设置系统变量
set session autocommit=0;                                                          
select @@session.autocommit;                                                           
insert into course(id,name) values(5,'Oracle');
commit;                                                                            -- 设置autocommit为0后要commit，才能在另外的控制台看到所做操作

set session autocommit=1;   
insert into course(id,name) values(6,'ES');                                        -- 恢复autocommit为1后，直接执行就可在另外控制台看到所做操作

set global autocommit=0;                                                           -- 修改global(全局)级别的autocommit参数，影响的是后续新建连接会话的global.autocommit【注：session和global是相互独立的，session.autocommit值不受影响】
select @@global.autocommit;                                                        -- 执行成功。另外控制台执行该语句执行也是global.autocommit=0(原因如上)。【注意：在命令行执行systemctl restart mysql或wsl ubuntu执行sudo systemctl restart mysql，也就是重启MySQL后，该值又恢复默认1。若要永久修改参数值，可以在/etc/my.cnf中配置】

-- 用户自变量的赋值、使用
set @myname='itcast';
set @myage:=10;                                                                    -- 两种sql语句都可，但推荐使用:=，因为在MySQL中等号可以表比较也可用于赋值，为区分清楚，赋值时用:=
set @mygender:='男',@myhobby:='java';
select @myname,@myage,@mygender,@myhobby;
set @mycolor:='red';
select count(*) into @mycount from wz_user;                                        -- 将一个表的查询结果值，赋值给自定义变量mycount(自定义变量前加@)
select @mycolor,@mycount;
select @abc;                                                                       -- 该自定义变量未做声明，所以该变量值为null

-- 局部变量的声明、赋值
delimiter //
create procedure p2()
begin
	declare stu_count int default 0;                                               -- 声明局部变量stu_count (不同于用户自定义变量，局部变量需要声明，其作用域为当前begin...end块)
    select count(*) into stu_count from student;                                   -- 若直接给局部变量stu_count赋值，set stu_count:=100;
    select stu_count;
end //
delimiter ;
call p2();                                                                         -- 【注：局部变量的范围是在其内声明的begin...end块】


-- 【关于if的案例1】根据定义的分数score变量，判定当前分数对应的分数等级。score>=85分，等级为优秀；score>=60分且score<85分，等级为及格；score<60分，等级为不及格
delimiter //
create procedure p3()
begin
	declare score int default 58;
    declare result varchar(10);
    if score>=85 then set result:='优秀';
	elseif score>=60 then set result:='及格';
    else set result:='不及格';
    end if;
    select result;
end //
delimiter ;
call p3();                                                                                 -- p3这个存储过程中定义死了score值

-- 【关于if的案例2】根据传入参数score，判定当前分数对应的分数等级。score>=85分，等级为优秀；score>=60分且score<85分，等级为及格；score<60分，等级为不及格
delimiter //                                                                       
create procedure p4(in score int,out result varchar(10))                                   -- in(传入参数)为score int，out(传出参数)为result varchar(10)                
begin
	if score>=85 then set result:='优秀';
    elseif score>=60 then set result:='及格';
    else set result:='不及格';
    end if;
end //
delimiter ;                                                                               
call p4(68,@result);                                                                       -- 调用p4要写参数，参数包括需判断的score值和用来接收结果的用户自定义变量@result
select @result;                                                                            -- 查看@result
call p4(98,@result);
select @result;                                                                            
call p4(18,@result);
select @result;   

-- 将传入的200分制的分数进行换算，换算成百分制，然后返回分数
delimiter //
create procedure p5(inout score double)                                                    -- INOUT表示该参数既能传入也能传出；score是参数名称；double(双精度浮点数)表示限定参数必须是双精度浮点数【MySQL中的一种浮点型数据类型】
begin
	set score:=score*0.5;
end //
delimiter ;
set @score=198;
call p5(@score);  
select @score;

-- 【关于case的存储过程的案例】根据传入的月份，判定月份所属的季节(要求采用case结构)。1-3月份为第一季度，4-6月份为第二季度，7-9月份为第三季度，10-12月份为第四季度
delimiter //
create procedure p6(in month int)     
begin
	declare result varchar(10);
    case
		when month>=1 and month<=3 then set result:='第一季度';
		when month>=4 and month<=6 then set result:='第二季度';
		when month>=7 and month<=9 then set result:='第三季度';
		when month>=10 and month<=12 then set result:='第四季度';
		else set result:='非法参数';
    end case;
	select concat('您输入的月份为：',month,',所属的季度为：',result);                            -- 字符串拼接函数concat，将这三部分文字拼接在一起          
end //
delimiter ;
call p6(4);
call p6(16);

-- 【关于while的案例】计算从1累加到n的值，n为传入的参数值
delimiter //
create procedure p7(in n int)
begin
	declare total int default 0;          -- 定义局部变量total(记录累加之后的值)
    while n>0 do
		set total:=total+n;
		set n:=n-1;
    end while;
    select total;
end //
delimiter ;                               -- 总结：while循环是先判断while的条件是否满足，是则进行while循环体，否则不进行                                                            
call p7(10);
call p7(100); 

-- 【关于repeat的案例】计算从1累加到n的值，n为传入的参数值
delimiter //
create procedure p8(in n int)
begin
	declare total int default 0;
    repeat
		set total:=total+n;
        set n:=n-1;
        until n=0                -- 直到n=0结束循环【注:until部分不加分号，后面直接跟end repeat;】
	end repeat;
	select total;
end //
delimiter ;                      -- 总结：repeat循环是先执行一次repeat循环体(until之前的逻辑)，直到until的条件满足时结束repeat循环
call p8(10);
call p8(100);

-- 【关于loop的案例1】计算从1累加到n的值，n为传入的参数值
delimiter //
create procedure p9(in n int)
begin
	declare total int default 0;
    
    sum:loop                                       -- loop循环体开始【xxx:loop→sum是该loop循环的名字】
		if n<=0 then leave sum;                    -- 若n<=0，则退出loop循环
		end if;                                    -- if...then...和end if;必须闭环
        set total:=total+n;
        set n:=n-1;
    end loop sum;                                  -- loop循环体结束【sum:loop和end loop sum;必须闭环】
    
    select total;                                  -- loop循环体结束后，取出total值
end //
delimiter ;
call p9(10);
call p9(100);
-- 【关于loop的案例2】计算从1到n之间的偶数累加的值，n为传入的参数值
delimiter //
create procedure p10(in n int)
begin
	declare total int default 0;
    
    sum:loop                                                  -- loop循环体开始
		if n<=0 then leave sum;
        end if;                                               -- 若n<=0，则直接退出loop循环
        if n%2=1 then set n:=n-1; iterate sum;                -- 若n为奇数，则给n赋值n-1，跳过该一轮循环(不执行下面的累加操作，从循环体开头开始下一轮)
        end if;
        set total:=total+n;
        set n:=n-1;
	end loop sum;
    
    select total;
end //
delimiter ;
call p10(10);
call p10(100);





delimiter //
create procedure p11()
begin
	declare stu_count int default 0;                       
    select * into stu_count from student;                   -- 取student表的所有数据，赋值给stu_count(int类型)是不合法的。调用p11会报错1222(列数不匹配)
    select stu_count;
end //
delimiter ;                                                 -- 总结：自己定义的简单类型(int\varchar()等)的局部变量，是无法被赋值为表数据的，要用到游标
call p11;
drop procedure p11;


-- 游标---------------------------------------------------------------------------------------------------------------
-- 根据传入的参数uage，来查询用户表wz_user中，所有的用户年龄小于等于uage的用户姓名(name)和专业(profession)，并将用户的姓名和专业插入到所创建的一张新表(id,name,profession中)
delimiter //
create procedure p11(in uage int)
begin
	declare uname varchar(100);                                                                 -- 先声明常规变量
    declare upro varchar(100);
    declare u_cursor cursor for select name,profession from wz_user where age<=uage;            -- 再声明游标(将查询结果集封装在u_cursor这个游标中)

    drop table if exists wz_user_pro;
    create table if not exists wz_user_pro(
		id int primary key auto_increment,
        name varchar(100),
        profession varchar(100)
	);                                                                                           -- 根据要求建新表
    
	open  u_cursor;                                                                                      
    while true do
		fetch u_cursor into uname,upro;
        insert into wz_user_pro values(null,uname,upro);
    end while;
    close u_cursor;
end //
delimiter ;
call p11(40);                                                                                    -- 调用p11会报错[02000][1329]，这是因为p11的while循环体是无限循环的(while true do)，但此时新表wz_user_pro里显示的记录是正确的
	
delimiter //
create procedure p12(in uage int)
begin
	declare uname varchar(100);                                                                 -- 先声明常规变量
    declare upro varchar(100);
    declare u_cursor cursor for select name,profession from wz_user where age<=uage;            -- 再声明游标(将查询结果集封装在u_cursor这个游标中)
	declare exit handler for sqlstate '02000' close u_cursor;                                   -- 声明一个(退出)条件处理程序(handler):当SQL状态码为02000时触发“close u_cursor”。
                                                                                                -- 【声明handler时有sqlstate 状态码、sqlwarning、not found、sqlexception】【例如此案例就可以换为decalre exit handler for not found close u_cursor，表示声明一个条件处理程序：当报错not found时触发"close u_cursor"】
    drop table if exists wz_user_pro;
    create table if not exists wz_user_pro(
		id int primary key auto_increment,
        name varchar(100),
        profession varchar(100)
	);                                                                                           -- 根据要求建新表
    
	open  u_cursor;                                                                                      
    while true do                                                                                -- while循环体开始【注：此处while的条件是true，可能无限循环，所以声明部分有条件处理程序exit handler】
		fetch u_cursor into uname,upro;                                                          -- 在抓取不到数据报错后，会进行到条件处理程序，触发“关闭u_cursor”这个操作
        insert into wz_user_pro values(null,uname,upro);
    end while;
    close u_cursor;
end //
delimiter ;
call p12(30);                                                                                     -- 调用p12不会报错

-- 【关于存储函数的案例】从1到n的累加
delimiter //
create function fun1(n int) returns int deterministic
begin
	declare total int default 0;
    
    while n>0 do
		set total:=total+n;
        set n:=n-1;
	end while;

	return total;
end //
delimiter ;
select fun1 (100);                                -- 调用fun1;
-- 总结：存储函数能实现的存储过程都能实现，因存储函数有其局限性：参数必须只能是IN类型、必须有返回值





-- 触发器-------------------------------------------------------------------------------------------------------
-- 案例：通过触发器记录wz_user表的数据变更日志(user_logs)，包含增加/修改/删除--
create table user_logs(
	id int(11) not null auto_increment,
    operation varchar(20) not null comment'操作类型，insert/update/delete',
    operation_time datetime not null comment'操作时间',
    operate_id int(11) not null comment'操作的ID',
    operate_params varchar(500) comment'操作参数',
    primary key(id)
    )engine=InnoDB default charset=utf8;                                  -- 准备工作

-- 创建insert型触发器
delimiter //
create trigger wz_user_insert_trigger 
	after insert on wz_user for each row
begin
	insert into user_logs(id,operation,operation_time,operate_id,operate_params) values(
		null,'insert',now(),new.id,concat('插入的数据内容为：id=',new.id,'，name=',new.name,'，phone=',new.phone,'，email=',new.email,'，profession=',new.profession)
	);
end //
delimiter ;                                                                               
show triggers;                                       -- 建完触发器之后，图形化界面的导航中展示不出来，用show指令能展示触发器的各信息(监控什么类型的操作、监控的表、何时触发after/before)
drop trigger wz_user_insert_trigger;                 -- 删除指定触发器(可之后再用show查看是否删成功)
-- 测试insert型触发器
insert into wz_user values(25,'二皇子','18809091212','erhuangzi@163.com','软件工程',23,1,'1',now());             
insert into wz_user values(26,'三皇子','18809091213','sanhuangzi@163.com','软件工程',23,1,'1',now());          -- 触发器有没有生效，刷新看日志表(user_log)中有无数据

-- 创建update型触发器
delimiter //
create trigger wz_user_update_trigger
	after update on wz_user for each row
begin
	insert into user_logs values(null,'update',now(),new.id,concat('更新前的数据：id=',old.id,'，name=',old.name,'，phone=',old.phone,'，email=',old.email,'，profession=',old.profession,'|更新后的数据：id=',new.id,'，name=',new.name,'，phone=',new.phone,'，email=',new.email,'，profession=',new.profession));
end //
delimiter ; 
drop trigger wz_user_update_trigger;                                   
show triggers;
-- 测试update型触发器
update wz_user set age=20 where id=23;
update wz_user set profession='会计' where id=23;     -- 若这两个update是对同一行的操作，若同时执行两个update(等价于直接在图形化界面修改相关表数据)，触发器生效一次，日志表user_logs中仅增一条记录；若分开执行两个update，触发器生效两次，日志表会增两条记录
update wz_user set profession='会计' where id<=5;     -- 触发器生效五次，即日志表增五条记录(现在触发器只支持行级触发，affect多少行触发器就生效多少次)

-- 创建delete型触发器
delimiter //
create trigger wz_user_delete_trigger
	after delete on wz_user for each row
begin
	insert into user_logs values(null,'delete',now(),old.id,concat('已删的数据内容为：id=',old.id,'，name=',old.name,'，phone=',old.phone,'，email=',old.email,'，profession=',old.profession));
end //
delimiter ;
-- 测试delete型触发器
show triggers;
delete from wz_user where id=25;
delete from wz_user where id=26;



