use db104;
select * from emp;
select ename employee_Name from emp;
select distinct(job) from emp;
select * from emp order by empno desc limit 5;
select ename,substr(ename,1,3) from emp;
select count(ename) from emp where ename like "%a%";
select deptno,max(sal) from emp group by deptno;
select replace(ename,'A','a') from emp;
select * from emp order by ename ;
select * from emp order by deptno ;
select ename,sal from emp where sal=(select max(sal) from emp);
select * from emp where ename not in ('SMITH','MILLER');
select * from emp where ename like "_____r";
select * , year(hiredate),month(hiredate)  from emp where year(hiredate)='1981'and month(hiredate)='2';
select empno,count(*) from emp group by empno having count(*) >1;
select *, row_number() over(partition by empno order by ename) from emp where mod(empno,2);
CREATE TABLE Newemployee AS SELECT * FROM emp;
select * from Newemployee;
select * from emp order by empno limit 10;
select  distinct(sal) from emp order by sal desc limit 5;
SELECT MAX(sal) AS fifth_highest_salary FROM emp WHERE sal < (SELECT MAX(sal) FROM emp WHERE sal < (SELECT MAX(sal) FROM emp 
WHERE sal < (SELECT MAX(sal) FROM emp WHERE sal< (SELECT MAX(sal) FROM emp))));
select ename,sal from emp where sal IN (select  sal from emp group by sal having count(*)>1);






 

 

