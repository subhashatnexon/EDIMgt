page 61057 "NXN DocParser List"
{
    Caption = 'DocParser List';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "NXN DocParser List";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(ParserCode; ParserCode)
                {
                    ApplicationArea = All;
                    Caption = 'Parser Code';
                }
                field(ParserID; ParserID)
                {
                    ApplicationArea = All;
                    Caption = 'Parser ID';
                    ShowMandatory = true;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                }
            }
        }
    }

    actions
    {

    }

    var
        myInt: Integer;
}