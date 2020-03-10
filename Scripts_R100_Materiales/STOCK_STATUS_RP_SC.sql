

	DECLARE @VP_LOTE VARCHAR(10)
	DECLARE @VP_COLOR VARCHAR(10) = 'FMCKTX7' 
	DECLARE @VP_LOCACION VARCHAR(5) = 'MHI' 

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


--	SELECT * FROM  RP_SC_LOTE_SIN_STOCK
-- SELECT RP_SC.* INTO  RP_SC_LOTE_SIN_STOCK
-- DELETE FROM RP_SC
-- WHERE	LTRIM(RTRIM(COLOUR)) = 'FMCKTX7' 
--AND	LTRIM(RTRIM(LOT)) IN ('103741','22571','30031','30301','30541','30901','31011','31031','31041','31081'
--							,'31091','31101','31111','31151','31161','31181','31211','31231','31241','31251','31261'
--							,'31271','31281','31291','31301','31361','31371','31381','31391','31411','31421','31441'
--							,'31451','31491','31521','31542','31551','31552','31561','31591','31592','31621','31631'
--							,'31641','31651','31661','31671','31672','31691','31701','31731','31761','31771','31791'
--							,'31821','31861','31901','31911','31921','31931','31941','31951','32001','32011','32012'
--							,'32021','32071','32081','32111','32121','32131','32141','32152','32181','32191','32211'
--							,'32221','32231','32241','32242','32251','32261','32292','32332','32401','32412','32431'
--							,'32471','32481','32491','32541','32601','32621','32651','32701','32711','32761','64981'
--							)
--	AND  (CASE WHEN ISNUMERIC(MOVEMENT)  = 1 THEN (	SELECT TOP 1	IMINVTRX_SQL.Loc
--																		-- ===================== 
--																FROM	IMLSTRX_SQL, IMINVTRX_SQL 
--																		-- =====================
--																WHERE	(IMLSTRX_SQL.Source	= IMINVTRX_SQL.Source 
--																AND		IMLSTRX_SQL.Ord_No	= IMINVTRX_SQL.Ord_No)
--																AND		IMLSTRX_SQL.Ctl_No	= IMINVTRX_SQL.Ctl_No 
--																AND		IMLSTRX_SQL.Line_No	= IMINVTRX_SQL.Line_No 
--																AND		IMLSTRX_SQL.Lev_No	= IMINVTRX_SQL.Lev_No 
--																AND		IMLSTRX_SQL.Seq_No	= IMINVTRX_SQL.Seq_No 
--																AND		IMINVTRX_SQL.ord_no	= MOVEMENT
--																-- =====================
--																AND		((IMLSTRX_SQL.lev_no	= '0' AND doc_type	= 'R') 
--																		OR  (IMLSTRX_SQL.lev_no	= '1' AND doc_type	= 'T'))
--																)
--			ELSE	MOVEMENT END ) = 'MHI'