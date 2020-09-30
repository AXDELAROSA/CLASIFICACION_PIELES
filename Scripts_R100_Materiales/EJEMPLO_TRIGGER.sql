USE [DATA_02]
GO

/****** Object:  Trigger [dbo].[TRIGGER_IN_TRANSACCION_COLOR_CONTROLADO]    Script Date: 9/30/2020 10:02:01 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[TRIGGER_IN_TRANSACCION_COLOR_CONTROLADO]
ON [dbo].[IMINVTRX_SQL]
for INSERT
AS
	BEGIN
		SET NOCOUNT ON;
  
		DECLARE @VP_TRANSACCION			VARCHAR(15) = ''
		DECLARE @VP_COLOR				VARCHAR(15) = ''
		DECLARE @VP_N_COLOR_CONTROLADO	INT = 0
		
		SELECT	@VP_TRANSACCION = LTRIM(RTRIM(ord_no)),
				@VP_COLOR =  LTRIM(RTRIM(item_no))
		FROM	inserted
		WHERE doc_type = 'T'
		
		SELECT	@VP_N_COLOR_CONTROLADO = COUNT(ID) 
		FROM COLORES_CONTROLADOS
		WHERE COLOR = @VP_COLOR
		
		IF @VP_N_COLOR_CONTROLADO IS NULL
			SET @VP_N_COLOR_CONTROLADO = 0
		
			IF @VP_TRANSACCION LIKE '0%' AND @VP_N_COLOR_CONTROLADO > 0
				BEGIN
					DECLARE @VP_RECIPIENTS	NVARCHAR(MAX)  = 'franciscoe@pearlleather.com.mx'
					DECLARE @VP_SUBJECT		VARCHAR(255) = 'Error: Movimiento transaccion inicia en 0..'
					DECLARE @VP_BODY		NVARCHAR(MAX) 
		
					SET @VP_BODY =  N'<table  border="1" align="center" cellspacing="0">' + 
										N'<thead>' + 
										  N'<tr BGCOLOR="#ADD8E6">' + 
										    N'<th colspan="2">ERROR: Movimiento Transacción inicia en 0... </th>' + 
										  N'</tr>' + 
										  N'<tr BGCOLOR="#48D1CC">' + 
										    N'<th>Movimiento</th><th>Color</th>' + 
										  N'</tr>' + 
										N'</thead>' + 
										N'<tbody>' + 
										  N'<tr>' + 
										  N'<td>'+ @VP_TRANSACCION +'</td><td>'+ CONVERT(VARCHAR(10),@VP_COLOR) +'</td>' + 
										  N'</tr>' + 
										N'</tbody>' + 
									N'</table>' ;
						SET ROWCOUNT 0
						 				
					EXECUTE	BD_GENERAL.[dbo].[PG_ENVIAR_CORREO]	0, 0,
							@VP_RECIPIENTS, @VP_SUBJECT, @VP_BODY
		
				END

END
GO

ALTER TABLE [dbo].[IMINVTRX_SQL] ENABLE TRIGGER [TRIGGER_IN_TRANSACCION_COLOR_CONTROLADO]
GO

