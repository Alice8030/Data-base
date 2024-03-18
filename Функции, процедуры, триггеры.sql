#1
/*Функция, которая находит разницу между всем количеством поступивших и всем количеством выданных лекарств*/
CREATE DEFINER=`root`@`localhost` FUNCTION `Difference_receipt_giving`(id int) RETURNS int
    DETERMINISTIC
begin
declare razn int;
declare kolv1 int;
declare kolv2 int;
select SUM(Quantity) into kolv1 from journal_of_receipt where Medicine_id = id;
select SUM(Quantity) into kolv2 from journal_of_giving where Medicine = id;
set razn = kolv1 - kolv2;
return razn;
end

#2
/*Функция, которая находит общее количество запрошенного медикамента данным отделением*/
CREATE DEFINER=`root`@`localhost` FUNCTION `Requests`(idMed int, idDep int) RETURNS int
    DETERMINISTIC
begin
declare staf int;
declare zakaz int;
select MIN(id) into staf from staff where Department_id = idDep;
select SUM(Quantity) into zakaz from journal_of_giving where Medicine = idMed and Request = staf;
return zakaz;
end

#3
/*Изменение места хранения лекарства*/
CREATE DEFINER=`root`@`localhost` PROCEDURE `change_local`(in idMed INT, in idLoc INT)
begin
update medicine set Storage_id=idLoc where id = idMed;
end

#4
/*Добавление записи в журнал поступления*/
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_row`(in idMed INT, in idPro INT, in Quan INT, in D_T TIMESTAMP)
begin
insert into journal_of_receipt(Medicine_id, Provider_id, Quantity, Date_Time) values (idMed, idPro, Quan, D_T);
end

#5
/*Удаление записи из журнала поступления*/
CREATE DEFINER=`root`@`localhost` PROCEDURE `drop_row`(in ID INT, in idMed INT, in idPro INT)
begin
delete from journal_of_receipt
where (Medicine_id=idMed and Provider_id=idPro and id=ID);
end

#6
/*Подсчет общего количества поступивших медикаментов от поставщика*/
CREATE DEFINER=`root`@`localhost` PROCEDURE `quantity`(in idPro INT)
begin
select  provider.Name as 'Поставщик',
		SUM(Quantity_in_stock) as 'Количество медикаментов'
from medicine left join journal_of_receipt on medicine.id=journal_of_receipt.Medicine_id
			       join provider on journal_of_receipt.Provider_id=provider.id
where (provider.id=idPro);
end

#7
/*Выписка из журнала выдачи о том, кто, в каком количестве, какое лекарство запросил*/
CREATE DEFINER=`root`@`localhost` PROCEDURE `table`()
begin
select concat(Surname, ' ', staff.Name, ' ', Second_name) as 'ФИО',
	   medicine.Name as 'Медикаменты',
	   SUM(Quantity) as 'Количество медикаментов'
from medicine left join journal_of_giving on medicine.id = journal_of_giving.Medicine
                   join staff on journal_of_giving.Request = staff.id
group by `Медикаменты`;
end

#8
/*Триггер для обновления общего количества медикаментов на складе после выдачи очередных лекарств*/
CREATE DEFINER=`root`@`localhost` TRIGGER `journal_of_giving_AFTER_INSERT` AFTER INSERT ON `journal_of_giving` FOR EACH ROW BEGIN
update medicine
set `Quantity_in_stock` = Quantity_in_stock - new.quantity
where new.Medicine = medicine.`id`;
END

#9
/*Триггер для обновления общего количества медикаментов на складе после поступления новой партии*/
CREATE DEFINER=`root`@`localhost` TRIGGER `journal_of_receipt_AFTER_INSERT` AFTER INSERT ON `journal_of_receipt` FOR EACH ROW BEGIN
update medicine
set `Quantity_in_stock` = Quantity_in_stock + new.Quantity
where new.Medicine_id = medicine.`id`;
END