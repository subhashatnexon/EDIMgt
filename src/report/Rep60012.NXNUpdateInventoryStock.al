report 60012 "NXN Update Inventory Stock"
{
    Caption = 'Update Inventory Stock';
    ProcessingOnly = true;
    UsageCategory = Administration;
    ApplicationArea = All;
    UseRequestPage = true;


    dataset
    {
        dataitem("Stockkeeping Unit"; "Stockkeeping Unit")
        {
            RequestFilterFields = "Item No.";
            trigger OnPreDataItem()
            var
            begin

            end;

            trigger OnAfterGetRecord()
            var
            begin
                CalcFields("Qty. on Purch. Order", "Qty. on Sales Order", "Qty. on Assembly Order", Inventory);
                IF "Qty. on Purch. Order" <> "NXN Purch. Order Qty" THEN
                    VALIDATE("NXN Purch. Order Qty", "Qty. on Purch. Order");
                IF "Qty. on Sales Order" <> "NXN Sales Order Qty" THEN
                    VALIDATE("NXN Sales Order Qty", "Qty. on Sales Order");
                IF "Qty. on Assembly Order" <> "NXN Assembly Order Qty" THEN
                    VALIDATE("NXN Assembly Order Qty", "Qty. on Assembly Order");
                IF Inventory <> "NXN Inventory Qty" THEN
                    VALIDATE("NXN Inventory Qty", Inventory);
                MODIFY(TRUE);
            end;

            trigger OnPostDataItem()
            var
            begin

            end;

        }
    }
}