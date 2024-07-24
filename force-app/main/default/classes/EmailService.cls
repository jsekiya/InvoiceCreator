public with sharing class EmailService {
    public static void sendInvoices(List<Opportunity> opportunities){
        for (Opportunity opp : opportunities){
            List<OpportunityLineItem> lineItems = [SELECT ServiceDate, Name, Quantity, UnitPrice, TotalPrice
                                                FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];

            //generate pdf blob
            Blob pdfBlob = generatePdfBlob(opp, lineItems);
            //create email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[]{ opp.Owner.Email });
            email.setSubject('Invoice - ' + opp.Account.Name);
            email.setPlainTextBody(
                'Dear ' + opp.Account.Name + ',\n\n' +
                'This invoice is for your reference. You can view the invoice by ' +
                'clicking the pdf file below.\n\n' +
                'Best Regards' + '\n' +
                opp.Owner.Name + '\n' +
                opp.Owner.CompanyName
            );

            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setContentType('application/pdf');
            attachment.setFileName(opp.Account.Name + '.pdf');
            attachment.setBody(pdfBlob);
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{ attachment });

            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ email });
            System.debug('Email sent successfully.');
        }  
    }

    public static Blob generatePdfBlob(Opportunity opp, List<OpportunityLineItem> lineItems) {
        //generatepdf logic
        PageReference pdfPage = Page.InvoicePage;
        pdfPage.getParameters().put('oppId', opp.Id);
        Blob pdfBlob = pdfPage.getContentAsPDF();
        return pdfBlob;
    }
}