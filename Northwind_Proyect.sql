-- Realizando el analisis y manejo de la database Northwind

USE Northwind -- Otra forma de invocar la base de datos
GO 
--Ejercicio 1
--Top 10 Productos mas comprados
Select TOP 10 P.ProductName,SUM(od.Quantity) as [Units Sold]
from [Order Details] as od
INNER JOIN [Products] as p 
ON od.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY [Units Sold] DESC

--Ejercicio 2
-- Encuentra el producto que tiene el segundo precio mas alto en la compania
-- ProductID = 29 , UnitPrice =  123.79
USE Northwind
GO
SELECT p.ProductID,p.ProductName,p.UnitPrice
FROM [Products] as p
ORDER BY p.UnitPrice DESC

--Ejercicio 3 
-- Crear un RANK de productos vendidos ordenado por cuidad y cantidad en USA
USE Northwind
GO 
Select p.ProductName,c.City, od.Quantity,
DENSE_RANK () OVER (PARTITION BY c.City order by od.Quantity) as RANK -- Funcion que te permite crear un ranking 
FROM [Customers] as c
INNER JOIN [Orders] as o ON (c.CustomerID = o.CustomerID)
INNER JOIN [Order Details] as od ON (o.OrderID = od.OrderID)
INNER JOIN [Products] as p ON (od.ProductID = p.ProductID)
WHERE c.Country = 'USA'
ORDER BY od.Quantity DESC

--Ejercicio 4
-- Encontrar las ordenes que tardaron mas de 2 dias en entregarse despues de ser realizadas por el usuario, donde el valor sea mayor de 10,000
-- Mostar numero de dias, fecha de la orden, customer ID y pais de envio
USE Northwind
GO 
SELECT o.OrderID,o.CustomerID, o.OrderDate, o.ShippedDate, o.ShipCountry,
DATEDIFF(DAY,OrderDate,ShippedDate) as Duration_to_Ship,  --- Para obtener la diferencia entre fecha de pedido y fecha de entrega
SUM(od.Quantity * od.UnitPrice) as [Total Sale Amount]
FROM [Orders] as o 
INNER JOIN [Order Details] as od ON o.OrderID = od.OrderID
WHERE DATEDIFF(DAY,OrderDate,ShippedDate) > 2 --Nos piden ordenes mayores a 2 dias de retraso
GROUP BY o.OrderID,o.CustomerID,o.OrderDate, o.ShippedDate, o.ShipCountry -- Ordenamos las columnas 
HAVING SUM (od.Quantity * od.UnitPrice) > 10000 --Condicional para filtar las compras > a 10 000 

-- Ejericicio 5
-- Encuentra el TOP 10  de clientes mas valiosos
USE Northwind
GO 
SELECT TOP 10 c.CompanyName,c.Country,c.City ,SUM(od.Quantity * od.UnitPrice) as [Total Sale Amount]
FROM [Customers] as c
INNER JOIN [Orders] as o ON c.CustomerID = o.CustomerID
INNER JOIN [Order Details] as od ON o.OrderID = od.OrderID
GROUP BY c.CompanyName, c.Country, c.City
ORDER BY  SUM(od.Quantity * od.UnitPrice) DESC

-- Ejercicio 6 
-- Muestra los productos que generaron un monto total de venta mayor o igual a 30 000 y muestra las unidades 
-- vendidas de cada producto en 2018
USE Northwind
GO
SELECT p.ProductName, SUM(od.Quantity) as [Number of Products],SUM(od.Quantity * od.UnitPrice) as [Total Sale Amount]
FROM [Products] as p
INNER JOIN [Order Details] as od ON p.ProductID = od.ProductID
INNER JOIN [Orders] as o ON od.OrderID = o.OrderID
WHERE YEAR(o.OrderDate) = '2018'
GROUP BY p.ProductName
HAVING SUM(od.Quantity * od.UnitPrice) >= 30000


-- Ejercicio 7
-- Clasifica a los clientes de acuerdo a su total de ventas
-- >= 30000 Nivel A
-- >= 20000 y < 30000 Nivel B
-- < 20000 Nivel C
USE Northwind
GO
SELECT c.CompanyName, SUM(od.Quantity * od.UnitPrice) as [Total Sales Amount],
CASE
WHEN  SUM(od.Quantity * od.UnitPrice) >= 30000 THEN 'A'
WHEN  SUM(od.Quantity * od.UnitPrice) < 30000 AND SUM(od.Quantity * od.UnitPrice) >=20000 THEN 'B'
WHEN SUM(od.Quantity * od.UnitPrice) < 20000 THEN 'C'
END LEVEL -- Esto sirve para terminar los casos, y poner nombre a la colmuna donde se crea la calisifcacion
FROM [Customers] as c
INNER JOIN [Orders] as o ON c.CustomerID = o.CustomerID
INNER JOIN [Order Details] as od ON o.OrderID = od.OrderID
GROUP BY c.CompanyName

