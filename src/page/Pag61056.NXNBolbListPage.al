page 61056 BlobList
{
    PageType = list;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "NXN BlobList";

    layout
    {
        area(Content)
        {
            repeater(List)
            {
                field(entrynumber; entrynumber)
                {
                    ApplicationArea = all;
                    Caption = 'ID Number';
                }
                field(FileName; FileName)
                {
                    ApplicationArea = All;

                }
                field(NXNUserID; NXNUserID)
                {
                    ApplicationArea = All;
                    Caption = 'UserID';
                }
                field("NXN Company Name"; "NXN Company Name")
                {
                    ApplicationArea = All;
                    Caption = 'Company Name';
                }

            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    ListBlobCU: Codeunit "NXN List Azure Blob";
                begin
                    ListBlobCU.ListBlob('nexonblob', 'nxnblob', '45ndmc7kZaRF6Lo+eiB8Gue6vSOVsw3mwt8Rj83xbjY5mPNScZxTNTz/TgsSrJovGfdxrF6HbtpnSIzehO8FJA==', '')
                end;
            }
        }
    }

    var
        myInt: Integer;
}