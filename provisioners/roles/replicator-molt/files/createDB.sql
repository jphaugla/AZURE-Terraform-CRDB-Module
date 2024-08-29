drop database if exists employees;
create database employees;
\c employees
select 'create schema employees' where not exists (select from information_schema.schemata where schema_name = 'employees')\gexec
create role jhaugland  with login superuser password 'jasonrocks';
