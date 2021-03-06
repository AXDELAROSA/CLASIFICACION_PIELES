
-- ////////////////////////////////////////////////////////////// 
USE DATA_02Pruebas

/*
--INSERT INTO RP_SC( 
--		[CDATE],[COLOUR],[LOT],[HIDE],[SQF],[TAGNO],[TYPE],MOVEMENT
--		)
--SELECT GETDATE(), 'FMCKTX7'   ,'33641','0575','40.30', 3797972,'C','T45'
--FROM RP_SC_FOLIO_TYPE_2 WHERE TAGNO = 3788317
*/

/*
--DECLARE @VP_FOLIO_BASE INT = 0
--SELECT TOP 1 @VP_FOLIO_BASE = MAX(TAG) FROM RP_FOLIOS 

--SET @VP_FOLIO_BASE = @VP_FOLIO_BASE + 1

--EXECUTE [dbo].[PG_IN_RP_FOLIOS]		0, 0,
--									@VP_FOLIO_BASE, 'B', NULL, NULL, NULL


--INSERT INTO RP_SC( 
--		[CDATE],[COLOUR],[LOT],[HIDE],[SQF],[TAGNO],[YARDAS],[YLB],[PESO],[TYPE],[MOVEMENT],[K_CLASIFICACION]
--		)
--SELECT GETDATE(),[COLOUR],[LOT],[HIDE],[SQF],@VP_FOLIO_BASE,[YARDAS],[YLB],[PESO],[TYPE],'MHI',[K_CLASIFICACION]
--FROM RP_SC_FOLIO_TYPE_2 WHERE TAGNO = 3788336 AND HIDE = '0137'
*/

-- BASE 3798262

SELECT *  FROM ccjobhdr_sql 
WHERE datecreated < 20210111 
AND status = 'P'
AND machine LIKE 'T%'
AND INSTRUCT1 = ''
AND JOBNO IN (SELECT JOBNO FROM CCJOBLIN_SQL)
AND colourdesc NOT LIKE 'U%'
ORDER BY MACHINE, datecreated ASC
--jobno = '21928'

SELECT * FROM CCJOBLIN_SQL WHERE jobno = '18786'
SELECT * FROM  RP_FOLIOS WHERE jobno = '23677'

SELECT * FROM RP_SC WHERE TAGNO = (3812780)

--UPDATE RP_SC 
--	SET MOVEMENT = 'T35'
--WHERE ID = 5569576 


SELECT * FROM  RP_SC_FOLIO_STATUS_XX WHERE HIDE = '0092' and LOT = '105721'

SELECT  * FROM [PIEL_A_TRANSFERIR]

SELECT * FROM [PIEL_A_TRANSFERIR_TRANSACCION] where folio_origen = 3797941 or FOLIO_DESTINO = 3797941

SELECT * FROM COLORES_CONTROLADOS WHERE COLOR LIKE 'FG%'

SELECT * FROM  RP_FOLIOS WHERE JOBNO = '23061'

SELECT  TOP 100 * FROM cccuthst_sql WHERE --JOBNO = '23061'  
LTRIM(RTRIM(lotno)) = '700151'
AND HIDENO IN ('0223')

SELECT '         ' + '1' + SUBSTRING(Ltrim(Rtrim('         067651')), 2, 6) 

SELECT * FROM RP_SC_FOLIO_TYPE_2 WHERE LTRIM(RTRIM(LOT)) IN ('34311') order by id desc

SELECT * FROM RP_SC WHERE	LTRIM(RTRIM(LOT)) IN ('34311') 
--AND CONVERT(INT, LTRIM(RTRIM(HIDE))) BETWEEN 141 AND 167
--AND COLOUR = 'FGMPAX7'
--and convert(int, hide) between 1 and 49
 ORDER BY COLOUR, HIDE asc

-- delete RP_SC WHERE	LTRIM(RTRIM(LOT)) IN ('900011') 
----AND CONVERT(INT, LTRIM(RTRIM(HIDE))) BETWEEN 141 AND 167
--AND COLOUR = 'FGMPAX7'
--and convert(int, hide) between 1 and 49
-- ORDER BY COLOUR, HIDE asc


SELECT * FROM HIDESHDR_SQL   
 inner join HIDESLIN_SQL on  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
WHERE	--LTRIM(RTRIM(PLOT)) IN ('33351')
--and 
hide = '0078'
and sqf = '58.40'
--and HIDESLIN_SQL.fileno = '20210202170107'
--AND CONVERT(INT, LTRIM(RTRIM(HIDE))) BETWEEN 141 AND 167
--AND PCOLOR = 'FNPJSA5'
 ORDER BY HIDESLIN_SQL.HIDE ASC


SELECT * FROM  HIDESLIN_SQL WHERE FILENO IN ('210225121557T1000001') AND PRINTED = 1 
ORDER BY HIDE

SELECT * FROM HIDESHDR_SQL
WHERE FILENO IN ('20210202170107' )

