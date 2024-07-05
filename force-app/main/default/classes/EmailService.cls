public with sharing class EmailService {
    @AuraEnabled
    public static void sendInvoiceEmail(String recipientEmail, String subject, String body, Blob attachment, String fileName) {
        
        // Create email
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setToAddresses(new String[]{ recipientEmail });
        message.setSubject('Account summary for ' +  subject);
        message.setHtmlBody('Here\'s a summary for the account.');
        
        Blob reportPdf;
        try {
            getContentAsPDF(reportPdf);
        }
        catch (Exception e) {
            reportPdf = Blob.valueOf(e.getMessage());
        }

        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setContentType('application/pdf');
        attachment.setFileName('AccountSummary.pdf');
        attachment.setInline(false);
        attachment.setBody(body);
        message.setFileAttachments(new Messaging.EmailFileAttachment[]{ attachment });
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ message });

        ApexPages.addMessage(new 
        ApexPages.Message(ApexPages.Severity.INFO,
       'Email sent with PDF attachment to ' + this.recipientEmail));

        return null;
   
    }
}