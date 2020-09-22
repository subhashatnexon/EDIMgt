page 61058 "NXN Azure Setup"
{
    Caption = 'Azure Storage Setup';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "NXN Azure Storage Setup";

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(AccountName; AccountName)
                {
                    ApplicationArea = All;
                    Caption = 'Account Name';
                }
                field(AccountContainer; AccountContainer)
                {
                    ApplicationArea = All;
                    Caption = 'Container Name';
                }
                field(AccountAccessKey; AccountAccessKey)
                {
                    ApplicationArea = All;
                    Caption = 'Access Key';
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