-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			RP_SC / Folio Transaccion
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	20/ENE/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO

-- ////////////////////////////////////////////////////////////// 
-- ////////////////////////////////////////////////////////////// 



IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CONFIGURAR_CORREO_MFP_ENTRADA_PIEL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CONFIGURAR_CORREO_MFP_ENTRADA_PIEL]
GO


CREATE PROCEDURE [dbo].[PG_CONFIGURAR_CORREO_MFP_ENTRADA_PIEL]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_COLOR					VARCHAR(10),
	@PP_FOLIO					INT,
	@VP_TOTAL_SQF				DECIMAL(8,4),
	@PP_COMENTARIO				VARCHAR(255),
	@PP_USER					VARCHAR(50)
AS

	-- ///////////////////////////////////////////
	
	DECLARE @VP_RECIPIENTS	NVARCHAR(MAX)  = ''
	SELECT  @VP_RECIPIENTS	=	@VP_RECIPIENTS + ';' + CORREO_USUARIO_PEARL
								FROM	BD_GENERAL.dbo.USUARIO_PEARL AS USERS
								INNER	JOIN	BD_GENERAL.dbo.GRUPO_APROBADOR GP_APROB ON GP_APROB.K_USUARIO=USERS.K_USUARIO_PEARL
								WHERE   GP_APROB.S_GRUPO_APROBADOR = 'NOT_EN_MFP'
								AND		GP_APROB.K_TIPO_GRUPO_APROBADOR = 41 -- MFP
								AND		K_ESTATUS_GRUPO_APROBADOR = 1

	SET @VP_RECIPIENTS = SUBSTRING(@VP_RECIPIENTS,2,LEN(@VP_RECIPIENTS))

	--SELECT @VP_RECIPIENTS

	DECLARE @VP_SUBJECT		VARCHAR(255) = 'Transferencia hacia MFP...'
	DECLARE @VP_FECHA		VARCHAR(10) = CONVERT(VARCHAR(10), GETDATE(),103)
	DECLARE @VP_BODY		NVARCHAR(MAX) 
	
	SET @VP_BODY =  N'<table  border="1" align="center" cellspacing="0">' + 
						N'<thead>' + 
						  N'<tr BGCOLOR="#ADD8E6">' + 
						    N'<th colspan="6">Se ha creado una nueva transferencia (Entrada a MFP)... </th>' + 
						  N'</tr>' + 
						  N'<tr BGCOLOR="#48D1CC">' + 
						    N'<th>Fecha</th><th>Color</th><th>Folio</th><th>Cantidad SQF</th><th>Comentario</th><th>Usuario</th>' + 
						  N'</tr>' + 
						N'</thead>' + 
						N'<tbody>' + 
						  N'<tr>' + 
						  N'<td>'+ @VP_FECHA +'</td><td>'+ @PP_COLOR +'</td><td>'+ CONVERT(VARCHAR(10),@PP_FOLIO) +'</td><td>'+ CONVERT(VARCHAR(10),@VP_TOTAL_SQF) +'</td><td>'+ @PP_COMENTARIO+'</td><td>'+ @PP_USER +'</td>' + 
						  N'</tr>' + 
						N'</tbody>' + 
					N'</table>' ;
		SET ROWCOUNT 0
		 				
	EXECUTE	BD_GENERAL.[dbo].[PG_ENVIAR_CORREO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
												@VP_RECIPIENTS, @VP_SUBJECT, @VP_BODY

	-- ////////////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
