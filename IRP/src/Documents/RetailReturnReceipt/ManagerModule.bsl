#Region Posting

Function PostingGetDocumentDataTables(Ref, Cancel, PostingMode, Parameters, AddInfo = Undefined) Export
	Tables = New Structure();
	Parameters.IsReposting = False;
	
#Region NewRegistersPosting		
	QueryArray = GetQueryTextsSecondaryTables();
	PostingServer.ExecuteQuery(Ref, QueryArray, Parameters);
#EndRegion	
	
	Return Tables;
EndFunction

Function PostingGetLockDataSource(Ref, Cancel, PostingMode, Parameters, AddInfo = Undefined) Export
	DataMapWithLockFields = New Map();
	Return DataMapWithLockFields;
EndFunction

Procedure PostingCheckBeforeWrite(Ref, Cancel, PostingMode, Parameters, AddInfo = Undefined) Export
#Region NewRegisterPosting
	Tables = Parameters.DocumentDataTables;	
	QueryArray = GetQueryTextsMasterTables();
	PostingServer.SetRegisters(Tables, Ref);
	PostingServer.FillPostingTables(Tables, Ref, QueryArray, Parameters);
#EndRegion
EndProcedure

Function PostingGetPostingDataTables(Ref, Cancel, PostingMode, Parameters, AddInfo = Undefined) Export
	PostingDataTables = New Map();
	
#Region NewRegistersPosting
	PostingServer.SetPostingDataTables(PostingDataTables, Parameters);
#EndRegion	
	
	Return PostingDataTables;
EndFunction

Procedure PostingCheckAfterWrite(Ref, Cancel, PostingMode, Parameters, AddInfo = Undefined) Export
	CheckAfterWrite(Ref, Cancel, Parameters, AddInfo);
EndProcedure

#EndRegion

#Region Undoposting

Function UndopostingGetDocumentDataTables(Ref, Cancel, Parameters, AddInfo = Undefined) Export
	Return PostingGetDocumentDataTables(Ref, Cancel, Undefined, Parameters, AddInfo);
EndFunction

Function UndopostingGetLockDataSource(Ref, Cancel, Parameters, AddInfo = Undefined) Export
	DataMapWithLockFields = New Map();
	Return DataMapWithLockFields;
EndFunction

Procedure UndopostingCheckBeforeWrite(Ref, Cancel, Parameters, AddInfo = Undefined) Export
#Region NewRegistersPosting
	QueryArray = GetQueryTextsMasterTables();
	PostingServer.ExecuteQuery(Ref, QueryArray, Parameters);
#EndRegion
EndProcedure

Procedure UndopostingCheckAfterWrite(Ref, Cancel, Parameters, AddInfo = Undefined) Export
	Parameters.Insert("Unposting", True);
	CheckAfterWrite(Ref, Cancel, Parameters, AddInfo);
EndProcedure

#EndRegion

#Region CheckAfterWrite

Procedure CheckAfterWrite(Ref, Cancel, Parameters, AddInfo = Undefined)
	PostingServer.CheckBalance_AfterWrite(Ref, Cancel, Parameters, "Document.RetailReturnReceipt.ItemList", AddInfo);
EndProcedure

#EndRegion

#Region NewRegistersPosting
Function GetInformationAboutMovements(Ref) Export
	Str = New Structure;
	Str.Insert("QueryParamenters", GetAdditionalQueryParamenters(Ref));
	Str.Insert("QueryTextsMasterTables", GetQueryTextsMasterTables());
	Str.Insert("QueryTextsSecondaryTables", GetQueryTextsSecondaryTables());
	Return Str;
EndFunction

Function GetAdditionalQueryParamenters(Ref)
	StrParams = New Structure();
	StrParams.Insert("Ref", Ref);
	Return StrParams;
EndFunction

Function GetQueryTextsSecondaryTables()
	QueryArray = New Array;
	QueryArray.Add(ItemList());
	QueryArray.Add(Payments());
	QueryArray.Add(RetailSales());
	QueryArray.Add(PostingServer.Exists_R4011B_FreeStocks());
	QueryArray.Add(PostingServer.Exists_R4010B_ActualStocks());	
	Return QueryArray;
EndFunction

Function GetQueryTextsMasterTables()
	QueryArray = New Array;
	QueryArray.Add(R4011B_FreeStocks());
	QueryArray.Add(R4010B_ActualStocks());
	QueryArray.Add(R3010B_CashOnHand());
	QueryArray.Add(R3050T_RetailCash());
	QueryArray.Add(R2050T_RetailSales());
	QueryArray.Add(R5021T_Revenues());
	QueryArray.Add(R2002T_SalesReturns());
	Return QueryArray;
EndFunction

