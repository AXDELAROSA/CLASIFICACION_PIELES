
DECLARE @VP_RECIPIENTS	NVARCHAR(MAX)  =  'franciscoe@pearlleather.com.mx'
				--SET @VP_RECIPIENTS = 'manuelg@pearlleather.com.mx;omard@pearlleather.com.mx;adelaree@pearlleather.com.mx;guillermom@pearlleather.com.mx;jorgeh@pearlleather.com.mx;miguelc@pearlleather.com.mx;pedrov@pearlleather.com.mx'

				DECLARE @VP_SUBJECT		VARCHAR(255) = 'TEST DEV'
				DECLARE @VP_FECHA		VARCHAR(10) = CONVERT(VARCHAR(10), GETDATE(),103)
				DECLARE @VP_BODY		NVARCHAR(MAX) 
				
SET @VP_BODY = '<!DOCTYPE html><html><head><style>
#id0 { background-color: rgb(200, 240, 200); }
#id1 { background-color: rgb(240, 200, 200); }
#id2 { background-color: rgb(200, 200, 240); }
table, tr, th, td {
    border:1px solid black;
    border-collapse:collapse;
	text-align:left;}
Caption {font-weight:bold; background-color:yellow;}
</style>

</head><body>
<table align="left" cellpadding="5" cols="8" frame="vsides" rules="rows" width="90%">
<caption align="top">HTML email example from sys.tables query</caption>
<thead>
      <tr> <th>Name</th> <th>ObjectID</th> <th>Type</th> <th>Created</th> <th>Modified</th> <th>System obj</th> <th>Ansi nulls</th> <th>Text-in-row</th> </tr>
</thead>
<tbody>' + (
    SELECT top 1 [@id] = 'id' + LTRIM(ROW_NUMBER() OVER (ORDER BY name) % 3),
         td = ISNULL(name,' '), '',
         td = ISNULL(LTRIM([object_id]),' '), '',
         td = ISNULL(type_desc,' '), '',
         td = ISNULL(CONVERT(CHAR(19), create_date, 120),' '), '',
         td = ISNULL(CONVERT(CHAR(19), modify_date, 120),' '), '',
         td = ISNULL(LTRIM(is_ms_shipped),' '), '',
         td = ISNULL(LTRIM(uses_ansi_nulls),' '), '',
         td = ISNULL(LTRIM(text_in_row_limit),' ')
    FROM sys.tables
    ORDER BY name
    FOR XML PATH('tr') )
    + '</tbody>
<tfoot>
      <tr> <th colspan="8" align="center">And that''s how to format email queries</th> </tr>
</tfoot>
</table></body></html>';
SET ROWCOUNT 0
					 				
EXECUTE	BD_GENERAL.[dbo].[PG_ENVIAR_CORREO]	0, 0,
											@VP_RECIPIENTS, @VP_SUBJECT, @VP_BODY

