
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


 
SELECT * FROM HIDESHDR_SQL   
 inner join HIDESLIN_SQL on  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
WHERE	LTRIM(RTRIM(PLOT)) IN ('900061')
--and 
--hide = '0078'
and sqf = '50.90'
--and HIDESLIN_SQL.fileno = '210310181706T1000002'
--AND CONVERT(INT, LTRIM(RTRIM(HIDE))) BETWEEN 141 AND 167
--AND PCOLOR = 'FNPJSA5'
 ORDER BY HIDESLIN_SQL.HIDE ASC

 SELECT * FROM HIDESHDR_SQL WHERE PLOT = '900061'

SELECT * 
FROM  HIDESLIN_SQL WHERE FILENO IN ('210122060130T1000001') --AND PRINTED = 1 
--AND HIDE > 290
ORDER BY HIDE

--UPDATE   HIDESLIN_SQL
--	SET FILENO = ('210310173125T1000001') 
-- WHERE FILENO IN ('210310173125T1000000') --AND PRINTED = 1 
--AND HIDE > 290

--UPDATE  HIDESLIN_SQL 
--SET PRINTED = 1
--WHERE FILENO IN ('210310173125T1000001')

SELECT * --RIGHT('0000' + CONVERT(VARCHAR(4), CONVERT(INT, HIDE) + 215 ), 4) , SQF
FROM RP_SC 
WHERE	LTRIM(RTRIM(LOT)) = ('900061') 
AND HIDE IN ('0597', '0596', '0595', '0594', '0593')
--and convert(int, LTRIM(RTRIM(hide))) between 230 and 644
ORDER  BY RP_SC.HIDE

SELECT * FROM RP_FOLIOS WHERE TAG = 3813789

SELECT * FROM [PIEL_A_TRANSFERIR_TRANSACCION] where folio_origen = 3799533 or FOLIO_DESTINO = 3799533

SELECT * FROM [PIEL_A_TRANSFERIR]

SELECT * FROM RP_SC_FOLIO_STATUS_XX WHERE TAGNO =3799707 AND HIDE = '0099'

SELECT * FROM  CCJOBHDR_SQL WHERE jobno > ('25000') 
order by jobno desc

--SELECT '         ' + '0' + SUBSTRING(Ltrim(Rtrim('         106771')), 2, 6)

SELECT * FROM cccuthst_sql WHERE jobno = '26343' AND hideno IN ('0599','0600','0601')

--UPDATE cccuthst_sql 
--SET cdate = 20210317,
--	cshiftdate = 20210317,
--	cshift = 0
--WHERE jobno = '26343' AND cshift = 2 --AND hideno IN ('0599','0600','0601')

SELECT top 10000 D_TIPO_PIEL_LOG, usuario, PIEL_LOG.*
FROM PIEL_LOG 
INNER JOIN users_pearl ON PIEL_LOG.K_USUARIO_ALTA = users_pearl.codigo
INNER JOIN TIPO_PIEL_LOG ON PIEL_LOG.K_TIPO_PIEL_LOG = TIPO_PIEL_LOG.K_TIPO_PIEL_LOG
WHERE-- (FOLIO_ORIGEN = 3815800 OR  FOLIO_DESTINO = 3815800 )
--(ORDEN_ORIGEN = 26245 OR  ORDEN_DESTIDO = 26245 )
--AND 
--K_USUARIO_ALTA = 136
--AND 
LOTE IN (402041    )              
--AND 
--PIEL   IN (select hide from RP_SC_temp where TAGNO = 3816145)
--and color = 'FMCKTX7'
AND PIEL_LOG.K_TIPO_PIEL_LOG IN (1)
--AND ORDEN_DESTIDO = '22873'
ORDER BY k_piel_log desc



SELECT  * from RP_SC 
WHERE TAGNO IN (3815849)   and lot = '34441' and hide = '0581'

SELECT  * from RP_SC_temp 
WHERE TAGNO IN (3816145)         
ORDER BY  HIDE DESC


SELECT  * from RP_folios WHERE jobno = '25953'

SELECT *  FROM ccjobhdr_sql WHERE JOBNO IN ('25953')

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



--	SELECT * FROM cccuthst_sql WHERE JOBNO = '00000'  

--DECLARE @VP_FECHA	INT = FORMAT(CAST(GETDATE() AS DATE), N'yyyyMMdd');
--DECLARE @VP_HORA	INT = FORMAT(CAST(GETDATE() AS TIME(0)), N'hhmmss');
--DECLARE @VP_LOTE_CON_ESPACIO VARCHAR(50) = CONCAT('         ', RIGHT('000000' + '401631', 6) )
--DECLARE @VP_TURNO	VARCHAR(5) = '0'

--EXECUTE [dbo].[PG_IN_CCCUTHST_SQL]		0, 0,
--										-- ===========================
--										'00000', '0000', '1', @VP_FECHA,
--										-- ===========================
--										@VP_HORA, @VP_FECHA, 0, 'FWLCPT3', 
--										-- ===========================
--										@VP_LOTE_CON_ESPACIO, '0181','007.1000',
--										-- ===========================
--										'00000', '', '00000', '00000',
--										'00000', '00000', '00000', '00000', '00000',
--										-- ===========================
--										0, 0, 0, 0,
--										-- ===========================
--																	1, 0, 'P', '', '', 'FRANCISCOE', 'IT-10'



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
