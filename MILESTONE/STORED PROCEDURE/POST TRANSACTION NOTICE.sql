USE [MSPLNew_Live_@25062024]
GO
/****** Object:  StoredProcedure [dbo].[SBO_SP_PostTransactionNotice]    Script Date: 12/12/2024 5:32:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[SBO_SP_PostTransactionNotice]

@object_type nvarchar(30), 				-- SBO Object Type
@transaction_type nchar(1),			-- [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
@num_of_cols_in_key int,
@list_of_key_cols_tab_del nvarchar(255),
@list_of_cols_val_tab_del nvarchar(255)

AS

begin

-- Return values
declare @error  int				-- Result (0 for no error)
declare @error_message nvarchar (200) 		-- Error string to be displayed
select @error = 0
select @error_message = N'Ok'

--------------------------------------------------------------------------------------------------------------------------------

--	ADD	YOUR	CODE	HERE
If @object_type = '202' and  @transaction_type IN ('A','U')
BEGIN 
Update T0 set T0.U_Payment='Done',T0.U_PaymentInvoice=T1.DocEntry From OPCH T1 Inner Join OINV T0 
On T0.U_Transporter_Name=T0.CardCode and T0.DocEntry=T1.U_ARInvoice Where t1.DocEntry = @list_of_cols_val_tab_del;
end

---------------------------------Quantity in KG Calculation
If @object_type = '20' and  @transaction_type IN ('A','U')
BEGIN
UPDATE a
SET a.U_QTYK = ((ISNULL(a.U_Length,0) * ISNULL(a.U_Width,0) * ISNULL(a.U_Thick,0) * ISNULL(a.U_Density,0))/1000000)
FROM PDN1 a
where a.DocEntry = @list_of_cols_val_tab_del
END



--------------------------------------------------------------------------------------------------------------------------------

-- Select the return values
select @error, @error_message

end