tableextension 60036 "NXN EDIStockkeeping Unit Ext" extends "Stockkeeping Unit" //5700
{
    fields
    {
        // Add changes to table fields here
        field(60000; "NXN Sales Order Qty"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
            Caption = 'Sales Order Qty';
        }
        field(60001; "NXN Purch. Order Qty"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
            Caption = 'Purchase Order Qty';
        }
        field(60002; "NXN Assembly Order Qty"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
            Caption = 'Assembly Order Qty';
        }
        field(60003; "NXN Inventory Qty"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
            Caption = 'Inventory Qty';
        }

    }

    var
        myInt: Integer;
}