-- Ejercicio 8
-- Que clientes generaron ventas por arriba del promedio del total de ventas? Filtrar por ano 
USE Northwind
GO 
SELECT c.CompanyName, c.Country,AVG(od.Quantity * od.UnitPrice) as [Average Sales Amount] , SUM(od.Quantity * od.UnitPrice) as [Total Sales Amount]
FROM [Customers] as c
INNER JOIN [Orders] as o ON c.CustomerID = o.CustomerID
INNER JOIN [Order Details] as od ON o.OrderID = od.OrderID
WHERE YEAR(O.OrderDate) = '2018'
GROUP BY c.CompanyName, c.Country
HAVING SUM(od.Quantity * od.UnitPrice) > AVG(od.Quantity * od.UnitPrice)
ORDER BY [Total Sales Amount] DESC

-- Ejercicio 9
-- Que clientes no han comprado en los ultimos 20 meses?
USE Northwind
GO
SELECT c.CompanyName, MAX(o.OrderDate),
DATEDIFF(MONTH,MAX(o.OrderDate),GETDATE ()) AS [Months Since Last Order]
FROM [Customers] as c 
INNER JOIN [Orders] as o ON c.CustomerID = o.CustomerID
GROUP BY c.CompanyName
HAVING DATEDIFF(MONTH,MAX(o.OrderDate),GETDATE ()) > 20

--Ejercicio 10 
-- Numero de ordenes por cliente 

USE Northwind
GO 
SELECT c.CompanyName, c.Country, COUNT(od.OrderID) AS [Total Amount of Orders]
FROM [Customers] as c
INNER JOIN [Orders] as o  ON c.CustomerID = o.CustomerID
INNER JOIN [Order Details] as od ON o.OrderID = od.OrderID
GROUP BY c.CompanyName, c.Country
ORDER BY [Total Amount of Orders] DESC

-- Ejercicio 11
-- Encuentra la duracion de dias entre las ordenes de cada cliente
USE Northwind
GO 
SELECT c.CompanyName, c.CustomerID,o.OrderDate, o.ShippedDate,
DATEDIFF(DAY,o.OrderDate,o.ShippedDate) as [ORDER DURATION]
FROM [Customers] as c 
INNER JOIN [Orders] as o ON c.CustomerID = o.CustomerID
GROUP BY c.CompanyName , c.CustomerID, o.OrderDate, o.ShippedDate
ORDER BY [ORDER DURATION] DESC

-- Ejercicio 12
-- Muestra los empleados con mas ventas
-- Calcula un bono por sus ventas del 2%
USE Northwind
GO 
SELECT e.EmployeeID, e.FirstName , e.LastName, SUM(od.Quantity * od.UnitPrice) as [Total Amount of Sales],
0.02*(SUM(od.Quantity * od.UnitPrice)) as [Bonus Per Employee]
FROM [Employees] as e
INNER JOIN [Orders] as o ON e.EmployeeID = o.EmployeeID
INNER JOIN [Order Details] as od ON o.OrderID = od.OrderID
GROUP BY e.EmployeeID, e.FirstName , e.LastName
ORDER BY SUM(od.Quantity * od.UnitPrice) DESC

-- Ejercicio 13
-- Cuantos empleados tenemos por pocision y por cuidad

USE Northwind
GO 
SELECT Title, City , COUNT(EmployeeID)
FROM Employees 
GROUP BY Title, City, Region 

-- Ejercicio 14
-- Cuanto tiempo lleva trabajando tus empleados 

USE Northwind
GO 
SELECT d.EmployeeID , d.FirstName , d.LastName, d.HireDate,
DATEDIFF(YEAR,d.HireDate,GETDATE()) as [Time Working in the company]
FROM [Employees] as d
GROUP BY d.EmployeeID , d.FirstName, d.LastName ,d.HireDate
ORDER BY DATEDIFF(YEAR,d.HireDate,GETDATE()) DESC

-- Ejercicio 15 
-- Cuantos empleados son mayores de 70 anos?
USE Northwind
GO 
SELECT e.Title, e.FirstName, e.LastName, e.BirthDate,
DATEDIFF(YEAR,e.BirthDate,GETDATE()) as [Years of life]
FROM [Employees] as e
WHERE DATEDIFF(YEAR,e.BirthDate,GETDATE()) >=70
GROUP BY e.Title, e.FirstName, e.LastName, e.BirthDate


--USANDO TABLEAU 

USE Northwind
GO 

--CREATE VIEW TableauData as 

Select c.CompanyName, c.City, c.Country, CONVERT(DATE, o.OrderDate) as OrderDate,
od.Quantity, od.UnitPrice, p.ProductName, ct.CategoryName
FROM Customers as c 
INNER JOIN Orders as o  ON c.CustomerID = o.CustomerID
INNER JOIN [Order Details] as od ON o.OrderID = od.OrderID
INNER JOIN Products as p ON od.ProductID = p.ProductID
INNER JOIN Categories as ct ON p.CategoryID = ct.CategoryID