Function ItemList()
	Return
	"SELECT
	|	ItemList.Ref.Company AS Company,
	|	ItemList.Store AS Store,
	|	ItemList.ItemKey AS ItemKey,
	|	ItemList.Ref AS SalesReturn,
	|	ItemList.QuantityInBaseUnit AS Quantity,
	|	ItemList.TotalAmount AS TotalAmount,
	|	ItemList.Ref.Partner AS Partner,
	|	ItemList.Ref.LegalName AS LegalName,
	|	CASE
	|		WHEN ItemList.Ref.Agreement.Kind = VALUE(Enum.AgreementKinds.Regular)
	|		AND ItemList.Ref.Agreement.ApArPostingDetail = VALUE(Enum.ApArPostingDetail.ByStandardAgreement)
	|			THEN ItemList.Ref.Agreement.StandardAgreement
	|		ELSE ItemList.Ref.Agreement
	|	END AS Agreement,
	|	ISNULL(ItemList.Ref.Currency, VALUE(Catalog.Currencies.EmptyRef)) AS Currency,
	|	ItemList.Ref.Date AS Period,
	|	CASE
	|		WHEN ItemList.RetailSalesReceipt = VALUE(Document.RetailSalesReceipt.EmptyRef)
	|			THEN ItemList.Ref
	|		ELSE ItemList.RetailSalesReceipt
	|	END AS RetailSalesReceipt,
	|	ItemList.Key AS RowKey,
	|	ItemList.ItemKey.Item.ItemType.Type = VALUE(Enum.ItemTypes.Service) AS IsService,
	|	ItemList.BusinessUnit AS BusinessUnit,
	|	ItemList.RevenueType AS RevenueType,
	|	ItemList.AdditionalAnalytic AS AdditionalAnalytic,
	|	ItemList.NetAmount AS NetAmount,
	|	ItemList.OffersAmount AS OffersAmount,
	|	ItemList.ReturnReason AS ReturnReason,
	|	CASE
	|		WHEN ItemList.RetailSalesReceipt.Ref IS NULL
	|			THEN ItemList.Ref
	|		ELSE ItemList.RetailSalesReceipt
	|	END AS Invoice
	|INTO ItemList
	|FROM
	|	Document.RetailReturnReceipt.ItemList AS ItemList
	|WHERE
	|	ItemList.Ref = &Ref";
EndFunction

Function Payments()
	Return
	"SELECT
	|	Payments.Ref.Date AS Period,
	|	Payments.Ref.Company AS Company,
	|	Payments.Account AS Account,
	|	Payments.Ref.Currency AS Currency,
	|	Payments.Amount AS Amount,
	|	Payments.Ref.BusinessUnit AS BusinessUnit,
	|	Payments.PaymentType AS PaymentType,
	|	Payments.PaymentTerminal AS PaymentTerminal,
	|	Payments.Percent AS Percent,
	|	Payments.Commission AS Commission
	|INTO Payments
	|FROM
	|	Document.RetailReturnReceipt.Payments AS Payments
	|WHERE
	|	Payments.Ref = &Ref";
EndFunction

