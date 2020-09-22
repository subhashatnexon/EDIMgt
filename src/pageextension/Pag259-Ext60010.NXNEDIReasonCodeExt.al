pageextension 60010 "NXN EDIReasonCodes Ext" extends "Reason Codes" //259
{
    layout
    {
        // Add changes to page layout here
        addafter(Description)
        {

            field("NXN Allow Auto Posting"; "NXN Allow Auto Posting")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Allow Auto Posting field';
            }
            field("NXN Use WorkDate As PostDate"; "NXN Use WorkDate As PostDate")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Use WorkDate As PostDate field';
            }
        }

    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}