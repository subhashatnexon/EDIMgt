
// report 60011 MasterSyncJob
// {
//     UsageCategory = Administration;
//     ApplicationArea = All;
//     ProcessingOnly = true;

//     dataset
//     {
//         dataitem("NXN Master Data Sync Log"; "NXN Master Data Sync Log")
//         {
//             trigger OnPreDataItem()
//             var
//             begin
//                 SetRange("To Company Name", CompanyName);
//                 SETRANGE(Synced, FALSE);
//             end;

//             trigger OnAfterGetRecord()
//             var
//                 MasterDataSyncMgt: Codeunit "NXN Master Sync Mgt";
//             begin
//                 COMMIT;
//                 IF MasterDataSyncMgt.RUN("NXN Master Data Sync Log") THEN BEGIN
//                     Synced := TRUE;
//                     "Synced Date" := WORKDATE;
//                     "Synced Time" := TIME;
//                     "Error Occured" := FALSE;
//                     "Error Message" := '';
//                     MODIFY;
//                 END ELSE BEGIN
//                     "Error Occured" := TRUE;
//                     "Error Message" := COPYSTR(GETLASTERRORTEXT, 1, 250);
//                     MODIFY;
//                 END;

//             end;
//         }
//     }

//     requestpage
//     {
//         layout
//         {
//             area(Content)
//             {
//                 group(GroupName)
//                 {
//                 }
//             }
//         }

//         actions
//         {
//             area(processing)
//             {
//                 action(ActionName)
//                 {
//                     ApplicationArea = All;

//                 }
//             }
//         }
//     }

//     var
//         myInt: Integer;
// }