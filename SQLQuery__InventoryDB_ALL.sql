-------InventoryDB Script---------

--USE MASTER
--GO
--IF DB_ID ('InventoryDB') is not null DROP DATABASE InventoryDB
--GO
--CREATE DATABASE InventoryDB
--ON(
--name=InventoryDB_Data_1,
--filename='C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\InventoryDB_Data_1.mdf',
--size=25mb,
--maxsize=100mb,
--filegrowth=5%
--)
--LOG ON(
--name=InventoryDB_Log_1,
--filename='C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\InventoryDB _Log_1.ldf',
--size=2mb,
--maxsize=50mb,
--filegrowth=1%
--)

USE InventoryDB
GO

CREATE TABLE Item(
ItemId int  Primary Key not null,
ItemType Varchar (20) not null
)
INSERT INTO Item
(ItemId, ItemType) VALUES
(1,'Camp shirt'),
(2,'Dress shirt'),
(3,'T-shirt'),
(4,'Polo shirt')

GO
CREATE TABLE Color(
ColorId int  Primary Key NONCLUSTERED not null,
ColorName VARCHAR (15)
)

-------INDEX--
CREATE CLUSTERED INDEX ix_Color_ColorName on Color(ColorName)
----JUSTIFY--
--EXEC sp_helpindex Color

INSERT INTO Color(ColorId,ColorName)
VALUES
(100,'Red'),
(101,'Blue')

GO
CREATE TABLE ItemColor(
ItemNo VARCHAR (10) Primary Key NOT Null,
ItemId int not null REFERENCES Item(ItemId),
ColorId int not null REFERENCES Color(ColorId)
)
INSERT INTO ItemColor(ItemNo,ItemId,ColorId)
VALUES
('Item 1',1,100),
('Item 2',1,101),
('Item 3',2,100),
('Item 4',2,101),
('Item 5',3,100),
('Item 6',3,101),
('Item 7',4,100),
('Item 8',4,101)

GO
CREATE TABLE Unit (
UnitId int not null Primary Key,
UnitName Varchar (10)  not null
)
INSERT INTO Unit (UnitId,UnitName)
VALUES (200,'pcs')

GO
CREATE TABLE ItemLot (
LotId VARCHAR (5),
ItemNo VARCHAR (10) REFERENCES ItemColor(ItemNo) NOT Null, 
Quantity int NOT Null,
UnitId int REFERENCES Unit(UnitId)not null,
UnitPrice decimal (18,2),
Vat decimal (18,2) not null
)
INSERT INTO ItemLot(LotId,ItemNo,Quantity,UnitId,UnitPrice,Vat)
VALUES 
('Lot 1','Item 1',6,200,1100,0.15 ),
('Lot 1','Item 2',6,200,1200,0.15 ),
('Lot 1','Item 3',6,200,1300,0.15 ),
('Lot 1','Item 4',6,200,1400,0.15 ),
('Lot 1','Item 5',6,200,1500,0.15 ),
('Lot 1','Item 6',6,200,1600,0.15 ),
('Lot 1','Item 7',6,200,1700,0.15 ),
('Lot 1','Item 8',6,200,1800,0.15 ),

('Lot 2','Item 1', 12, 200, 1150,0.15 ),
('Lot 2','Item 2', 12, 200, 1250,0.15 ),
('Lot 2','Item 3', 12, 200, 1350,0.15 ),
('Lot 2','Item 4', 12, 200, 1450,0.15 ),
('Lot 2','Item 5', 12, 200, 1550,0.15 ),
('Lot 2','Item 6', 12, 200, 1650,0.15 ),
('Lot 2','Item 7', 12, 200, 1750,0.15 ),
('Lot 2','Item 8', 12, 200, 1850,0.15 )



 ------VIEW----

 USE InventoryDB
