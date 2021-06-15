
USE [DATA_02Pruebas] 
GO
	--UPDATE RP_SC 
	--SET TYPE = 'D'
	--WHERE TAGNO IN ( 3798327) 
	--AND ID IN (5122787, 5128937, 5128940 )
	
	SELECT * FROM RP_SC WHERE TAGNO IN ( 3798327) 

	SELECT * FROM RP_Folios WHERE TAG = 3798327

	SELECT * FROM ccjobhdr_sql WHERE FOLIO = 3798327

	SELECT * FROM CCCUTHST_SQL WHERE jobno = '18014' AND hideno IN ( '0245', '0240' )

	--UPDATE CCCUTHST_SQL 
	--SET hidesqm = 15
	--WHERE jobno = '18014' AND hideno IN ( '0245', '0240' )

	SELECT RIGHT('000000' + '33561', 6)

--=====================================================================================

