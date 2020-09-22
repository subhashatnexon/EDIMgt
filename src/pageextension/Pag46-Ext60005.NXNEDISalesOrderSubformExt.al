pageextension 60005 "NXN EDISales Order Subform Ext" extends "Sales Order Subform" //46
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
    }
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
    begin
        IF SalesHeader.get(Rec."Document Type", Rec."Document No.") then begin
            IF (SalesHeader."Bill-to IC Partner Code" <> '') AND (SalesHeader."NXN IC SRC Order No." <> '') then
                Error(ICInsertErr);
        end;
    end;

    trigger OnDeleteRecord(): Boolean
    var
    begin
        IF SalesHeader.get(Rec."Document Type", Rec."Document No.") then begin
            IF (SalesHeader."Bill-to IC Partner Code" <> '') AND (SalesHeader."NXN IC SRC Order No." <> '') then
                Error(ICDeleteErr);
        end;

    end;

    var
        SalesHeader: Record "Sales Header";
        ICInsertErr: Label 'You can not insert the line as it is intercompany order';
        ICDeleteErr: Label 'You can not delete the line as it is intercompany order';
}