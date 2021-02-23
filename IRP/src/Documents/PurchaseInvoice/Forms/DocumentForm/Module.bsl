﻿
#Region FormEvents

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	DocPurchaseInvoiceServer.OnCreateAtServer(Object, ThisObject, Cancel, StandardProcessing);
	If Parameters.Key.IsEmpty() Then
		SetVisibilityAvailability(Object, ThisObject);
	EndIf;
EndProcedure

&AtClient
Procedure OnOpen(Cancel, AddInfo = Undefined) Export
	DocPurchaseInvoiceClient.OnOpen(Object, ThisObject, Cancel);
EndProcedure

&AtClient
Procedure NotificationProcessing(EventName, Parameter, Source, AddInfo = Undefined) Export
	If EventName = "UpdateAddAttributeAndPropertySets" Then
		AddAttributesCreateFormControl();
	EndIf;
	
	If Not Source = ThisObject Then
		Return;
	EndIf;
	
	DocPurchaseInvoiceClient.NotificationProcessing(Object, ThisObject, EventName, Parameter, Source, AddInfo);
	
	ServerData = Undefined;		
	If TypeOf(Parameter) = Type("Structure") And Parameter.Property("AddInfo") Then
		ServerData = CommonFunctionsClientServer.GetFromAddInfo(Parameter.AddInfo, "ServerData");
	EndIf;
	
	If EventName = "NewBarcode" And IsInputAvailable() Then
		SearchByBarcode(Undefined, Parameter);
	EndIf;
	
	If Upper(EventName) = Upper("CallbackHandler") Then
		CurrenciesClient.CalculateAmount(Object, ThisObject);
		CurrenciesClient.SetRatePresentation(Object, ThisObject);
				
		If ServerData <> Undefined Then
			CurrenciesClient.SetVisibleRows(Object, ThisObject, Parameter.AddInfo);
		EndIf;
	EndIf;
EndProcedure

&AtClient
Procedure BeforeWrite(Cancel, WriteParameters)
	Return;
EndProcedure

&AtServer
Procedure OnWriteAtServer(Cancel, CurrentObject, WriteParameters)
	DocumentsServer.OnWriteAtServer(Object, ThisObject, Cancel, CurrentObject, WriteParameters);
EndProcedure

&AtClient
Procedure AfterWrite(WriteParameters, AddInfo = Undefined) Export
	DocPurchaseInvoiceClient.AfterWriteAtClient(Object, ThisObject, WriteParameters);
EndProcedure

&AtServer
Procedure AfterWriteAtServer(CurrentObject, WriteParameters, AddInfo = Undefined) Export
	DocPurchaseInvoiceServer.AfterWriteAtServer(Object, ThisObject, CurrentObject, WriteParameters);
	SetVisibilityAvailability(CurrentObject, ThisObject);
EndProcedure

&AtServer
Procedure OnReadAtServer(CurrentObject)
	DocPurchaseInvoiceServer.OnReadAtServer(Object, ThisObject, CurrentObject);
	SetVisibilityAvailability(CurrentObject, ThisObject);
EndProcedure

&AtServer
Procedure BeforeWriteAtServer(Cancel, CurrentObject, WriteParameters)
	AddAttributesAndPropertiesServer.BeforeWriteAtServer(ThisObject, Cancel, CurrentObject, WriteParameters);
EndProcedure

&AtClientAtServerNoContext
Procedure SetVisibilityAvailability(Object, Form) Export
	Form.Items.LegalName.Enabled = ValueIsFilled(Object.Partner);
EndProcedure

#EndRegion

#Region FormItemsEvents

