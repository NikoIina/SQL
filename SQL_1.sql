Схема таблицы:

company				phone
-------				-------
companyId (PK)			phoneId (PK)
companyName			phoneModel
companyCountry			companyId (FK -> company.companyId)
				price

Решение 1:
SELECT DISTINCT company.companyName as CompanyName, COUNT(phoneModel) as ModelNumber, SUM(price) as TotalPrice
FROM phone
RIGHT OUTER JOIN company
ON phone.companyId=company.companyId
GROUP BY company.companyName;


Решение 2:
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
