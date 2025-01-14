CREATE DATABASE ALEGERI
GO
USE ALEGERI
GO
CREATE TABLE SECTII (
ID INT PRIMARY KEY IDENTITY (1,1),
NUMAR INT
)

CREATE TABLE CETATENI (
ID INT PRIMARY KEY IDENTITY (1,1),
NUME VARCHAR(100),
PRENUME VARCHAR(100),
DATA_NASTERII DATE,
ID_SECTIE_VOTARE INT FOREIGN KEY REFERENCES SECTII(ID)
)

CREATE TABLE CANDIDATI (
ID INT PRIMARY KEY IDENTITY (1,1),
NUME VARCHAR(100),
PRENUME VARCHAR(100),
DATA_NASTERII DATE
)

CREATE TABLE VOTURI(
ID INT PRIMARY KEY IDENTITY (1,1),
ORA TIME,
PE_LISTE_SUPLIMENTARE BIT,
ID_CETATEAN INT FOREIGN KEY REFERENCES CETATENI(ID),
ID_SECTIE_VOTARE INT FOREIGN KEY REFERENCES SECTII(ID),
ID_CANDIDAT INT FOREIGN KEY REFERENCES CANDIDATI(ID)
)

CREATE TABLE ECHIPAJE (
ID INT PRIMARY KEY IDENTITY (1,1),
NUMAR INT,
NUMAR_MEMBRII INT
)

CREATE TABLE ECHIPAJE_SECTII (
ID INT PRIMARY KEY IDENTITY(1,1),
ID_SECTIE_VOTARE INT FOREIGN KEY REFERENCES SECTII(ID),
ID_ECHIPAJ INT FOREIGN KEY REFERENCES ECHIPAJE(ID)
)

GO

CREATE OR ALTER PROCEDURE USP_CASTIGATOR (@ID_SECTIE_VOTARE INT, @ID_CANDIDAT INT OUTPUT)
AS
	DECLARE @ID_CASTIGATOR INT
	
	-- NUMARAM VOTURILE FIECARUI CANDIDAT IN ACEA SECTIE. SORTAM DESCRESCATOR DUPA NR VOTURI OBITNUTE
	-- LUAM PRIMA LINIE -> CASTIGATORUL
	SELECT TOP 1 @ID_CASTIGATOR = V.CANDIDAT FROM (
	SELECT ID_CANDIDAT AS [CANDIDAT], COUNT(*) AS [NR_VOTURI] FROM VOTURI 
	WHERE ID_SECTIE_VOTARE = @ID_SECTIE_VOTARE
	GROUP BY ID_CANDIDAT) V
	ORDER BY NR_VOTURI DESC

	SET @ID_CANDIDAT = @ID_CASTIGATOR

	-- NUMARAM CATE VOTURI A OBTINUT CASTIGATORUL IN ACEA SECTIE
	DECLARE @VOTURI_OBTINUTE_CASTIGATOR INT

	SELECT @VOTURI_OBTINUTE_CASTIGATOR = COUNT(*) FROM VOTURI 
	WHERE ID_SECTIE_VOTARE = @ID_SECTIE_VOTARE
		AND ID_CANDIDAT = @ID_CASTIGATOR

	-- NUMARAM CATE VOTURI S-AU EXPRIMAT IN ACEA SECTIE
	DECLARE @VOTURI_EXPRIMATE_SECTIE INT

	SELECT @VOTURI_EXPRIMATE_SECTIE = COUNT(*) FROM VOTURI 
	WHERE ID_SECTIE_VOTARE = @ID_SECTIE_VOTARE

	RETURN FLOOR(@VOTURI_OBTINUTE_CASTIGATOR * 100 / @VOTURI_EXPRIMATE_SECTIE)

GO

CREATE OR ALTER VIEW VW_VOTURI_GEORGESCU AS 
SELECT CONVERT(VARCHAR(10),S.NUMAR) + ': ' + CONVERT(VARCHAR(10), COUNT(*)) AS [DATE] FROM VOTURI V
INNER JOIN CANDIDATI C ON V.ID_CANDIDAT = C.ID
INNER JOIN SECTII S ON V.ID_SECTIE_VOTARE = S.ID
WHERE C.PRENUME LIKE 'Calin' AND C.NUME = 'Georgescu'
GROUP BY V.ID_SECTIE_VOTARE, S.NUMAR
HAVING COUNT(*) > 500

GO
INSERT INTO SECTII (NUMAR) VALUES 
(1), (2), (3)

INSERT INTO CETATENI (ID_SECTIE_VOTARE) VALUES
(1), (1), (1),
(2), (2), (2),
(3), (3), (3)

INSERT INTO CANDIDATI (NUME, PRENUME) VALUES
('Lasconi', 'Elena'),
('Georgescu', 'Calin')

INSERT INTO VOTURI (ID_CETATEAN, ID_SECTIE_VOTARE, ID_CANDIDAT) VALUES
(1, 1, 1),
(2, 1, 2),
(3, 1, 2),
(4, 2, 1),
(5, 2, 1),
(6, 2, 1),
(7, 3, 1),
(8, 3, 1),
(9, 3, 2)

GO
DECLARE	@return_value int,
		@ID_CANDIDAT int

EXEC	@return_value = [dbo].[USP_CASTIGATOR]
		@ID_SECTIE_VOTARE = 3,
		@ID_CANDIDAT = @ID_CANDIDAT OUTPUT

SELECT	@ID_CANDIDAT as N'CASTIGATOR'

SELECT	@return_value

GO
SELECT * FROM VW_VOTURI_GEORGESCU
