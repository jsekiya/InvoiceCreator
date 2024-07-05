public with sharing class EmailService {
    @AuraEnabled
    public static void sendInvoiceEmail(String recipientEmail, String subject, String body, Blob attachment, String fileName) {
        try{
            // Create email
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setToAddresses(new String[]{ recipientEmail });
            message.setSubject(subject);
            message.setHtmlBody(body);
            
            //dekodowanie zalacznika PDF z base64
            Blob pdfBlob = EncodingUtil.base64Decode(attachment);
            Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
            emailAttachment.setFileName('AccountSummary.pdf');
            emailAttachment.setBody(attachment);
            emailAttachment.setContentType(fileName);
            message.setFileAttachments(new Messaging.EmailFileAttachment[]{ emailAttachment });
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ message });
            System.debug('Email sent successfully.');
        }catch(Exception e){
            System.debug('Error sending email: ' + e.getMessage());
            throw new AuraHandledException('exceptionText'+ e.getMessage());
        }
    }
}