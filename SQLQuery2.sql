--DML : Data Maniputation Language
--��������Ǣ����� insert into
insert into Department(deptName, deptPhone)
values('IT','1111111');

insert into Department(deptName)
values('Accounting');

insert into Department(deptPhone)
values('3333333');

insert into Employee
values('A0001','������','�Ҩ������', 'oterobot@gmail.com', NULL, NULL);

insert into Employee(empID, email,deptID)
values('A0132','doriblo@gmail.com',1);

select * from Department;
select * from Employee;

--คำสั่ง update
UPDATE Employee
set deptID = 1 ,    
    firstName = 'Rewades' , 
    lastName = 'Sukprasert'
WHERE empID = 'A0001'

-- คำสั่ง Delete
Delete from Employee
where empID = 'A0001';
