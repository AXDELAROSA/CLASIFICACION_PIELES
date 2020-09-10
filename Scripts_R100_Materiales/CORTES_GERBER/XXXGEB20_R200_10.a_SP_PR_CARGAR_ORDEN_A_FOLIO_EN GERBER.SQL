-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			PROYECTO/GERBER
-- // OPERACION:		LIBERACION / TABLAS
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	27/AGO/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO


	DECLARE @VP_FOLIO INT = 0
	DECLARE CU_FOLIO_GERBER_SIN_ORDEN CURSOR 
		FOR SELECT DISTINCT TAGNO FROM RP_SC WHERE TAGNO IN (3793283,3793284,3793285,3793286,3793297,3793327
									,3793378,3793418,3793467,3793545,3793570,3793650,3793669) ORDER BY TAGNO ASC
		
		OPEN CU_FOLIO_GERBER_SIN_ORDEN
		FETCH NEXT FROM CU_FOLIO_GERBER_SIN_ORDEN INTO @VP_FOLIO

-- ////////////////////SE RECORRE EL CURSOR//////////////////////////	
	WHILE @@FETCH_STATUS = 0
		BEGIN
			-- //////////SE OBTINE EL NUMERO DE ORDEN/////////////////////////////////
			DECLARE @VP_ORDEN	VARCHAR(10) = 0
			SELECT	TOP 1 @VP_ORDEN = CONVERT(INT, LTRIM(RTRIM(JOBNO)))
			FROM	CCJOBHDR_SQL 
			WHERE	JOBNO < '26379'
			ORDER BY JOBNO DESC

			SET @VP_ORDEN = @VP_ORDEN + 1
			-- =====================

			SET @VP_ORDEN =RIGHT('00000' + @VP_ORDEN, 5)

			-- //////////SE OBTINE LA DESCRIPCION DEL COLOR/////////////////////////////////
			DECLARE @PP_COLOR VARCHAR(50)= ''
			SELECT TOP 1 @PP_COLOR = LTRIM(RTRIM(COLOUR)) FROM RP_SC WHERE TAGNO = @VP_FOLIO

			DECLARE @VP_COLOR_DESCRIPCION VARCHAR(100) = ''
			SELECT @VP_COLOR_DESCRIPCION = LTRIM(RTRIM(item_desc_1))
			FROM IMITMIDX_SQL 
			WHERE LTRIM(RTRIM(item_no)) = @PP_COLOR

			-- //////////SE OBTINE EL CLIENTE EN BASE AL COLOR/////////////////////////////////
			--SELECT TOP 100 * FROM ARCUSFIL_SQL
			DECLARE @PP_CLIENTE VARCHAR(50) = ''

			IF SUBSTRING(@PP_COLOR, 1, 3) IN ('FWL', 'FCP')
				SET @PP_CLIENTE = 'MAGN02'
		
			IF SUBSTRING(@PP_COLOR, 1, 3) = 'FYP'
				SET @PP_CLIENTE = 'YANG02'

			IF SUBSTRING(@PP_COLOR, 1, 3) = 'FWS'
				SET @PP_CLIENTE = 'FAUR01'

			-- //////////SE INGRESA EL DATO DE LA ORDEN CCJOBHDR_SQL/////////////////////////////////
			DECLARE @VP_F_CREACION_INT	INT = DATA_02.DBO.[CONVERT_DATE_TO_INT](CONVERT(DATE, GETDATE()),'yyyyMMdd')
			SET @PP_COLOR =  SUBSTRING(@PP_COLOR, 2, 15)

			-- //////////SE OBTINE LA LOCACION DEL FOLIO/////////////////////////////////
			DECLARE @PP_LOCACION VARCHAR(25)= ''
			SELECT @PP_LOCACION = LTRIM(RTRIM(LOC_DESC))
							FROM IMLOCFIL_SQL
							WHERE LTRIM(RTRIM(LOC)) = (SELECT TOP 1 LTRIM(RTRIM(MOVEMENT)) FROM RP_SC WHERE TAGNO = @VP_FOLIO )

			INSERT INTO CCJOBHDR_SQL (
										JOBNO,
										STATUS,
										COLOUR,
										COLOURDESC,
										MACHINE,
										DATECREATED,
										DATEPLANNED,
										CUSTOMER,
										folio,
										COMMENTS)
								VALUES(
										@VP_ORDEN,
										'P',
										@PP_COLOR,
										@VP_COLOR_DESCRIPCION,
										@PP_LOCACION,
										@VP_F_CREACION_INT,
										@VP_F_CREACION_INT,
										@PP_CLIENTE,
										@VP_FOLIO,
										'FEG: ORDEN GENERADA PARA FOLIO EN GERBER SIN ORDER'
										)

			UPDATE RP_Folios 
				SET MACHINE = @PP_LOCACION,
					JOBNO = @VP_ORDEN
			WHERE TAG = @VP_FOLIO 

			FETCH NEXT FROM CU_FOLIO_GERBER_SIN_ORDEN INTO @VP_FOLIO
		END
			
	-- ////////////////////SE CIERRA EL CURSOR//////////////////////////
	CLOSE CU_FOLIO_GERBER_SIN_ORDEN
	DEALLOCATE CU_FOLIO_GERBER_SIN_ORDEN



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
