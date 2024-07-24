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
            email.setSubject('請求書 - ' + opp.Account.Name);
            email.setPlainTextBody(
                opp.Account.Name + ' 御中、\n\n' +

                'こちらの請求書はご参考用です。以下のPDFファイルをクリックして請求書をご覧ください。\n\n' +
                '平素より大変お世話になっております。\n\n'+
                'この度は、請求書をお送りいたします。\n\n' +
                '以下のPDFファイルをクリックして請求書をご覧ください。\n\n' +
                '請求書の内容をご確認の上、ご不明な点がございましたらご連絡ください。\n\n' +
                '何卒よろしくお願い申し上げます。\n\n' +
                '----\n'+

                opp.Owner.Name + '\n' +
                opp.Owner.CompanyName
            );

            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setContentType('application/pdf');
            attachment.setFileName(opp.Account.Name + '.pdf');
            attachment.setBody(pdfBlob);
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{ attachment });

            //Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ email });
            System.debug('Email sent successfully.');

            savePdfAsContentVersion(opp, pdfBLob);
        }  
    }

    public static Blob generatePdfBlob(Opportunity opp, List<OpportunityLineItem> lineItems) {
        //generatepdf logic
        PageReference pdfPage = Page.InvoicePage;
        pdfPage.getParameters().put('oppId', opp.Id);
        Blob pdfBlob = pdfPage.getContentAsPDF();
        return pdfBlob;
    }

    public static void savePdfAsContentVersion(Opportunity opp, Blob pdfBlob) {
        ContentVersion contentVersion = new ContentVersion();
        
        contentVersion.Title = opp.Account.Name + '-請求書';
        contentVersion.PathOnClient = opp.Account.Name + '.pdf';
        contentVersion.VersionData = pdfBlob;
        contentVersion.FirstPublishLocationId = opp.Id;
        insert contentVersion;
    }
}