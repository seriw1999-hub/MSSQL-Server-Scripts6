
--Library database-i qurmaq üçün aşağıdakı SQL skriptindən istifadə edirik:
CREATE  DATABASE LibraryDB;
USE LibraryDB;
--Author table yaradirik:
CREATE TABLE Authors (
	AuthorID INT PRIMARY KEY IDENTITY(1,1),
	Name NVARCHAR(50) NOT NULL,
	Surname NVARCHAR(50) NOT NULL
);
--Book table yaradirik:
CREATE TABLE Books (
    Id INT IDENTITY PRIMARY KEY,
    AuthorId INT NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    PageCount INT NOT NULL,
--Constraints elave edirik:
CONSTRAINT FK_Books_Authors 
FOREIGN KEY (AuthorId) REFERENCES Authors(AuthorID),

CONSTRAINT CK_Books_Name
CHECK (LEN(Name) BETWEEN 2 AND 100),

CONSTRAINT CK_Books_PageCount
CHECK (PageCount >=10)
);

--Author table-a sample datalar elave edirik
INSERT INTO Authors (Name, Surname) VALUES 
('Fyodor', 'Dostoyevski'),
('George', 'Orwell'),
('Franz', 'Kafka');

--Book table-a sample datalar elave edirik
INSERT INTO Books (AuthorId, Name, PageCount) VALUES
(1, 'Crime and Punishment', 671),
(1, 'The Idiot', 656),
(2, '1984', 328),
(2, 'Animal Farm', 112),
(3, 'The Trial', 255);
DROP VIEW IF EXISTS vwBooksWithAuthors;

--Id,Name,PageCount ve AuthorFullName columnlarinin valuelarini qaytaran bir VIEW yaradiriq
CREATE VIEW dbo.vw_BooksWithAuthors AS
SELECT
    b.Id,
    b.Name,
    b.PageCount,
    a.Name + ' ' + a.Surname AS AuthorFullName
FROM Books b
JOIN Authors a ON b.AuthorId = a.AuthorID;

--Gonderilmis axtaris deyirene gore hemin axtaris deyeri Boook.name ve ya Author.
--Name olan Book-lari Id,Name,PageCount,AuthorFullName columnlari seklinde gosteren procedure yaziriq.
CREATE PROCEDURE usp_SearchBooks @Search NVARCHAR(100) AS
BEGIN
    SELECT
        b.Id,
        b.Name,
        b.PageCount,
        a.Name + ' ' + a.Surname AS AuthorFullName
    FROM Books b
    JOIN Authors a ON b.AuthorId = a.Id
    WHERE b.Name LIKE '%' + @Search + '%'
       OR a.Name LIKE '%' + @Search + '%';
END;
--Procedure-i test edin
EXEC usp_SearchBooks 'George';
EXEC usp_SearchBooks 'Crime';

--Bir Function yaradin.MinPageCount parametri qebul etsin.
--Default deyeri 10 olsun;
CREATE FUNCTION fn_BookCountByPage (@MinPageCount INT=10 )
RETURNS INT AS
BEGIN
    DECLARE @Result INT;
    SELECT @Result = COUNT(*)
    FROM Books
    WHERE PageCount > @MinPageCount;
    RETURN @Result;
END;

--Function-i test edin
SELECT dbo.fn_BookCountByPage(300);
SELECT dbo.fn_BookCountByPage();

--DeletedBooks table yaradin
CREATE TABLE DeletedBooks (
    Id INT,
    AuthorId INT,
    Name NVARCHAR(100),
    PageCount INT,
    DeletedDate DATETIME DEFAULT GETDATE()
);

--Id,AuthorId,Name,PageCount trigger yaradirsiz.
--Books table-dan silinen her bir record DeletedBooks table-a insert edilsin.
CREATE TRIGGER trg_Books_Delete ON Books
AFTER DELETE AS
BEGIN
    INSERT INTO DeletedBooks (Id, AuthorId, Name, PageCount)
    SELECT Id, AuthorId, Name, PageCount
    FROM DELETED;
END;
--Trigger-i test edin
DELETE FROM Books WHERE Id= 5;
SELECT * FROM DeletedBooks;
--Silinen kitab DeletedBooks table-a insert olunub

--End of script