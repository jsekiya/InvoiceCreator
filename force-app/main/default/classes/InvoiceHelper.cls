public with sharing class InvoiceHelper {
    @future(callout = true)
    public static void generateAndSendInvoice(Id oppId) {
        /*Opportunity opp = [SELECT Id, Name, Amount, Account.Email__c FROM Opportunity WHERE Id = :oppId LIMIT 1];
        //generowanie linku do faktury
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        String invoicePageUrl = baseUrl + '/lightning/cmp/c__invoice?recordId=' + opp.Id;
        PageReference pdfPage = new PageReference(invoicePageUrl);
        Blob pdfBlob = pdfPage.getContentAsPDF();

        //tworzenie zalacznika
        Attachment att = new Attachment();
        att.ParentId = opp.Id;
        att.Name = '請求書_' + opp.Name + '.pdf';
        att.Body = pdfBlob;
        insert att;

        //wysylanie emaila
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[]{opp.Account.Email__c});
        mail.setSubject('請求書' + opp.Name);
        mail.setPlainTextBody('');


        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(att.Name);
        efa.setBody(att.Body);

        mail.setFileAttachments(new Messaging.EmailFileAttachment[]{
            efa
        });
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
            mail
        });*/
    }
}