&AtClient
Procedure DateOnChange(Item, AddInfo = Undefined) Export
	DocPurchaseInvoiceClient.DateOnChange(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure StoreOnChange(Item)
	DocPurchaseInvoiceClient.StoreOnChange(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure DeliveryDateOnChange(Item)
	DocumentsClient.DeliveryDateOnChange(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure PartnerOnChange(Item, AddInfo = Undefined) Export	
	DocPurchaseInvoiceClient.PartnerOnChange(Object, ThisObject, Item, AddInfo);
	SetVisibilityAvailability(Object, ThisObject);
EndProcedure

&AtClient
Procedure LegalNameOnChange(Item, AddInfo = Undefined) Export
	DocPurchaseInvoiceClient.LegalNameOnChange(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure AgreementOnChange(Item, AddInfo = Undefined) Export
	DocPurchaseInvoiceClient.AgreementOnChange(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure CompanyOnChange(Item, AddInfo = Undefined) Export
	DocPurchaseInvoiceClient.CompanyOnChange(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure PriceIncludeTaxOnChange(Item)
	DocPurchaseInvoiceClient.PriceIncludeTaxOnChange(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure CurrencyOnChange(Item)
	DocPurchaseInvoiceClient.CurrencyOnChange(Object, ThisObject, Item);
EndProcedure

#EndRegion

#Region ItemListEvents

&AtClient
Procedure ItemListAfterDeleteRow(Item)
	DocPurchaseInvoiceClient.ItemListAfterDeleteRow(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure ItemListOnChange(Item, AddInfo = Undefined) Export
	DocPurchaseInvoiceClient.ItemListOnChange(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure ItemListOnStartEdit(Item, NewRow, Clone)
	If Clone Then
		Item.CurrentData.Key = New UUID();
	EndIf;
	DocumentsClient.TableOnStartEdit(Object, ThisObject, "Object.ItemList", Item, NewRow, Clone);
EndProcedure

&AtClient
Procedure ItemListOnActivateRow(Item)
	DocPurchaseInvoiceClient.ItemListOnActivateRow(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure ItemListSelection(Item, RowSelected, Field, StandardProcessing)
	DocPurchaseInvoiceClient.ItemListSelection(Object, ThisObject, Item, RowSelected, Field, StandardProcessing);
EndProcedure

#EndRegion

#Region ItemListItemsEvents

&AtClient
Procedure ItemListItemOnChange(Item, AddInfo = Undefined) Export
	DocPurchaseInvoiceClient.ItemListItemOnChange(Object, ThisObject, Item, AddInfo);
EndProcedure

&AtClient
Procedure ItemListItemStartChoice(Item, ChoiceData, StandardProcessing)
	DocPurchaseInvoiceClient.ItemListItemStartChoice(Object, ThisObject, Item, ChoiceData, StandardProcessing);
EndProcedure

&AtClient
Procedure ItemListItemEditTextChange(Item, Text, StandardProcessing)
	DocPurchaseInvoiceClient.ItemListItemEditTextChange(Object, ThisObject, Item, Text, StandardProcessing);
EndProcedure

&AtClient
Procedure ItemListItemKeyOnChange(Item, AddInfo = Undefined) Export
	DocPurchaseInvoiceClient.ItemListItemKeyOnChange(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure ItemListPriceTypeOnChange(Item, AddInfo = Undefined) Export
	DocPurchaseInvoiceClient.ItemListPriceTypeOnChange(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure ItemListUnitOnChange(Item, AddInfo = Undefined) Export
	DocPurchaseInvoiceClient.ItemListUnitOnChange(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure ItemListQuantityOnChange(Item, AddInfo = Undefined) Export	
	DocPurchaseInvoiceClient.ItemListQuantityOnChange(Object, ThisObject, Item, AddInfo);
EndProcedure

&AtClient
Procedure ItemListSerialLotNumbersPresentationStartChoice(Item, ChoiceData, StandardProcessing, AddInfo = Undefined) Export
	DocPurchaseInvoiceClient.ItemListSerialLotNumbersPresentationStartChoice(Object, ThisObject, Item, ChoiceData, StandardProcessing);
EndProcedure

&AtClient
Procedure ItemListSerialLotNumbersPresentationClearing(Item, StandardProcessing)
	DocPurchaseInvoiceClient.ItemListSerialLotNumbersPresentationClearing(Object, ThisObject, Item, StandardProcessing);
EndProcedure

&AtClient
Procedure ItemListPriceOnChange(Item, AddInfo = Undefined) Export
	DocPurchaseInvoiceClient.ItemListPriceOnChange(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure ItemListTotalAmountOnChange(Item, AddInfo = Undefined) Export
	DocPurchaseInvoiceClient.ItemListTotalAmountOnChange(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure ItemListTaxAmountOnChange(Item)
	DocPurchaseInvoiceClient.ItemListTaxAmountOnChange(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure ItemListDontCalculateRowOnChange(Item)
	DocPurchaseInvoiceClient.ItemListDontCalculateRowOnChange(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure ItemListStoreOnChange(Item)
	DocPurchaseInvoiceClient.ItemListStoreOnChange(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure ItemListExpenseTypeStartChoice(Item, ChoiceData, StandardProcessing)
	DocPurchaseInvoiceClient.ItemListExpenseTypeStartChoice(Object, ThisObject, Item, ChoiceData, StandardProcessing);
EndProcedure

&AtClient
Procedure ItemListExpenseTypeEditTextChange(Item, Text, StandardProcessing)
	DocPurchaseInvoiceClient.ItemListExpenseTypeEditTextChange(Object, ThisObject, Item, Text, StandardProcessing);
EndProcedure

#EndRegion

#Region ItemPartner

&AtClient
Procedure PartnerStartChoice(Item, ChoiceData, StandardProcessing)
	DocPurchaseInvoiceClient.PartnerStartChoice(Object, ThisObject, Item, ChoiceData, StandardProcessing);
EndProcedure

&AtClient
Procedure PartnerEditTextChange(Item, Text, StandardProcessing)
	DocPurchaseInvoiceClient.PartnerTextChange(Object, ThisObject, Item, Text, StandardProcessing);
EndProcedure

#EndRegion

#Region ItemLegalName

&AtClient
Procedure LegalNameStartChoice(Item, ChoiceData, StandardProcessing)
	DocPurchaseInvoiceClient.LegalNameStartChoice(Object, ThisObject, Item, ChoiceData, StandardProcessing);
EndProcedure

&AtClient
Procedure LegalNameEditTextChange(Item, Text, StandardProcessing)
	DocPurchaseInvoiceClient.LegalNameTextChange(Object, ThisObject, Item, Text, StandardProcessing);
EndProcedure

#EndRegion

#Region ItemAgreement

&AtClient
Procedure AgreementStartChoice(Item, ChoiceData, StandardProcessing)
	DocPurchaseInvoiceClient.AgreementStartChoice(Object, ThisObject, Item, ChoiceData, StandardProcessing);
EndProcedure

&AtClient
Procedure AgreementEditTextChange(Item, Text, StandardProcessing)
	DocPurchaseInvoiceClient.AgreementTextChange(Object, ThisObject, Item, Text, StandardProcessing);
EndProcedure

#EndRegion

#Region ItemCompany

&AtClient
Procedure CompanyStartChoice(Item, ChoiceData, StandardProcessing)
	DocPurchaseInvoiceClient.CompanyStartChoice(Object, ThisObject, Item, ChoiceData, StandardProcessing);
EndProcedure

&AtClient
Procedure CompanyEditTextChange(Item, Text, StandardProcessing)
	DocPurchaseInvoiceClient.CompanyEditTextChange(Object, ThisObject, Item, Text, StandardProcessing);
EndProcedure

#EndRegion

#Region DescriptionEvents

&AtClient
Procedure DescriptionClick(Item, StandardProcessing)
	DocumentsClient.DescriptionClick(Object, ThisObject, Item, StandardProcessing);
EndProcedure

#EndRegion

#Region SpecialOffers

#Region Offers_for_document

&AtClient
Procedure SetSpecialOffers(Command)
	OffersClient.OpenFormPickupSpecialOffers_ForDocument(Object,
		ThisObject,
		"SpecialOffersEditFinish_ForDocument");
EndProcedure

&AtClient
Procedure SpecialOffersEditFinish_ForDocument(Result, AdditionalParameters) Export
	OffersClient.SpecialOffersEditFinish_ForDocument(Result, Object, ThisObject, AdditionalParameters);
	
EndProcedure

#EndRegion

#Region Offers_for_row

&AtClient
Procedure SetSpecialOffersAtRow(Command)
	OffersClient.OpenFormPickupSpecialOffers_ForRow(Object,
		Items.ItemList.CurrentData,
		ThisObject,
		"SpecialOffersEditFinish_ForRow");
EndProcedure

&AtClient
Procedure SpecialOffersEditFinish_ForRow(Result, AdditionalParameters) Export
	OffersClient.SpecialOffersEditFinish_ForRow(Result, Object, ThisObject, AdditionalParameters);
EndProcedure

#EndRegion

#EndRegion

#Region GroupTitleDecorations

&AtClient
Procedure DecorationGroupTitleCollapsedPictureClick(Item)
	DocumentsClient.DecorationGroupTitleCollapsedPictureClick(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure DecorationGroupTitleCollapsedLabelClick(Item)
	DocumentsClient.DecorationGroupTitleCollapsedLabelClick(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure DecorationGroupTitleUncollapsedPictureClick(Item)
	DocumentsClient.DecorationGroupTitleUncollapsedPictureClick(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure DecorationGroupTitleUncollapsedLabelClick(Item)
	DocumentsClient.DecorationGroupTitleUncollapsedLabelClick(Object, ThisObject, Item);
EndProcedure

#EndRegion

#Region Commands

&AtClient
Procedure OpenPickupItems(Command)
	DocPurchaseInvoiceClient.OpenPickupItems(Object, ThisObject, Command);
EndProcedure

&AtClient
Procedure SearchByBarcode(Command, Barcode = "")
	DocPurchaseInvoiceClient.SearchByBarcode(Barcode, Object, ThisObject);
EndProcedure

&AtClient
Procedure SelectGoodsReceipt(Command)
	CommandParameters = New Structure("Company, Partner, LegalName, Agreement, Currency, PriceIncludeTax");
	FillPropertyValues(CommandParameters, Object);
	AlreadySelectedGoodsReceipts = New Array();
	For Each Row In Object.GoodsReceipts Do
		If AlreadySelectedGoodsReceipts.Find(Row.GoodsReceipt) = Undefined Then
			AlreadySelectedGoodsReceipts.Add(Row.GoodsReceipt);
		EndIf;
	EndDo;
	CommandParameters.Insert("AlreadySelectedGoodsReceipts", AlreadySelectedGoodsReceipts);
	InfoGoodsReceipt = DocPurchaseInvoiceServer.GetInfoGoodsReceiptBeforePurchaseInvoice(CommandParameters);
	
	FormParameters = New Structure("InfoGoodsReceipt", InfoGoodsReceipt.Tree);
	OpenForm("Document.PurchaseInvoice.Form.SelectGoodsReceiptForm"
		, FormParameters, , , ,
		, New NotifyDescription("SelectGoodsReceiptContinue", ThisObject,
			New Structure("InfoGoodsReceipt",
				InfoGoodsReceipt)));
EndProcedure

&AtClient
Procedure SelectGoodsReceiptContinue(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;
	
	ArrayOfBasisDocuments = New Array();
	For Each Row In AdditionalParameters.InfoGoodsReceipt.Linear Do
		If Result.Find(Row.GoodsReceipt) <> Undefined Then
			ArrayOfBasisDocuments.Add(Row);
		EndIf;
	EndDo;	
	SelectGoodsReceiptFinish(ArrayOfBasisDocuments);
	
	Taxes_CreateFormControls();
	DocumentsClient.SetLockedRowsForItemListByTradeDocuments(Object, ThisObject, "GoodsReceipts");
	DocumentsClient.UpdateTradeDocumentsTree(Object, ThisObject, 
		"GoodsReceipts", "GoodsReceiptsTree", "QuantityInGoodsReceipt");	
EndProcedure

&AtServer
Procedure SelectGoodsReceiptFinish(ArrayOfBasisDocuments)
	DocPurchaseInvoiceServer.FillDocumentWithGoodsReceiptArray(Object, ThisObject, ArrayOfBasisDocuments);
	For Each Row In Object.ItemList Do
		Row.Item = Row.ItemKey.Item;
	EndDo;
EndProcedure

&AtClient
Procedure SelectPurchaseOrders(Command)
	FilterValues = New Structure("Company, Partner, LegalName, Agreement, Currency, PriceIncludeTax");
	FillPropertyValues(FilterValues, Object);
	
	ExistingRows = New Array;
	For Each Row In Object.ItemList Do
		RowStructure = New Structure("Key, Unit, Quantity");
		FillPropertyValues(RowStructure, Row);
		ExistingRows.Add(RowStructure);
	EndDo;
	
	FormParameters = New Structure("FilterValues, ExistingRows, Ref", FilterValues, ExistingRows, Object.Ref);
	OpenForm("Document.PurchaseInvoice.Form.SelectPurchaseOrdersForm"
		, FormParameters, , , ,
		, New NotifyDescription("SelectPurchaseOrdersContinue", ThisObject));
EndProcedure

&AtClient
Procedure SelectPurchaseOrdersContinue(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;
	
	SelectPurchaseOrdersContinueAtServer(Result, AdditionalParameters);
	
	DocPurchaseInvoiceClient.ItemListOnChange(Object, ThisObject, Items.ItemList);
EndProcedure

&AtServer
Procedure SelectPurchaseOrdersContinueAtServer(Result, AdditionalParameters)
	Settings = New Structure();
	Settings.Insert("Rows", New Array());
	Settings.Insert("CalculateSettings", New Structure());
	Settings.CalculateSettings = CalculationStringsClientServer.GetCalculationSettings(Settings.CalculateSettings);
	
	For Each ResultRow In Result Do
		RowsByKey = Object.ItemList.FindRows(New Structure("Key", ResultRow.Key));
		If RowsByKey.Count() Then
			RowByKey = RowsByKey[0];
			ItemKeyUnit = CatItemsServer.GetItemKeyUnit(ResultRow.ItemKey);
			UnitFactorFrom = Catalogs.Units.GetUnitFactor(RowByKey.Unit, ItemKeyUnit);
			UnitFactorTo = Catalogs.Units.GetUnitFactor(ResultRow.Unit, ItemKeyUnit);
			FillPropertyValues(RowByKey, ResultRow, , "Quantity");
			RowByKey.Quantity = ?(UnitFactorTo = 0,
					0,
					RowByKey.Quantity * UnitFactorFrom / UnitFactorTo) + ResultRow.Quantity;
			RowByKey.PriceType = ResultRow.PriceType;
			RowByKey.Price = ResultRow.Price;
			Settings.Rows.Add(RowByKey);
		Else
			NewRow = Object.ItemList.Add();
			FillPropertyValues(NewRow, ResultRow);
			NewRow.PriceType = ResultRow.PriceType;
			NewRow.Price = ResultRow.Price;
			Settings.Rows.Add(NewRow);
		EndIf;
	EndDo;
	
	TaxInfo = Undefined;
	SavedData = TaxesClientServer.GetSavedData(ThisObject, TaxesServer.GetAttributeNames().CacheName);
	If SavedData.Property("ArrayOfColumnsInfo") Then
		TaxInfo = SavedData.ArrayOfColumnsInfo;
	EndIf;
	CalculationStringsClientServer.CalculateItemsRows(Object,
		ThisObject,
		Settings.Rows,
		Settings.CalculateSettings,
		TaxInfo);
EndProcedure

&AtClient
Procedure ShowRowKey(Command)
	DocumentsClient.ShowRowKey(ThisObject);
EndProcedure

#EndRegion

#Region Taxes

&AtClient
Procedure TaxValueOnChange(Item) Export
	DocPurchaseInvoiceClient.ItemListTaxValueOnChange(Object, ThisObject, Item);
EndProcedure

&AtServer
Function Taxes_CreateFormControls(AddInfo = Undefined) Export
	Return TaxesServer.CreateFormControls_RetailDocuments(Object, ThisObject, AddInfo);
EndFunction
	
#EndRegion

#Region Currencies

&AtClient
Procedure CurrenciesSelection(Item, RowSelected, Field, StandardProcessing, AddInfo = Undefined)
	CommonFunctionsClientServer.PutToAddInfo(AddInfo, "ExecuteAtClient", True);
	CurrenciesClient.CurrenciesTable_Selection(Object, ThisObject, Item, RowSelected, Field, StandardProcessing, AddInfo);
EndProcedure

&AtClient
Procedure CurrenciesRatePresentationOnChange(Item, AddInfo = Undefined)
	CommonFunctionsClientServer.PutToAddInfo(AddInfo, "ExecuteAtClient", True);
	CurrenciesClient.CurrenciesTable_RatePresentationOnChange(Object, ThisObject, Item, AddInfo);
EndProcedure

&AtClient
Procedure CurrenciesMultiplicityOnChange(Item, AddInfo = Undefined)
	CommonFunctionsClientServer.PutToAddInfo(AddInfo, "ExecuteAtClient", True);
	CurrenciesClient.CurrenciesTable_MultiplicityOnChange(Object, ThisObject, Item, AddInfo);
EndProcedure

&AtClient
Procedure CurrenciesAmountOnChange(Item, AddInfo = Undefined)
	CommonFunctionsClientServer.PutToAddInfo(AddInfo, "ExecuteAtClient", True);
	CurrenciesClient.CurrenciesTable_AmountOnChange(Object, ThisObject, Item, AddInfo);
EndProcedure

&AtClient
Procedure CurrenciesBeforeAddRow(Item, Cancel, Clone, Parent, IsFolder, Parameter)
	Cancel = True;
EndProcedure

&AtClient
Procedure CurrenciesBeforeDeleteRow(Item, Cancel)
	Cancel = True;
EndProcedure

#EndRegion

#Region AddAttributes

&AtClient
Procedure AddAttributeStartChoice(Item, ChoiceData, StandardProcessing) Export
	AddAttributesAndPropertiesClient.AddAttributeStartChoice(ThisObject, Item, StandardProcessing);
EndProcedure

&AtServer
Procedure AddAttributesCreateFormControl()
	AddAttributesAndPropertiesServer.CreateFormControls(ThisObject, "GroupOther");
EndProcedure

#EndRegion

#Region ExternalCommands

&AtClient
Procedure GeneratedFormCommandActionByName(Command) Export
	ExternalCommandsClient.GeneratedFormCommandActionByName(Object, ThisObject, Command.Name);
	GeneratedFormCommandActionByNameServer(Command.Name);	
EndProcedure

&AtServer
Procedure GeneratedFormCommandActionByNameServer(CommandName) Export
	ExternalCommandsServer.GeneratedFormCommandActionByName(Object, ThisObject, CommandName);
EndProcedure

#EndRegion

#Region GoodsReceiptsTree

&AtClient
Procedure GoodsReceiptsTreeQuantityOnChange(Item)
	DocumentsClient.TradeDocumentsTreeQuantityOnChange(Object, ThisObject, 
		"GoodsReceipts", "GoodsReceiptsTree", "GoodsReceipt");
EndProcedure
	
&AtClient
Procedure GoodsReceiptsTreeBeforeAddRow(Item, Cancel, Clone, Parent, IsFolder, Parameter)
	Cancel = True;
EndProcedure

&AtClient
Procedure GoodsReceiptsTreeBeforeDeleteRow(Item, Cancel)
	Cancel = True;
EndProcedure

#EndRegion
