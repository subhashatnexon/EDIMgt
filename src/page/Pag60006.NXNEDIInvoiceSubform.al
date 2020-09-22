page 60006 "NXN EDI Invoice Subform"
{
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "NXN EDI Invoice Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Entry No. field';
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Line No. field';
                }
                field("Invoice Line No."; "Invoice Line No.")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Invoice Line No. field';
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Item No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Description field';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Quantity field';
                }
                field("Unit Of Measure Code"; "Unit Of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Unit Of Measure Code field';
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Unit Price field';
                }
                field("GST %"; "GST %")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the GST % field';
                }
                field(Approved; Approved)
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Approved field';
                }
                field("Duplicate Item"; "Duplicate Item")
                {
                    Editable = false;
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Duplicate Item field';
                }
                field("Manufacturer Code"; "Manufacturer Code")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Manufacturer Code field';
                }
                field(Brand; Brand)
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Brand field';
                }
                field("Size (Gm/Ml)"; "Size (Gm/Ml)")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Size (Gm/Ml) field';
                }
                field("Reason Code"; "Reason Code")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Reason Code field';
                }
                field("Reason Description"; "Reason Description")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Reason Description field';
                }
                field("Substitute Line No."; "Substitute Line No.")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Substitute Line No. field';
                }
            }
        }
    }

    actions
    {
    }
}

