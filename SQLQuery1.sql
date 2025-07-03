CREATE DATABASE tsetdb;
go
use tsetdb;

--Drop Database tsetdb; ź�ҹ������

CREATE TABLE Department (
deptID int identity ,
deptNAME nVarchar(40) ,
deptPHONE Varchar(10),
Constraint PK_Department Primary Key(deptID)
);


CREATE TABLE Employee (
empID		char(6),
firstNAME	nVarchar(30) ,
lastNAME	nVarchar(40),
emial		Varchar(50),
salary		money,
deptID		int , 
Constraint PK_Employee Primary Key(empID),
Constraint FR_Employee_Department Foreign Key(deptID)
	References Department(deptID)
	on Update cascade
	on Delete set null
);

Alter Table Employee
	Add birthdate datetime;

	--rename column
	EXEC sp_rename 'Employee.emial', 'email', 'COLUMN';
	EXEC sp_rename '���͵��ҧ.���ͤ����(���)', '���ͤ��������', 'COLUMN';

	--��䢵��ҧ�ͧ����� email �ͧ���ҧ Employee ����� Varchar(60) �����繵�ç
	Alter Table Employee
		Alter column email Varchar(60) Not Null;

	--��䢵��ҧ Employee ��ź����� birthdate
	Alter Table Employee
		Drop column birthdate

		select * From Employee;


--Alter Table Department
--Add Constraint PK_Department

Alter Table Department
Add Constraint PK_Department Primary Key(deptID);

--ź���ҧ
--Drop Table  Department;