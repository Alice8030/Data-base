#1
/*Запрос для вывода всей информации о лекарствах кроме столбца storage_id.*/

select id, 
	   Name as 'Название', 
	   Dosage as 'Дозировка', 
       Annotation as 'Аннотация', 
       Quantity_in_stock as 'Количество на складе' from medicine -- вывод столбцов таблицы
       order by Название asc; -- Сортировка по алфавиту
       
#2
/*Запрос для вывода ФИО сотрудников, у которых номер телефона начинается на «896» и которые работают в отделении с id не равным 2.*/
select concat (Surname, ' ', Name, ' ', Second_name) as 'ФИО' -- используется функция concat(), которая соединяет значения столбцов в одну строчку
from staff
where Phone like '896%' and Department_id!=2;  

#3
/*Запрос для вывода названий лекарств, поступивших между 01-03-2021 и 01-05-2021, id которых меньше 15. */
select Name as 'Название лекарства' 
from medicine join journal_of_receipt on medicine.id=journal_of_receipt.Medicine_id -- соединение двух таблиц
where medicine.id < 15 and date(Date_Time) between '2021-02-01' and '2021-05-01';  -- используется функция date, которая берет только дату

#4
/*Запрос для вывода ФИО и отделения сотрудников, фамилии которых начинаются на «М» */
select concat (Surname, ' ', staff.Name, ' ', Second_name) as 'ФИО', -- используется функция concat(), которая соединяет значения столбцов в одну строчку
	   department.Name as 'Отделение'
from staff join department on staff.Department_id=department.id -- соединение двух таблиц
where Surname like 'М%';  

#5
/*Запрос, который позволит найти лекарства и их количество, которые хранятся в том же месте, что и лекарства с ID от 15 до 20.*/
select Name as 'Название лекарства',
       Quantity_in_stock as 'Количество'
from medicine 
where (Storage_id=any(select Storage_id from medicine /*Если хотя бы одно из сравнений даст положительный результат, то проверка ANY также завершится с результатом TRUE, 
														иначе подзапрос просигнализирует значением FALSE*/
where id between 15 and 20))
order by `Название лекарства`; -- Сортировка по алфавиту

#6
/*Запрос для подсчета количества запрошенных расходных материалов зав.отделениями по ID сотрудника, исключить запись для тех, кто запросил в общем количестве меньше 50*/
select Request as 'ID зав.отделения',
       SUM(Quantity) as 'Количество расходных материалов' -- используется агрегирующая функция SUM(), которая вычисляет сумму значений
from journal_of_giving
where Medicine between 16 and 21
group by `ID зав.отделения` -- группировка по id сотрудника
having `Количество расходных материалов`>50; -- исключение 

#7
/*Вывести название, аннотацию, дозировку и поставщика всех лекарств, у которых название производящей фарм.компании заканчивается на «er».*/
select medicine.Name as 'Название',
       Dosage as 'Дозировка',
       Annotation as 'Аннотация',
	   provider.Name as 'Поставщик'
from medicine left join journal_of_receipt on medicine.id=journal_of_receipt.Medicine_id -- левое внешнее соединение таблиц
			       join provider on journal_of_receipt.Provider_id=provider.id
                   join medicine_has_pharm_company on medicine.id=medicine_has_pharm_company.Medicine_id
                   join pharm_company on medicine_has_pharm_company.Pharm_Company_id=pharm_company.id
where pharm_company.Name like '%er';
