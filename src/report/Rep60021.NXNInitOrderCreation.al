report 60021 "Init Document Creation"
{
    Caption = 'Execute Document Creation process';
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Integer; Integer)
        {
            DataItemTableView = SORTING(Number) ORDER(Ascending) WHERE(Number = CONST(1));
            trigger OnAfterGetRecord()
            var
                DocreationProcess: codeunit "NXN Start Doc Creation Process";
            begin
                Commit();
                IF DocreationProcess.RUN then;
            end;
        }
    }

}