Задача: Схема БД интернет-магазина содержит таблицы Company – производители телефонов, 
Phone – возможные для приобретения телефоны. Составить запрос для поиска количества и общей стоимости телефонов каждого производителя 
(в момент времени в интернет-магазине может не быть телефонов конкретного производителя).  

company				phone
-------				-------
companyId (PK)			phoneId (PK)
companyName			phoneModel
companyCountry			companyId (FK -> company.companyId)
				price

Решение:
SELECT DISTINCT company.companyName as CompanyName, COUNT(phoneModel) as ModelNumber, SUM(price) as TotalPrice
FROM phone
RIGHT OUTER JOIN company
ON phone.companyId=company.companyId
GROUP BY company.companyName;

Задача: для схемы данных из Задачи 1, составить запросы для:
a)	поиска производителя телефона с наибольшей средней стоимостью телефона этого производителя;
b)	определения количества китайских товаров;
c)	получения списка самых дорогих моделей телефонов каждого производителя.

Решение:
a)
SELECT TOP 1 company.companyName as CompanyName, AVG(phone.price) as AVGprice 
FROM phone
RIGHT OUTER JOIN company
ON phone.companyId=company.companyId
GROUP BY company.companyName
ORDER BY AVGprice DESC;
b)
SELECT DISTINCT company.companyName as CompanyName, COUNT(phoneModel) as ModelNumber
FROM phone
RIGHT OUTER JOIN company
ON phone.companyId=company.companyId
WHERE company.companyCountry='China'
GROUP BY CompanyName;
c)
WITH allProducts AS
(SELECT phone.phoneModel as Model, company.companyName as CompanyName, phone.price as Price,
ROW_NUMBER() OVER (PARTITION BY CompanyName ORDER BY Price DESC) ROW_NUM
FROM phone
RIGHT OUTER JOIN company
ON phone.companyId = company.companyId)
SELECT Model, CompanyName, Price
FROM allProducts
WHERE ROW_NUM = 1
ORDER BY Price DESC;