Function RetailSales()
	Return 
	"SELECT
	|	RetailReturnReceiptItemList.Ref.BusinessUnit AS BusinessUnit,
	|	RetailReturnReceiptItemList.Ref.Company AS Company,
	|	RetailReturnReceiptItemList.ItemKey AS ItemKey,
	|	SUM(RetailReturnReceiptItemList.QuantityInBaseUnit) AS Quantity,
	|	SUM(ISNULL(RetailReturnReceiptSerialLotNumbers.Quantity, 0)) AS QuantityBySerialLtNumbers,
	|	RetailReturnReceiptItemList.Ref.Date AS Period,
	|	CASE
	|		WHEN RetailReturnReceiptItemList.RetailSalesReceipt = VALUE(Document.RetailSalesReceipt.EmptyRef)
	|			THEN RetailReturnReceiptItemList.Ref
	|		ELSE RetailReturnReceiptItemList.RetailSalesReceipt
	|	END AS RetailSalesReceipt,
	|	SUM(RetailReturnReceiptItemList.TotalAmount) AS Amount,
	|	SUM(RetailReturnReceiptItemList.NetAmount) AS NetAmount,
	|	SUM(RetailReturnReceiptItemList.OffersAmount) AS OffersAmount,
	|	RetailReturnReceiptItemList.Key AS RowKey,
	|	RetailReturnReceiptSerialLotNumbers.SerialLotNumber AS SerialLotNumber,
	|	RetailReturnReceiptItemList.Store
	|INTO tmpRetailSales
	|FROM
	|	Document.RetailReturnReceipt.ItemList AS RetailReturnReceiptItemList
	|		LEFT JOIN Document.RetailReturnReceipt.SerialLotNumbers AS RetailReturnReceiptSerialLotNumbers
	|		ON RetailReturnReceiptItemList.Key = RetailReturnReceiptSerialLotNumbers.Key
	|		AND RetailReturnReceiptItemList.Ref = RetailReturnReceiptSerialLotNumbers.Ref
	|		AND RetailReturnReceiptItemList.Ref = &Ref
	|		AND RetailReturnReceiptSerialLotNumbers.Ref = &Ref
	|WHERE
	|	RetailReturnReceiptItemList.Ref = &Ref
	|GROUP BY
	|	RetailReturnReceiptItemList.Ref.BusinessUnit,
	|	RetailReturnReceiptItemList.Ref.Company,
	|	RetailReturnReceiptItemList.ItemKey,
	|	RetailReturnReceiptItemList.Ref.Date,
	|	CASE
	|		WHEN RetailReturnReceiptItemList.RetailSalesReceipt = VALUE(Document.RetailSalesReceipt.EmptyRef)
	|			THEN RetailReturnReceiptItemList.Ref
	|		ELSE RetailReturnReceiptItemList.RetailSalesReceipt
	|	END,
	|	RetailReturnReceiptItemList.Key,
	|	RetailReturnReceiptSerialLotNumbers.SerialLotNumber,
	|	RetailReturnReceiptItemList.Store
	|;
	|
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	tmpRetailSales.Company AS Company,
	|	tmpRetailSales.BusinessUnit AS BusinessUnit,
	|	tmpRetailSales.ItemKey AS ItemKey,
	|	CASE
	|		WHEN tmpRetailSales.QuantityBySerialLtNumbers = 0
	|			THEN -tmpRetailSales.Quantity
	|		ELSE -tmpRetailSales.QuantityBySerialLtNumbers
	|	END AS Quantity,
	|	tmpRetailSales.Period AS Period,
	|	tmpRetailSales.RetailSalesReceipt AS RetailSalesReceipt,
	|	tmpRetailSales.RowKey AS RowKey,
	|	tmpRetailSales.SerialLotNumber AS SerialLotNumber,
	|	CASE
	|		WHEN tmpRetailSales.QuantityBySerialLtNumbers <> 0
	|			THEN CASE
	|				WHEN tmpRetailSales.Quantity = 0
	|					THEN 0
	|				ELSE -tmpRetailSales.Amount / tmpRetailSales.Quantity * tmpRetailSales.QuantityBySerialLtNumbers
	|			END
	|		ELSE tmpRetailSales.Amount
	|	END AS Amount,
	|	CASE
	|		WHEN tmpRetailSales.QuantityBySerialLtNumbers <> 0
	|			THEN CASE
	|				WHEN tmpRetailSales.Quantity = 0
	|					THEN 0
	|				ELSE -tmpRetailSales.NetAmount / tmpRetailSales.Quantity * tmpRetailSales.QuantityBySerialLtNumbers
	|			END
	|		ELSE tmpRetailSales.NetAmount
	|	END AS NetAmount,
	|	CASE
	|		WHEN tmpRetailSales.QuantityBySerialLtNumbers <> 0
	|			THEN CASE
	|				WHEN tmpRetailSales.Quantity = 0
	|					THEN 0
	|				ELSE -tmpRetailSales.OffersAmount / tmpRetailSales.Quantity * tmpRetailSales.QuantityBySerialLtNumbers
	|			END
	|		ELSE tmpRetailSales.OffersAmount
	|	END AS OffersAmount,
	|	tmpRetailSales.Store
	|INTO RetailSales
	|FROM
	|	tmpRetailSales AS tmpRetailSales";
EndFunction

Function R3010B_CashOnHand()
	Return
		"SELECT
		|	VALUE(AccumulationRecordType.Expense) AS RecordType,
		|	*
		|INTO R3010B_CashOnHand
		|FROM
		|	Payments AS Payments
		|WHERE
		|	TRUE";
EndFunction

Function R4011B_FreeStocks()
	Return
	"SELECT
	|	VALUE(AccumulationRecordType.Receipt) AS RecordType,
	|	*
	|INTO R4011B_FreeStocks
	|FROM
	|	ItemList AS ItemList
	|WHERE
	|	NOT ItemList.IsService";	
EndFunction

Function R4010B_ActualStocks()
	Return
	"SELECT
	|	VALUE(AccumulationRecordType.Receipt) AS RecordType,
	|	*
	|INTO R4010B_ActualStocks
	|FROM
	|	ItemList AS ItemList
	|WHERE
	|	NOT ItemList.IsService";	
EndFunction	

Function R3050T_RetailCash()
	Return
		"SELECT
		|	- Payments.Amount AS Amount,
		|	*
		|INTO R3050T_RetailCash
		|FROM
		|	Payments AS Payments
		|WHERE
		|	TRUE";
EndFunction

Function R2050T_RetailSales()
	Return
		"SELECT
		|	*
		|INTO R2050T_RetailSales
		|FROM
		|	RetailSales AS RetailSales
		|WHERE
		|	TRUE";
EndFunction

Function R5021T_Revenues()
	Return
		"SELECT
		|	*,
		|	- ItemList.NetAmount AS Amount
		|INTO R5021T_Revenues
		|FROM
		|	ItemList AS ItemList
		|WHERE
		|	TRUE";
EndFunction

Function R2002T_SalesReturns()
	Return
		"SELECT
		|	*,
		|	ItemList.TotalAmount AS Amount
		|INTO R2002T_SalesReturns
		|FROM
		|	ItemList AS ItemList
		|WHERE
		|	TRUE";
EndFunction

#EndRegion