GO
CREATE VIEW vu_InventoryDBWithEncryptionAndSchemaBinding
With Encryption ,SchemaBinding
AS
SELECT IL.ItemNo, I.ItemType,C.ColorName, IL.ItemNo, IL.Quantity,IL.UnitPrice, IL.Vat
FROM dbo.ItemLot IL 
JOIN dbo.ItemColor IC ON IL.ItemNo=IC.ItemNo
JOIN dbo.Item I ON IC.ItemId=I.ItemId
JOIN dbo.Color C ON IC.ColorId=C.ColorId
GO
---JUSTIFY--
--SELECT * FROM vu_InventoryDBWithEncryptionAndSchemaBinding
--EXEC sp_helpindex vu_InventoryDBWithEncryptionAndSchemaBinding


----------------VIEW--GetItemIndoWithVat-------------
USE InventoryDB
GO
CREATE VIEW vu_GetItemIndoWithVat
with encryption , schemabinding
AS 
SELECT IL.ItemNo,IC.ColorId, C.ColorName,IL.Quantity,IL.UnitPrice,IL.Vat,
(IL.Quantity*IL.UnitPrice*IL.Vat) AS VatAmmount
FROM dbo.ItemLot IL
JOIN dbo.ItemColor IC ON IL.ItemNo=IC.ItemNo
JOIN dbo.Color C ON IC.ColorId=C.ColorId
JOIN dbo.Item I ON IC.ItemId=I.ItemId
WHERE C.ColorName='red'
GO
--------------JUSTIFY-----------
SELECT * FROM vu_GetItemIndoWithVat



-------------PROCEDURE--
USE InventoryDB
GO
CREATE PROC spInventoryDB1
@Statement varchar(6)='',
@ColorId int ,
@ColorName varchar (10),
@ColorCount int OUTPUT
AS 
BEGIN

IF @Statement='Select'
BEGIN
SELECT * FROM Color
END

IF @Statement='Insert'
BEGIN
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO Color (ColorId,ColorName) 
VALUES (@ColorId,@ColorName) 
COMMIT TRANSACTION
END TRY
BEGIN  CATCH
SELECT ERROR_MESSAGE () AS EMassage,
ERROR_NUMBER () AS ENumber
ROLLBACK TRANSACTION
END CATCH
END

IF @Statement='Update'
BEGIN
UPDATE Color SET ColorName=@ColorName WHERE ColorId=@ColorId
END

IF @Statement='Delete'
BEGIN
DELETE FROM Color WHERE ColorId=@ColorId
END

IF @Statement='Count'
BEGIN
SELECT @ColorCount=COUNT (ColorId) FROM Color
END 

   END

   ------JUSTIFY ---
   EXEC spInventoryDB1 'Select','','',''

   EXEC spInventoryDB1 'insert','103','Vlolet',''

   EXEC spInventoryDB1 'Update','103','Balck',''

   EXEC spInventoryDB1 'Delete','103','',''

   DECLARE @Color INT
   EXEC spInventoryDB1 'COUNT','','', @Color OUTPUT
   PRINT @Color


 ------------Procedure_with_Return--------------


 USE InventoryDB
GO
CREATE PROC InsertUpdateDeleteOutputRetunColor
@statement varchar(10)='',
@ColorId int,
@ColorName varchar(10),
@Name varchar(10) OUTPUT
AS
BEGIN
if @statement='Insert'
BEGIN
BEGIN TRAN
BEGIN TRY
INSERT INTO Color (ColorId, ColorName) VALUES (@ColorId, @ColorName)
COMMIT TRAN
END TRY
BEGIN CATCH
SELECT ERROR_MESSAGE() ErrorMessage
ROLLBACK TRAN
END CATCH
END
if @statement='Select'
BEGIN
SELECT * FROM Color
END
if @statement='Update'
BEGIN
UPDATE Color SET ColorName=@ColorName WHERE ColorId=@ColorId
END
if @statement='Delete'
BEGIN
DELETE FROM Color  WHERE ColorId=@ColorId
END

if @statement='Output'
BEGIN
SELECT @Name=ColorName FROM Color WHERE ColorId=@ColorId
END

