set search_path = "$user", public, employees;
alter table department set schema public;
alter table department_employee set schema public;
alter table department_manager set schema public;
alter table employee set schema public;
alter table salary set schema public;
alter table title set schema public;
