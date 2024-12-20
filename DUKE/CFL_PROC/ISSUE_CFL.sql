USE [DukeLiveNew]
GO
/****** Object:  StoredProcedure [dbo].[Issue_CFL]    Script Date: 02-12-2024 10:16:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure  [dbo].[Issue_CFL] 
(
@mode	varchar(40),
@parameter1	nvarchar(40)=null,
@parameter2	nvarchar(40)=null,
@parameter3	nvarchar(40)=null,
@parameter4	nvarchar(40)=null,
@parameter5	nvarchar(40)=null,
@parameter6	nvarchar(40)=null,
@ColumnName nvarchar(60)=null,
@order  nvarchar(60)=null , 
@DOC  nvarchar(60)=null 
)
as
BEGIN

if(@parameter2)=''
begin
set @parameter2=NULL
end
IF (@parameter3)=''
begin
set @parameter3=NULL
end
IF (@parameter4)=''
begin
set @parameter4=NULL
end
IF (@parameter5)=''
begin
set @parameter5=NULL
end
--------------------------get ItemCode--------------------------------
IF upper (@mode)='get_ItemCode'						  
begin 


select ItemCode,FrgnName,U_Size,U_MRP,U_Gender,U_CP from OITM(NoLock)

end


--------------------------get Warehouse --------------------------------
IF upper (@mode)='get_WHS'						  
begin 


select WhsCode,WhsName from OWHS(NoLock)

end

END

/*Minimum no of column is 3 in CFL*/