if @statement='Return'
BEGIN
DECLARE @Count int
SELECT @Count=COUNT(ColorId) FROM Color
RETURN @Count
END
END
---Justify--------
EXEC InsertUpdateDeleteOutputRetunColor 'Select','','',''
EXEC InsertUpdateDeleteOutputRetunColor 'Insert','102','Green',''
EXEC InsertUpdateDeleteOutputRetunColor 'Update','102','Yellow',''
EXEC InsertUpdateDeleteOutputRetunColor 'Delete','102','',''

DECLARE @CName varchar(10)
EXEC InsertUpdateDeleteOutputRetunColor 'Output','101','',@CName OUTPUT
PRINT @CName

DECLARE @ReturnCount int
EXEC @ReturnCount= InsertUpdateDeleteOutputRetunColor 'Return','','',''
PRINT @ReturnCount


 --------Procedure_with_Return--------
USE InventoryDB
GO
CREATE PROC spInsertUpdateDeleteOutputReturnColor
@Statement varchar (10)='',
@ColorId int,
@ColorName varchar (20),
@Name varchar (10) OUTPUT
AS
BEGIN

IF @Statement='Select'
BEGIN
SELECT * FROM Color
END

IF @Statement='Insert'
BEGIN
BEGIN TRAN
BEGIN TRY
COMMIT TRAN
END TRY
BEGIN CATCH
SELECT ERROR_MESSAGE () AS EMSG
ROLLBACK TRAN
END CATCH
END

IF @Statement='Update'
BEGIN
UPDATE Color set ColorName=@ColorName WHERE ColorId=@ColorId
END

IF @Statement='Delete'
BEGIN
DELETE FROM Color WHERE ColorId=@ColorId
END

IF @Statement='Output'
BEGIN
SELECT @Name=ColorName FROM Color WHERE  ColorId=@ColorId
END

IF @Statement='Return'
BEGIN
DECLARE @Count INT 
SELECT @Count=COUNT(ColorId) FROM Color 
RETURN @Count
END

END

----------JUSTIFY-
 GO
   EXEC spInsertUpdateDeleteOutputReturnColor 'Select','','',''

   EXEC spInsertUpdateDeleteOutputReturnColor 'Insert','102','Green',''

   EXEC spInsertUpdateDeleteOutputReturnColor 'Update','102','Yellow',''

   EXEC spInsertUpdateDeleteOutputReturnColor 'Delete','102','',''

   DECLARE @CName varchar (10)
   EXEC spInsertUpdateDeleteOutputReturnColor 'Output','101','',@CName OUTPUT
   PRINT @CName

   DECLARE @ReturnCount varchar (10)
   EXEC @ReturnCount=spInsertUpdateDeleteOutputReturnColor 'Return','','',@ReturnCount OUTPUT
   PRINT @ReturnCount



 --------------TRIGGER--------
GO
CREATE TRIGGER tr_ColorInsert
ON Color
FOR INSERT 
AS
BEGIN
SELECT * FROM inserted
END

GO
CREATE TRIGGER tr_ColorDeleteRaisError
ON Color
FOR DELETE 
AS
BEGIN
RAISERROR('Deletec Protected',1,1)
ROLLBACK TRANSACTION
END

-------------------------------------------

USE InventoryDB
GO
CREATE TABLE ColorArchive (
ColorId int not null,
ColorName Varchar (10)
)
GO
CREATE TABLE Logs(
ActivityId int not null identity primary key,
Activity Varchar (30) not null,
Actitity_date datetime 
)


----Trigger---

USE InventoryDB 
GO
CREATE TRIGGER tr_ColorInsert
ON Color
Instead OF Insert
AS 
BEGIN
INSERT INTO ColorArchive
SELECT * FROM Inserted
INSERT INTO Logs VALUES ('Color Inserted', GETDATE())
END

-----insert into trigger ---

USE InventoryDB 
GO
INSERT INTO Color (ColorId, ColorName)
VALUES (104, 'Black')

