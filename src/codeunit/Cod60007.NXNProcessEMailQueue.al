codeunit 60007 "NXN Process Email Queue"
{
    trigger OnRun()
    var
        EDISetup: Record "NXN EDI Setup";
        SMTPMail: Codeunit "SMTP Mail";
        TestSMTPMail: Codeunit "SMTP Test Mail";
        MessageQueue: Record "NXN E-Mail Queue";
        MessageQueue2: Record "NXN E-Mail Queue";
        SendToList: List of [Text];
        SendToCcList: List of [Text];
        SendToBccList: List of [Text];

    begin
        EDISetup.GET;
        WITH MessageQueue DO BEGIN
            RESET;
            SETRANGE(Status, Status::" ");
            IF FINDSET THEN
                REPEAT
                    CLEAR(SMTPMail);
                    IF "To Address" <> '' then
                        SendToList.Add("To Address");
                    IF "CC Address" <> '' THEN
                        SendToCcList.Add("CC Address");
                    IF "BCC Address" <> '' THEN
                        SendToBccList.Add("BCC Address");
                    SMTPMail.CreateMessage(EDISetup."Sender Name",
                                           EDISetup."Sender Email ID",
                                           SendToList,
                                           "Subject Line",
                                           "Body Line",
                                           TRUE);

                    IF SendToCcList.Count > 0 then
                        SMTPMail.AddCC(SendToCcList);
                    IF SendToBccList.Count > 0 then
                        SMTPMail.AddBCC(SendToBccList);

                    IF SMTPMail.Send() THEN BEGIN
                        MessageQueue2.GET("Entry No.");
                        MessageQueue2.Status := MessageQueue2.Status::Processed;
                        MessageQueue2.MODIFY;
                    END ELSE BEGIN
                        MessageQueue2.GET("Entry No.");
                        MessageQueue2.Status := MessageQueue2.Status::Error;
                        MessageQueue2."Error while Sending Email" := COPYSTR(SMTPMail.GetLastSendMailErrorText, 1, 250);
                        MessageQueue2.MODIFY;
                    END;
                    COMMIT;
                    SLEEP(200);
                UNTIL NEXT = 0;
        END;

    end;

    var
        myInt: Integer;
}