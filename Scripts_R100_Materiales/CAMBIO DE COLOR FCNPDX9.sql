
-- FOLIO BASE COLOR FNRUDX9 : 3461874

--==============PIELES POR LOTE================================================================================================
SELECT  *  FROM RP_SC WHERE LTRIM(RTRIM(COLOUR)) = 'FNRUDX9'  AND LOT = '68171' AND HIDE IN (SELECT HIDE FROM HIDESLIN_SQL	WHERE FILENO IN (	'210726133957T1000001', '210728113444T1000001', '210728121225T1000001') )

--==============TOTALES POR LOTE================================================================================================
SELECT  COUNT(CONVERT(INT, HIDE)) AS 'TOTAL PIEL', SUM(CONVERT(DECIMAL(13,2),SQF)) AS 'TOTAL SQF'  FROM RP_SC WHERE LOT = '68171' AND HIDE IN (SELECT HIDE FROM HIDESLIN_SQL	WHERE FILENO IN (	'210726133957T1000001', '210728113444T1000001', '210728121225T1000001'))

--==============IMPORTACION DE PIELES================================================================================================
	--SELECT * FROM  HIDESHDR_SQL WHERE PLOT = ('68171')   -- FILENO IN ( '210715130339T1000002' )
	--ORDER BY PLOT DESC	
	
	SELECT * FROM  HIDESHDR_SQL	WHERE FILENO IN (	'210726133957T1000001', '210728113444T1000001', '210728121225T1000001')
	ORDER BY PLOT DESC		
	--==============================================================================================================

	SELECT * FROM HIDESLIN_SQL	WHERE FILENO IN (	'210726133957T1000001', '210728113444T1000001', '210728121225T1000001') 
	ORDER BY HIDE ASC 
	--==============================================================================================================

	SELECT PLOT, SUM(CONVERT(INT, THIDES)) AS 'TOTAL PIEL', SUM(CONVERT(DECIMAL(13,2),TAREA)) AS 'TOTAL SQF' 
	FROM  HIDESHDR_SQL	WHERE FILENO IN (	'210726133957T1000001', '210728113444T1000001', '210728121225T1000001')
	GROUP BY PLOT
	--==============================================================================================================

	
