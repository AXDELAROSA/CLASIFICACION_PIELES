

	DECLARE @VP_LOTE VARCHAR(10)
	DECLARE @VP_COLOR VARCHAR(10) = 'FMCKTX7' 
	DECLARE @VP_LOCACION VARCHAR(5) = 'MHH' 

	DECLARE @VP_STOCK_STATUS AS TABLE(
	LOCACION VARCHAR(5),
	COLOR  VARCHAR(10),
	LOTE VARCHAR(10),
	PIELES INT,
	SQF_RP_SC	DECIMAL(13,2),
	SQF_STOCK	DECIMAL(13,2)
	)

	DECLARE CU_LOTE_STOCK_STATUS CURSOR 
	FOR SELECT DISTINCT LTRIM(RTRIM(LOT)) AS LOTE 
		FROM RP_SC
		WHERE LTRIM(RTRIM(COLOUR)) = @VP_COLOR
		AND  (CASE WHEN ISNUMERIC(MOVEMENT)  = 1 THEN (	SELECT TOP 1	IMINVTRX_SQL.Loc
																		-- ===================== 
																FROM	IMLSTRX_SQL, IMINVTRX_SQL 
																		-- =====================
																WHERE	(IMLSTRX_SQL.Source	= IMINVTRX_SQL.Source 
																AND		IMLSTRX_SQL.Ord_No	= IMINVTRX_SQL.Ord_No)
																AND		IMLSTRX_SQL.Ctl_No	= IMINVTRX_SQL.Ctl_No 
																AND		IMLSTRX_SQL.Line_No	= IMINVTRX_SQL.Line_No 
																AND		IMLSTRX_SQL.Lev_No	= IMINVTRX_SQL.Lev_No 
																AND		IMLSTRX_SQL.Seq_No	= IMINVTRX_SQL.Seq_No 
																AND		IMINVTRX_SQL.ord_no	= MOVEMENT
																-- =====================
																AND		((IMLSTRX_SQL.lev_no	= '0' AND doc_type	= 'R') 
																		OR  (IMLSTRX_SQL.lev_no	= '1' AND doc_type	= 'T'))
																)
			ELSE	MOVEMENT END ) = @VP_LOCACION
		AND CONVERT(INT,LTRIM(RTRIM(LOT)))  NOT IN (	SELECT CONVERT(INT,LTRIM(RTRIM(SER_LOT_NO)))
														FROM	IMLSMST_SQL 
														WHERE	LTRIM(RTRIM(LOC))=@VP_LOCACION 
														AND	LTRIM(RTRIM(ITEM_NO))=@VP_COLOR
														AND	qty_on_hand > 0		)
	
	OPEN CU_LOTE_STOCK_STATUS
	FETCH NEXT FROM CU_LOTE_STOCK_STATUS INTO @VP_LOTE
	
	WHILE @@FETCH_STATUS = 0
		BEGIN
			DECLARE @VP_SQF_LOC AS DECIMAL(13,2)
			SELECT @VP_SQF_LOC =CONVERT(DECIMAL(13,2),LTRIM(RTRIM(qty_on_hand)))
													FROM	IMLSMST_SQL 
													WHERE	LTRIM(RTRIM(LOC))=@VP_LOCACION 
													AND	LTRIM(RTRIM(ITEM_NO))=@VP_COLOR
													AND	CONVERT(INT,LTRIM(RTRIM(SER_LOT_NO)))=@VP_LOTE
			INSERT INTO @VP_STOCK_STATUS
			SELECT @VP_LOCACION, @VP_COLOR, @VP_LOTE, COUNT(HIDE), SUM(CONVERT(DECIMAL(13,2), SQF)),@VP_SQF_LOC
			  FROM RP_SC 
			  WHERE LTRIM(RTRIM(COLOUR)) = @VP_COLOR 
			  AND LTRIM(RTRIM(LOT)) = @VP_LOTE
			  AND (CASE WHEN ISNUMERIC(MOVEMENT)  = 1 THEN (	SELECT TOP 1	IMINVTRX_SQL.Loc
																			-- ===================== 
																	FROM	IMLSTRX_SQL, IMINVTRX_SQL 
																			-- =====================
																	WHERE	(IMLSTRX_SQL.Source	= IMINVTRX_SQL.Source 
																	AND		IMLSTRX_SQL.Ord_No	= IMINVTRX_SQL.Ord_No)
																	AND		IMLSTRX_SQL.Ctl_No	= IMINVTRX_SQL.Ctl_No 
																	AND		IMLSTRX_SQL.Line_No	= IMINVTRX_SQL.Line_No 
																	AND		IMLSTRX_SQL.Lev_No	= IMINVTRX_SQL.Lev_No 
																	AND		IMLSTRX_SQL.Seq_No	= IMINVTRX_SQL.Seq_No 
																	AND		IMINVTRX_SQL.ord_no	= MOVEMENT
																	-- =====================
																	AND		((IMLSTRX_SQL.lev_no	= '0' AND doc_type	= 'R') 
																			OR  (IMLSTRX_SQL.lev_no	= '1' AND doc_type	= 'T'))
																	)
			ELSE	MOVEMENT END ) = @VP_LOCACION

		
			FETCH NEXT FROM CU_LOTE_STOCK_STATUS INTO @VP_LOTE
	
		END

	CLOSE CU_LOTE_STOCK_STATUS
	DEALLOCATE CU_LOTE_STOCK_STATUS

	SELECT * FROM @VP_STOCK_STATUS