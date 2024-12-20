USE [DukeLiveNew]
GO
/****** Object:  StoredProcedure [dbo].[POD_CFL]    Script Date: 02-12-2024 10:17:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure  [dbo].[POD_CFL] 
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
--------------------------get bp--------------------------------
IF upper (@mode)='get_BIllingTransporter'						  
begin 

 SELECT DISTINCT U_TN AS TransporterName,U_TN AS TransporterName2,U_TN AS TransporterName3 FROM OINV WHERE U_TN IS NOT NULL;

end


--------------------------get item --------------------------------
IF upper (@mode)='get_ReturnTransporter'		
				  
begin 
Select  Distinct T0.U_Transporter AS TransporterName,T0.U_Transporter AS TransporterName2,T0.U_Transporter AS TransporterName3 From [@GATEENTRYH] t0 where t0.U_Transporter is not null;



 

end

END
