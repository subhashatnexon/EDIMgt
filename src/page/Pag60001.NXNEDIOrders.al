page 60001 "NXN EDI Orders"
{
    // ReSRP 20118-05-04: Carton Qty Added

    CardPageID = "NXN EDI Order";
    DataCaptionFields = "Entry No.", "Order ID";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NXN EDI Order Header";
    Caption = 'EDI Orders';
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Order ID"; "Order ID")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order ID field';
                }
                field("Customer ID"; "Customer ID")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer ID field';
                }
                field("Member ID"; "Member ID")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Member ID field';
                    Visible = false;
                }
                field("Bill-to Name"; "Bill-to Name")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to Name field';
                }
                field("Bill-to Name 2"; "Bill-to Name 2")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to Name 2 field';
                }
                field("Bill-to Address"; "Bill-to Address")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to Address field';
                }
                field("Bill-to Street"; "Bill-to Street")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to Street field';
                }
                field("Bill-to City"; "Bill-to City")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to City field';
                }
                field("Bill-to Contact"; "Bill-to Contact")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to Contact field';
                }
                field("Bill-to Post Code"; "Bill-to Post Code")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to Post Code field';
                }
                field("Bill-to State"; "Bill-to State")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to State field';
                }
                field("Bill-to Country/Region Code"; "Bill-to Country/Region Code")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to Country/Region Code field';
                }
                field("Ship-to Code"; "Ship-to Code")
                {
                    Editable = false;
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Code field';
                }
                field("Ship-to Name"; "Ship-to Name")
                {
                    Editable = false;
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Name field';
                }
                field("Ship-to Name 2"; "Ship-to Name 2")
                {
                    Editable = false;
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Name 2 field';
                }
                field("Ship-to Address"; "Ship-to Address")
                {
                    Editable = false;
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Address field';
                }
                field("Ship-to Street"; "Ship-to Street")
                {
                    Editable = false;
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Street field';
                }
                field("Ship-to City"; "Ship-to City")
                {
                    Editable = false;
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to City field';
                }
                field("Ship-to Contact"; "Ship-to Contact")
                {
                    Editable = false;
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Contact field';
                }
                field("Ship-to Post Code"; "Ship-to Post Code")
                {
                    Editable = false;
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Post Code field';
                }
                field("Ship-to State"; "Ship-to State")
                {
                    Editable = false;
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to State field';
                }
                field("Ship-to Country/Region Code"; "Ship-to Country/Region Code")
                {
                    Editable = false;
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Country/Region Code field';
                }
                field("Order Date"; "Order Date")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order Date field';
                }
                field("Order Time"; "Order Time")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order Time field';
                }
                field("Amount Including VAT"; "Amount Including VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Including VAT field';
                }
                field("Expected Delivery Date"; "Expected Delivery Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Expected Delivery Date field';
                }
                field("Order Method"; "Order Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order Method field';
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Doc Process Status"; "Doc Process Status")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Doc Process Status field';
                }
                field("Sales Order Created"; "Sales Order Created")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Order Created field';
                }
                field("Sales Order No."; "Sales Order No.")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Order No. field';
                }
                field("Purchase Order Created"; "Purchase Order Created")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Purchase Order Created field';
                }
                field("Purchase Order No."; "Purchase Order No.")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Purchase Order No. field';
                }
                field("Import File Name"; "Import File Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Order")
            {
                Caption = '&Order';
                Image = Invoice;
                action(Card)
                {
                    Caption = 'Card';
                    Image = EditLines;
                    Promoted = true;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+F7';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Card action';
                    trigger OnAction()
                    begin
                        PAGE.RUN(PAGE::"NXN EDI Order", Rec)
                    end;
                }
                action(CreateOrderFromCSV)
                {
                    Image = CreateDocuments;
                    Promoted = true;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    Caption = 'Create Order Excel/CSV';
                    trigger OnAction()
                    begin
                        NXNBlobMgt.CreateOrdersfromAzure();
                    end;
                }
                action(CreateOrderDocParser)
                {
                    Image = CreateDocument;
                    Promoted = true;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    Caption = 'Create Order from DocParser';
                    trigger OnAction()
                    begin
                        NXNBlobMgt.GetDocument();
                    end;
                }
                action("Open ParserList")
                {
                    Image = ListPage;
                    Promoted = true;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    Caption = 'Document Parser List';
                    RunObject = page "NXN DocParser List";

                }
            }
        }
    }
    var
        NXNBlobMgt: Codeunit "NXN Azure Blob Mgt.";
}

