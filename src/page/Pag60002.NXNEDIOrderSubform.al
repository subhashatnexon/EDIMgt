page 60002 "NXN EDI Order Subform"
{
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "NXN EDI Order Line";
    Caption = 'Lines';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Line No."; "Line No.")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field("Item Cross Reference No."; "Item Cross Reference No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Cross Reference No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Unit Of Measure Code"; "Unit Of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Of Measure Code field';
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Price field';
                }
                field("GST %"; "GST %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the GST % field';
                    Visible = false;
                }
                field("Requested Delivery Date"; "Requested Delivery Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Requested Delivery Date field';
                    Visible = false;
                }
                field("EDI Line Comments"; "EDI Line Comments")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the EDI Line Comments field';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnDeleteRecord(): Boolean
    begin
        EDIOrderHeader.GET("Entry No.");
        IF EDIOrderHeader.Status = EDIOrderHeader.Status::"Released (Manual)" THEN
            ERROR(Text70005);

        IF EDIOrderHeader."Doc Process Status" = EDIOrderHeader."Doc Process Status"::Successful THEN
            ERROR(Text70006);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        EDIOrderHeader.GET("Entry No.");
        IF EDIOrderHeader.Status = EDIOrderHeader.Status::"Released (Manual)" THEN
            ERROR(Text70005);

        IF EDIOrderHeader."Doc Process Status" = EDIOrderHeader."Doc Process Status"::Successful THEN
            ERROR(Text70006);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        EDIOrderHeader.GET("Entry No.");
        IF EDIOrderHeader.Status = EDIOrderHeader.Status::"Released (Manual)" THEN
            ERROR(Text70005);

        IF EDIOrderHeader."Doc Process Status" = EDIOrderHeader."Doc Process Status"::Successful THEN
            ERROR(Text70006);
    end;

    var
        Text70005: Label 'Order cannot be modified. Reopen the Order to make changes.';
        EDIOrderHeader: Record "NXN EDI Order Header";
        Text70006: Label 'Order cannot be modified because Doc Process Status is Successful.';
}

