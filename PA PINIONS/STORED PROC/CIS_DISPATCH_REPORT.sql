USE [PAP_LIVE_Branch]
GO
/****** Object:  StoredProcedure [dbo].[CIS_Dispatch_Report]    Script Date: 12/11/2024 3:20:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Procedure [dbo].[CIS_Dispatch_Report]
(
@T1 DateTime
--@Code nvarchar(250)
)
AS
BEGIN
SELECT 
    T0.U_CCUC AS 'Customer Code',
    T1.U_PANO AS 'PartNo',
    T1.U_DIPQ AS 'Schedule Qty',
    DATEDIFF(DAY, T1.U_CODD,@t1 ) AS 'Days Difference',
    T1.U_CODD AS 'Confirmed Dispatch Date by PPC',
    '' AS 'Planned Qty',
    '' AS 'Short Qty',
    '' AS 'Reason of Shortage',
    '' AS 'Revised Date of Shortage',
    T1.U_FGST AS 'FG Stock',
    T0.Remark
FROM dbo.[@IMOH] T0
INNER JOIN dbo.[@IMOD] T1 ON T1.DocEntry = T0.DocEntry
WHERE 
    ISNULL(T1.U_PONOS, '') <> '' 
    --AND (T0.U_CCUC = '[%2]' OR '[%2]' = '')
  and DATEDIFF(DAY, T1.U_CODD,@t1 )>=0  AND  DATEDIFF(DAY, T1.U_CODD,@t1 )<=5 
	End
