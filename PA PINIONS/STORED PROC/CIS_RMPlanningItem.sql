USE [PAP_LIVE_Branch]
GO
/****** Object:  StoredProcedure [dbo].[CIS_RMPlanningItem]    Script Date: 12/11/2024 3:25:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROC [dbo].[CIS_RMPlanningItem] 
( @DocEntry Nvarchar(8)
)


 AS Begin 


Create table #RMItem
  (ItemCode Nvarchar(2000),ItemCode1 Nvarchar(2000),ItemName Nvarchar(250),ItemGroup Nvarchar(10))
Insert into #RMItem (ItemCode,ItemCode1,ItemName,ItemGroup)

Select B.U_COM1,D.FrgnName,D.ItemName,D.ItmsGrpCod
from [dbo].[@BOMH] A 
Inner Join [dbo].[@BOMD] B On A.DocEntry = B.DocEntry 
Inner Join OITM D On B.U_COM1 =D.ItemCode
Where A.DocEntry=@DocEntry

Union All 

Select B.U_COM2,D.FrgnName,D.ItemName,D.ItmsGrpCod
from [dbo].[@BOMH] A 
Inner Join [dbo].[@BOMD] B On A.DocEntry = B.DocEntry 
Inner Join OITM D On B.U_COM2 =D.ItemCode
Where A.DocEntry=@DocEntry

Union All 

Select B.U_COM3,D.FrgnName,D.ItemName,D.ItmsGrpCod
from [dbo].[@BOMH] A 
Inner Join [dbo].[@BOMD] B On A.DocEntry = B.DocEntry 
Inner Join OITM D On B.U_COM3 =D.ItemCode
Where A.DocEntry=@DocEntry

Union All 

Select B.U_COM4,D.FrgnName,D.ItemName,D.ItmsGrpCod
from [dbo].[@BOMH] A 
Inner Join [dbo].[@BOMD] B On A.DocEntry = B.DocEntry 
Inner Join OITM D On B.U_COM4 =D.ItemCode
Where A.DocEntry= @DocEntry

Union All 

Select B.U_COM5,D.FrgnName,D.ItemName,D.ItmsGrpCod
from [dbo].[@BOMH] A 
Inner Join [dbo].[@BOMD] B On A.DocEntry = B.DocEntry 
Inner Join OITM D On B.U_COM5 =D.ItemCode
Where A.DocEntry= @DocEntry

Union All 

Select B.U_COM6,D.FrgnName,D.ItemName,D.ItmsGrpCod
from [dbo].[@BOMH] A 
Inner Join [dbo].[@BOMD] B On A.DocEntry = B.DocEntry 
Inner Join OITM D On B.U_COM6 =D.ItemCode
Where A.DocEntry= @DocEntry

Select Distinct * From #RMItem Z Where Z.ItemGroup in ('103','109')

Drop table #RMItem

END