-------------------------------------------
USE InventoryDB
GO
CREATE TRIGGER tr_Insert_ItemLot
ON ItemLot
FOR Insert 
AS 
DECLARE @price decimal (18,2)
SELECT @price= UnitPrice FROM Inserted 
IF @price=0
BEGIN
RAISERROR ('Unit price cannot be 0',1,1)
ROLLBACK
END
GO
INSERT INTO ItemLot ( LotId, ItemNo,Quantity,UnitId, UnitPrice, Vat)
VALUES
('Lot 3','Item 1',10, 200,1000, .15),
('Lot 3','Item 2',10, 200,1200, .15),
('Lot 3','Item 3',10, 200,1050, .15)
GO
-----------justify------------
UPDATE  ItemLot SET Quantity=3 WHERE LotId='Lot 3' AND ItemNo='Item 1'----(Can't update)


-----------------------------------
USE InventoryDB
GO
CREATE TRIGGER tr_ItemLot_Update
ON ItemLot
for Update 
AS
DECLARE @oldqty int, @newqty int
SELECT @oldqty=Quantity from deleted
SELECT @newqty=Quantity FROM inserted
IF @newqty<=@oldqty/2
BEGIN
RAISERROR ('You cannot reduce 50 percent or more',11,1)
rollback
END
GO
-----JUSTIFY---
---UPDATE  ItemLot SET Quantity=3 WHERE LotId='Lot 3' AND ItemNo='Item 3'

----------------------------------FUNCTION----------------------------------------------------


USE InventoryDB
GO
CREATE FUNCTION fn_GetColorCount (@ColorId int)
RETURNS int  
BEGIN
RETURN (SELECT COUNT(ColorId) FROM Color )
END

GO
PRINT dbo.fn_GetColorCount()


-----table-
USE InventoryDB
GO
CREATE FUNCTION fn_Table_ValuedColor (@ColorId int)
RETURNS Table
RETURN 
SELECT ColorId,ColorName FROM Color WHERE ColorId=@ColorId
GO
SELECT * FROM dbo.fn_Table_ValuedColor(101)

-------MultiTable------
GO
CREATE FUNCTION fn_MultipleTableValued (@number int )
RETURNS @outTable TABLE (ColorId int  , ColorName varchar(20))
BEGIN
INSERT INTO @outTable 
SELECT ColorId, ColorName FROM Color
WHERE ColorId>=100
UPDATE @outTable SET ColorId=ColorId+@number
RETURN
END
GO
SELECT * FROM dbo.fn_MultipleTableValued (100)




----------Multi-Statement-Table-Valued-Function----------
GO
CREATE FUNCTION fn_MultiStatementTableValuedFunction ( @qty int , @money decimal)
RETURNS @outputTable table
(LotId varchar(5), ItemNo varchar(10), Quantity int ,UnitPrice decimal , TotalAmount decimal )
BEGIN
INSERT INTO @outputTable 
SELECT LotId, ItemNo, Quantity, UnitPrice , Quantity* UnitPrice FROM ItemLot
WHERE UnitPrice>1500
UPDATE @outputTable SET  Quantity=Quantity+@qty,UnitPrice=UnitPrice+@money
RETURN;
END

GO
SELECT * FROM fn_MultiStatementTableValuedFunction(10,500)

------------------

GO
CREATE FUNCTION fn_MultiTableValuedFunction1 (@qty int, @money decimal)
RETURNS @outputTable table
            (LotId varchar(5), ItemNo varchar(10),Quantity int, UnitPrice decimal,TotalAmount decimal)
BEGIN
INSERT INTO @outputTable
SELECT LotId,ItemNo,Quantity,UnitPrice, Quantity*UnitPrice FROM ItemLot
WHERE Quantity>10
UPDATE @outputTable SET Quantity=Quantity-@qty, UnitPrice=UnitPrice+@money
RETURN;
END

GO
SELECT * FROM fn_MultiTableValuedFunction1(5,1000)


