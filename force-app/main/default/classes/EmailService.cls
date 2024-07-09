public with sharing class EmailService {
    public static void sendInvoices(List<Opportunity> opportunities){
        for (Opportunity opp : opportunities){
            List<OpportunityLineItem> lineItems = [SELECT ServiceDate, Name, Quantity, UnitPrice, TotalPrice
                                                FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];

            //generate pdf blob
            
            Blob pdfBlob = EncodingUtil.base64Decode(attachment);
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
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{ attachment});

            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ email });
            System.debug('Email sent successfully.');
        }  
    }

    public static Blob generatePdfBlob(Opportunity opp, List<OpportunityLineItem> lineItems) {
        //generatepdf logic
        String pdfContent = 'Invoice for ' + opp.Account.Name;
        return Blob.valueOf(pdfContent);
    }








    /*@AuraEnabled
    public static void sendInvoiceEmail(String recipientEmail, String subject, String body, String attachment, String fileName) {
        try{
            //Create email
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setToAddresses(new String[]{ recipientEmail });
            message.setSubject(subject);
            message.setHtmlBody(body);
            
            //dekodowanie zalacznika PDF z base64
            Blob pdfBlob = EncodingUtil.base64Decode(attachment);
            Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
            emailAttachment.setFileName(fileName);
            emailAttachment.setBody(pdfBlob);
            emailAttachment.setContentType('application/pdf');
            message.setFileAttachments(new Messaging.EmailFileAttachment[]{ emailAttachment });
            
            //wysylanie email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ message });
            System.debug('Email sent successfully.');

        }catch(Exception e){
            System.debug('Error sending email: ' + e.getMessage());
            throw new AuraHandledException('exceptionText'+ e.getMessage());
        }
    }*/
}