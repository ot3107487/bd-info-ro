CREATE DATABASE OSER
GO
USE OSER
GO

CREATE TABLE HALE (
ID INT PRIMARY KEY IDENTITY(1,1),
LITERA CHAR(1),
SUPRAFATA INT -- M2
)

CREATE TABLE TARABE (
ID INT PRIMARY KEY IDENTITY(1,1),
SUPRAFATA INT, -- M2
NUMAR INT,
ID_HALA INT FOREIGN KEY REFERENCES HALE(ID)
)

CREATE TABLE CATEGORII_PRODUSE (
ID INT PRIMARY KEY IDENTITY(1,1),
NUME VARCHAR(50)
)

CREATE TABLE TARABE_CATEGORII_PRODUSE (
ID_TARABA INT FOREIGN KEY REFERENCES TARABE(ID),
ID_CATEGORIE_PRODUS INT FOREIGN KEY REFERENCES CATEGORII_PRODUSE(ID),
CONSTRAINT PK_TARABE_CATEGORII PRIMARY KEY (ID_TARABA, ID_CATEGORIE_PRODUS)
)

CREATE TABLE PRODUSE (
ID INT PRIMARY KEY IDENTITY(1,1),
DENUMIRE VARCHAR(50),
PRET FLOAT,
ID_CATEGORIE_PRODUS INT FOREIGN KEY REFERENCES CATEGORII_PRODUSE(ID)
)

GO

/*
facem cum scrie in cerinta. produsul nu va avea referinta catre tarabe.

Trebuie sa avem grija cum actualizam preturile.
daca actualizam prima data pentru conditia 1, este posibil ca acelasi produs
sa fie actualizat si pentru conditia 2.
vom actualiza in ordinea: 2,3,1
*/

CREATE OR ALTER PROCEDURE USP_SCHIMBA_PRETURI (@ID_TARABA INT) 
AS
	UPDATE PRODUSE SET PRET = PRET + 50
	WHERE ID IN (SELECT P.ID FROM PRODUSE P
				INNER JOIN CATEGORII_PRODUSE CP ON P.ID_CATEGORIE_PRODUS = CP.ID
				INNER JOIN TARABE_CATEGORII_PRODUSE TAR ON TAR.ID_CATEGORIE_PRODUS = CP.ID 
				WHERE TAR.ID_TARABA = @ID_TARABA
					AND P.PRET > 200)

	UPDATE PRODUSE SET PRET = PRET * 1.1
	WHERE ID IN (SELECT P.ID FROM PRODUSE P
				INNER JOIN CATEGORII_PRODUSE CP ON P.ID_CATEGORIE_PRODUS = CP.ID
				INNER JOIN TARABE_CATEGORII_PRODUSE TAR ON TAR.ID_CATEGORIE_PRODUS = CP.ID 
				WHERE TAR.ID_TARABA = @ID_TARABA
					AND P.PRET BETWEEN 100 AND 200)

	UPDATE PRODUSE SET PRET = PRET + 10
	WHERE ID IN (SELECT P.ID FROM PRODUSE P
				INNER JOIN CATEGORII_PRODUSE CP ON P.ID_CATEGORIE_PRODUS = CP.ID
				INNER JOIN TARABE_CATEGORII_PRODUSE TAR ON TAR.ID_CATEGORIE_PRODUS = CP.ID 
				WHERE TAR.ID_TARABA = @ID_TARABA
					AND P.PRET < 100)

GO

CREATE OR ALTER VIEW VW_DISCOUNTURI AS
SELECT PR.DENUMIRE AS DENUMIRE, PR.PRET * 0.4 AS PRET FROM PRODUSE PR
INNER JOIN CATEGORII_PRODUSE CP ON CP.ID = PR.ID_CATEGORIE_PRODUS
INNER JOIN TARABE_CATEGORII_PRODUSE TACP ON TACP.ID_CATEGORIE_PRODUS = CP.ID
INNER JOIN TARABE TA ON TA.ID = TACP.ID_TARABA
INNER JOIN HALE HA ON HA.ID = TA.ID_HALA
WHERE CP.NUME IN ('HAINE', 'VESELA') AND HA.LITERA IN ('A','F','X')

GO
INSERT INTO HALE (LITERA, SUPRAFATA) VALUES 
('A', 100), ('B',200)

INSERT INTO TARABE (ID_HALA, NUMAR, SUPRAFATA) VALUES 
(1, 1, 5), (2,2,10)

INSERT INTO CATEGORII_PRODUSE (NUME) VALUES
('VESELA'), ('HAINE'), ('GRADINA')

INSERT INTO TARABE_CATEGORII_PRODUSE (ID_CATEGORIE_PRODUS, ID_TARABA) VALUES
(1, 1), (3,1), (2, 2)

INSERT INTO PRODUSE (PRET, DENUMIRE, ID_CATEGORIE_PRODUS) VALUES
(10,'FARFURIE', 1), (2, 'CUTIT', 1),
(500, 'GEACA', 2), (150, 'BLUGI', 2),
(150, 'FURTUN', 3), (700, 'GARD', 3)

GO

EXECUTE USP_SCHIMBA_PRETURI 1

SELECT * FROM PRODUSE

GO

SELECT * FROM VW_DISCOUNTURI