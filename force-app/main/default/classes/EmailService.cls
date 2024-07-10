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
            email.setSubject('subject');
            email.setPlainTextBody('Your invoice is attached');

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

        List<String> lineItemIds = new List<String>();
        for (OpportunityLineItem lineItem : lineItems){
            lineItemIds.add(lineItem.Id);
        }

        String lineItemsIdsString = String.join(lineItemIds, ',');
        
        pdfPage.getParameters().put('oppId', opp.Id);
        pdfPage.getParameters().put('lineItemsIds', lineItemsIdsString);

        //generate pdf
        Blob pdfBlob = pdfPage.getContentAsPDF();
        return pdfBlob;
    }
}