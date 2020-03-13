
USE DATA_02Pruebas
--//////////////////INDICES CREADOS///////////////////////////////////////////////
--DROP INDEX UN_RP_SC_01_ID ON [RP_SC] 
--GO

-- CREATE NONCLUSTERED INDEX [UN_RP_SC_01_ID]
--ON [dbo].[RP_SC] ([CDATE],[MOVEMENT])
--INCLUDE ([COLOUR],[LOT],[HIDE],[SQF],[TAGNO],[TYPE],[K_CLASIFICACION])
--GO

--DROP INDEX [UN_RP_SC_01_COLOR] ON [RP_SC] 
--GO
-- CREATE NONCLUSTERED INDEX [UN_RP_SC_01_COLOR]
--ON [dbo].[RP_SC] ([COLOUR])
--INCLUDE ([LOT],[HIDE],[SQF],[TAGNO],[TYPE],[K_CLASIFICACION])
--GO
 
-- DROP INDEX [UN_RP_FOLIOS_01_TAG] ON [RP_FOLIOS] 
--GO
-- CREATE NONCLUSTERED INDEX [UN_RP_FOLIOS_TAG]
--ON [dbo].[RP_FOLIOS] ([TAG])
--INCLUDE (ID,STATUS,JOBNO, MACHINE)
--GO

--SELECT  * FROM IMLSTRX_SQL
--SELECT  * FROM IMINVTRX_SQL 

-- DROP INDEX [UN_IMLSTRX_SQL] ON [IMLSTRX_SQL] 
--GO
-- CREATE NONCLUSTERED INDEX [UN_IMLSTRX_SQL]
--ON [dbo].[IMLSTRX_SQL] (item_no)
--INCLUDE (ord_no, ser_lot_no, line_no, lev_no,seq_no,ctl_no)
--GO

-- DROP INDEX [UN_IMINVTRX_SQL] ON [IMINVTRX_SQL] 
--GO
-- CREATE NONCLUSTERED INDEX [UN_IMINVTRX_SQL]
--ON [dbo].[IMINVTRX_SQL] (item_no)
--INCLUDE (ord_no,loc,line_no, lev_no,seq_no,ctl_no, doc_ord_no)
--GO
 --/////////////////////////////////////////////////////////////////

