codeunit 60044 "NXN Update Inventory Stock"
{
    trigger OnRun()
    begin
        //Commit();
        StockKeepingUnit.reset;
        IF StockKeepingUnit.FindFirst() then begin
            repeat
                With StockKeepingUnit do begin
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
            until StockKeepingUnit.Next = 0;
        end;

    end;

    var
        StockKeepingUnit: Record "Stockkeeping Unit";
}