SELECT * FROM [PIEL_A_TRANSFERIR_TRANSACCION] where folio_origen = 3799533 or FOLIO_DESTINO = 3799533

SELECT * FROM [PIEL_A_TRANSFERIR]

SELECT * FROM RP_SC_FOLIO_STATUS_XX WHERE TAGNO =3799707 AND HIDE = '0099'

SELECT * FROM  RP_FOLIOS WHERE jobno IN  ('25224')


--SELECT '         ' + '0' + SUBSTRING(Ltrim(Rtrim('         106771')), 2, 6)

SELECT  TOP 100 * FROM cccuthst_sql WHERE JOBNO = '24295'  --ORDER BY hideno
AND LTRIM(RTRIM(lotno)) = '750051'
AND HIDENO IN ('0473', '0474', '0475', '0476', '0477', '0739') 

--UPDATE cccuthst_sql 
--SET jobno = '24295'
--WHERE JOBNO = '24294'  --ORDER BY hideno
--AND LTRIM(RTRIM(lotno)) = '750051'
--AND HIDENO IN ('0473', '0474', '0475', '0476', '0477', '0739') 


--SELECT * FROM RP_SC_PRT

--SELECT  * from RP_SC WHERE TAGNO in (
--SELECT tag FROM RP_SC_PRT)
--and type <> 'C' 

SELECT  * from RP_SC WHERE TAGNO IN (3814021)             ORDER BY HIDE


SELECT  * from RP_folios WHERE TAG IN (3811065, 3814021) 

--UPDATE RP_folios 
--SET JOBNO = '24295'
--WHERE TAG IN (3814021) 

SELECT *  FROM ccjobhdr_sql WHERE JOBNO IN ('23280')

 --UPDATE ccjobhdr_sql 
 --SET folio = 3811065
 --WHERE JOBNO IN ('24294')

SELECT top 10000 D_TIPO_PIEL_LOG, usuario, PIEL_LOG.*
FROM PIEL_LOG 
INNER JOIN users_pearl ON PIEL_LOG.K_USUARIO_ALTA = users_pearl.codigo
INNER JOIN TIPO_PIEL_LOG ON PIEL_LOG.K_TIPO_PIEL_LOG = TIPO_PIEL_LOG.K_TIPO_PIEL_LOG
WHERE --FOLIO_ORIGEN = 3813391 OR FOLIO_DESTINO = 3813391 
--AND 
--K_USUARIO_ALTA = 136
--AND 
LOTE IN (750121)              
AND PIEL = 804
--and color = 'fwlcpt3'
--AND PIEL_LOG.K_TIPO_PIEL_LOG > 3
--AND ORDEN_DESTIDO = '22873'
ORDER BY K_PIEL_LOG ASC

SELECT * FROM TIPO_PIEL_LOG

SELECT top 100 * FROM IMLSTRX_SQL	WHERE LTRIM(RTRIM(ord_no)) IN (5031218, 5107455    ) order by trx_dt,trx_tm, ORD_NO desc

SELECT top 10 * FROM IMINVTRX_SQL	WHERE LTRIM(RTRIM(ord_no)) IN (5031218, 5107455 )  order by trx_dt,trx_tm, ORD_NO desc

select top 1000 * 
from IMINVTRX_SQL 
--where  item_no = 'FWLCPX7           '   /*and loc = 't13' */ and trx_dt>='20201023' --and doc_type = 'T' --AND SEQ_NO <> 0
--and doc_ord_no = '19407'
--ord_no in ( '04855875')
--order by trx_dt,trx_tm, ORD_NO desc
order by A4GLIDENTITY DESC


/*
--SELECT * FROM cccuthst_sql WHERE JOBNO = '00000'  

--DECLARE @VP_FECHA	INT = FORMAT(CAST(GETDATE() AS DATE), N'yyyyMMdd');
--DECLARE @VP_HORA	INT = FORMAT(CAST(GETDATE() AS TIME(0)), N'hhmmss');
--DECLARE @VP_LOTE_CON_ESPACIO VARCHAR(50) = CONCAT('         ', RIGHT('000000' + '107521', 6) )
--DECLARE @VP_TURNO	VARCHAR(5) = '0'

--EXECUTE [dbo].[PG_IN_CCCUTHST_SQL]		0, 0,
--										-- ===========================
--										'00000', '0000', '1', @VP_FECHA,
--										-- ===========================
--										@VP_HORA, @VP_FECHA, 0, 'FCNPDX9', 
--										-- ===========================
--										@VP_LOTE_CON_ESPACIO, '0153','009.4000',
--										-- ===========================
--										'00000', '', '00000', '00000',
--										'00000', '00000', '00000', '00000', '00000',
--										-- ===========================
--										0, 0, 0, 0,
--										-- ===========================
--																	1, 0, 'P', '', '', 'FRANCISCOE', 'IT-10'

*/

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
