create database samsara
go
use samsara
go

CREATE TABLE CLIENTI (
ID INT PRIMARY KEY IDENTITY (1,1),
NUME VARCHAR(50),
TELEFON VARCHAR(20)
)

CREATE TABLE COMENZI (
ID INT PRIMARY KEY IDENTITY (1,1),
ADRESA_LIVRARE VARCHAR(100),
DATA_COMANDA DATE,
ID_CLIENT INT FOREIGN KEY REFERENCES CLIENTI(ID)
)



CREATE TABLE PREPARATE (
ID INT PRIMARY KEY IDENTITY (1,1),
DENUMIRE VARCHAR(100),
CANTITATE INT,
PRET INT
)

CREATE TABLE INGREDIENTE (
ID INT PRIMARY KEY IDENTITY (1,1),
DENUMIRE VARCHAR(100),
CALORII INT
)

CREATE TABLE COMENZI_PREPARATE (
ID INT PRIMARY KEY IDENTITY (1,1),
ID_COMANDA INT FOREIGN KEY REFERENCES COMENZI(ID),
ID_PREPARAT INT FOREIGN KEY REFERENCES PREPARATE(ID)
)

CREATE TABLE PREPARATE_INGREDIENTE (
ID_PREPARAT INT FOREIGN KEY REFERENCES PREPARATE(ID),
ID_INGREDIENT INT FOREIGN KEY REFERENCES INGREDIENTE (ID),
CONSTRAINT PK_PREPARATE_INGREDIENTE PRIMARY KEY (ID_PREPARAT, ID_INGREDIENT)
)
GO

CREATE OR ALTER PROCEDURE USP_DELETE_INGREDIENT (@DENUMIRE VARCHAR(100))
AS
	DECLARE @ID_INGREDIENT INT
	SELECT @ID_INGREDIENT = ID FROM INGREDIENTE WHERE DENUMIRE = @DENUMIRE

	DECLARE @NR_COMENZI_STERSE INT
	-- CATE COMENZI CONTIN INGREDIENTUL INTERZIS?
	SELECT @NR_COMENZI_STERSE = COUNT(DISTINCT CP.ID_COMANDA) FROM COMENZI_PREPARATE CP
	INNER JOIN PREPARATE PR ON CP.ID_PREPARAT = PR.ID
	INNER JOIN PREPARATE_INGREDIENTE PRI ON PRI.ID_PREPARAT = PR.ID
	WHERE PRI.ID_INGREDIENT = @ID_INGREDIENT
	-- STERGEM ACELE COMENZI DIN COMENZI-PREPARATE CA SA EVITAM FOREIGN KEY VIOLATION FOLOSIND
	-- ACELASI SELECT CA MAI SUS
	DELETE FROM COMENZI_PREPARATE WHERE ID_COMANDA IN (SELECT CP.ID_COMANDA FROM COMENZI_PREPARATE CP
	INNER JOIN PREPARATE PR ON CP.ID_PREPARAT = PR.ID
	INNER JOIN PREPARATE_INGREDIENTE PRI ON PRI.ID_PREPARAT = PR.ID
	WHERE PRI.ID_INGREDIENT = @ID_INGREDIENT)

	-- NU MAI PUTEM FOLOSI SELECTUL DE MAI SUS PENTRU A STERGE COMENZI DIN CAUZA CA
	-- IN COMENZI PREPARATE NU MAI AVEM COMENZIILE CARE NE INTERESEAZA

	-- DACA O COMANDA NU MAI EXISTA IN COMENZI_PREPARATE TREBUIE STEARSA. NU ARE SENS SA EXISTA O
	-- COMANDA FARA PREPARATE
	DELETE FROM COMENZI WHERE ID NOT IN (SELECT ID_COMANDA FROM COMENZI_PREPARATE CP)

	RETURN @NR_COMENZI_STERSE
GO

CREATE OR ALTER VIEW VW_COMENZI_CU_SUMA AS
SELECT CO.DATA_COMANDA AS [DATA COMANDA], SUM(PR.PRET) AS [SUMA ACHITATA] FROM CLIENTI CL
INNER JOIN COMENZI CO ON CL.ID = CO.ID_CLIENT
INNER JOIN COMENZI_PREPARATE CP ON CP.ID_COMANDA = CO.ID
INNER JOIN PREPARATE PR ON PR.ID = CP.ID_PREPARAT
WHERE CL.NUME LIKE 'Bogdan Ioan'
GROUP BY CO.ID, CO.DATA_COMANDA

go

INSERT INTO CLIENTI(NUME, TELEFON) VALUES ('Bogdan Ioan', '0777888999'), 
('Luis Fonsi', '00409975874')

INSERT INTO COMENZI(ADRESA_LIVRARE, DATA_COMANDA, ID_CLIENT) VALUES 
('Kogalniceanu 1', '2024-12-24', 1),
('Mihali 3', '2025-01-01', 1),
('Dorobantilor 7', '2024-01-02', 2)

INSERT INTO INGREDIENTE (DENUMIRE, CALORII) VALUES
('Avocado', 200),
('Cartofi', 100)

INSERT INTO PREPARATE (DENUMIRE, CANTITATE, PRET) VALUES
('Piure', 200, 14),
('Avocado', 50, 23),
('Cartofi prajiti', 200, 12)

INSERT INTO PREPARATE_INGREDIENTE (ID_PREPARAT, ID_INGREDIENT) VALUES
(1, 2), (2,1), (3,2)

INSERT INTO COMENZI_PREPARATE (ID_COMANDA, ID_PREPARAT) VALUES 
(1, 1), (1,2), 
(2,1), (2,1), (2,3),
(3,2), (3,2)

GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[USP_DELETE_INGREDIENT]
		@DENUMIRE = N'Avocado'

SELECT	'Comenzi sterse' = @return_value

GO
SELECT * FROM VW_COMENZI_CU_SUMA