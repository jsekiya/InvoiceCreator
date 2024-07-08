import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

import { loadScript } from 'lightning/platformResourceLoader';
import JSPDF from '@salesforce/resourceUrl/jspdf';
import JSPDF_AUTOTABLE from '@salesforce/resourceUrl/jspdf_autotable';

import ACCOUNT_NAME_FIELD from '@salesforce/schema/Opportunity.Account.Name';
import AMOUNT_FIELD from '@salesforce/schema/Opportunity.Amount';
import OPPORTUNITY_CLOSE_DATE from '@salesforce/schema/Opportunity.CloseDate';
import OPPORTUNITY_ORDER_NUMBER from '@salesforce/schema/Opportunity.OrderNumber__c';
import OPPORTUNITY_OWNER_EMAIL from '@salesforce/schema/Opportunity.Owner.Email';
import OPPORTUNITY_OWNER_COMPANY_NAME from '@salesforce/schema/Opportunity.Owner.CompanyName';
import OPPORTUNITY_OWNER_PHONE from '@salesforce/schema/Opportunity.Owner.Phone';
import OPPORTUNITY_OWNER_STREET from '@salesforce/schema/Opportunity.Owner.Street';
import OPPORTUNITY_OWNER_POSTALCODE from '@salesforce/schema/Opportunity.Owner.PostalCode';
import ACCOUNT_BILLING_POSTALCODE_FIELD from '@salesforce/schema/Opportunity.Account.BillingPostalCode';
import ACCOUNT_BILLING_STATE_FIELD from '@salesforce/schema/Opportunity.Account.BillingState';
import ACCOUNT_BILLING_CITY_FIELD from '@salesforce/schema/Opportunity.Account.BillingCity';
import ACCOUNT_BILLING_STREET_FIELD from '@salesforce/schema/Opportunity.Account.BillingStreet';
import BANK_NAME_FIELD from '@salesforce/schema/Opportunity.BankAccount__r.BankName__c';
import BANK_BRANCH_NAME_FIELD from '@salesforce/schema/Opportunity.BankAccount__r.BranchName__c';
import BANK_ACCOUNT_NUMBER_FIELD from '@salesforce/schema/Opportunity.BankAccount__r.BankAccountNumber__c';
import BANK_DEPOSIT_TYPE_FIELD from '@salesforce/schema/Opportunity.BankAccount__r.DepositType__c';
import BANK_ACCOUNT_HOLDER_FIELD from '@salesforce/schema/Opportunity.BankAccount__r.BankAccountHolderName__c';

import getOpportunityLineItems from '@salesforce/apex/OpportunityLineItemController.getOpportunityLineItems';
import sendInvoiceEmail from '@salesforce/apex/EmailService.sendInvoiceEmail';

const FIELDS = [
    ACCOUNT_NAME_FIELD,
    AMOUNT_FIELD,
    ACCOUNT_BILLING_POSTALCODE_FIELD,
    ACCOUNT_BILLING_STATE_FIELD,
    ACCOUNT_BILLING_CITY_FIELD,
    ACCOUNT_BILLING_STREET_FIELD,
    OPPORTUNITY_CLOSE_DATE,
    OPPORTUNITY_ORDER_NUMBER,
    OPPORTUNITY_OWNER_EMAIL,
    OPPORTUNITY_OWNER_COMPANY_NAME,
    OPPORTUNITY_OWNER_PHONE,
    OPPORTUNITY_OWNER_STREET,
    OPPORTUNITY_OWNER_POSTALCODE,
    BANK_NAME_FIELD,
    BANK_ACCOUNT_NUMBER_FIELD,
    BANK_BRANCH_NAME_FIELD,
    BANK_DEPOSIT_TYPE_FIELD,
    BANK_ACCOUNT_HOLDER_FIELD
];

export default class Invoice extends LightningElement {
    opportunityDetails = [];
    @api recordId;
    totalAmount;
    contactName;
    billingPostalCode;
    billingState;
    billingCity;
    billingStreet;
    opportunityCloseDate;
    opportunityLineItems;
    opportunityOrderNumber;
    opportunityOwnerEmail;
    opportunityOwnerCompanyName;
    opportunityOwnerPhone;
    opportunityOwnerStreet;
    opportunityOwnerPostalCode;
    bankName;
    branchName;
    bankAccountNumber;
    depositType;
    accountHolderName;
    currentDate = new Date().toLocaleDateString();
    tenPercentAmount;
    beforeTax;

    renderedCallback(){
        loadScript(this, JSPDF)
        .then(() => loadScript(this, JSPDF_AUTOTABLE))
        .catch(error => {
            console.log('error loading script', error);
        });
    }

    generatePdf(){
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();

        //invoice header
        doc.setFont('Helvetica', 'Bold');
        doc.setFontSize(20);
        doc.text('Invoice', 14, 20);

        //Issue Date and Order Number
        doc.setFontSize(12);
        doc.text('Issue Date: ' + this.opportunityCloseDate, 14, 30);
        doc.text('Invoice Number: ' + this.opportunityOrderNumber, 14, 36);

        //Account Information
        doc.setFontSize(14);
        doc.text('To: ' + this.accountName, 14, 46);
        doc.setFontSize(12);
        doc.text('Billing Postal Code: ' + this.billingPostalCode, 14, 52);
        doc.text('Address: ' + this.billingStreet + this.billingCity + this.billingStreet, 14, 58);
        doc.text('Please find the details of the invoice below.', 14, 85);

        //total amount
        doc.setFontSize(14);
        doc.text('Total Amount (incl. tax) JPN' + this.totalAmount, 14, 92);
        
        //company Information
        doc.setFontSize(13);
        doc.text(this.opportunityOwnerCompanyName, 14, 105);
        doc.setFontSize(11);
        doc.text('Postal Code: ' + this.opportunityOwnerPostalCode, 14, 110);
        doc.text('Owner Address: ' + this.opportunityOwnerStreet, 14, 115);
        doc.text('Owner Phone: ' + this.opportunityOwnerPhone, 14, 125);
        doc.text('Owner Email: ' + this.opportunityOwnerEmail, 14, 130);
        
        //bank account information
        doc.setFontSize(14);
        doc.text('Bank Name: ' + this.bankName +' '+ this.branchName +' '+ this.bankAccountNumber, 14, 140);
        doc.text('Account Holder: ' + this.accountHolderName, 14, 146);
        
        //opportunity line items
        const headers = ["ServiceDate", "Name", "Quantity", "UnitPrice", "TotalPrice"];
        const tableData = this.opportunityLineItems.map(item => [
            item.ServiceDate || '',
            item.Name || '',
            item.Quantity || 0,
            item.UnitPrice || 0,
            item.TotalPrice || 0
        ]);
        doc.autoTable({
            head: [headers],
            body: tableData,
            startY: 160,
        });

        //total amount information
        doc.setFontSize(10);
        doc.text('Subtotal Before Tax: ' + this.beforeTax, 14, 210);
        doc.text('Tax Amount: ' + this.tenPercentAmount, 14, 214);
        doc.text('Total Amount: ' + this.totalAmount, 14, 218);
        
        //doc.save(this.accountName+".pdf");
        const pdfOutput = doc.output('blob');
        return pdfOutput;
    }

    sendEmail(){
        const pdfBlob = this.generatePdf();
        const reader = new FileReader();

        reader.onloadend = () => {
            const base64data = reader.result.split(',')[1];
            
            sendInvoiceEmail({
                recipientEmail: this.opportunityOwnerEmail,
                subject: 'Your invoice',
                body: 'Your invoice is attached.',
                attachment: base64data,
                fileName: this.accountName + '.pdf'
            })
            .then(result => {
                console.log(result);
            })
            .catch(error => {
                console.log(error);
            });
        };
        reader.readAsDataURL(pdfBlob);
    }


    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredOpportunity({ error, data }){
        if (data) {
            this.accountName = data.fields.Account.value.fields.Name.value;
            this.totalAmount = data.fields.Amount.value;
            this.billingPostalCode = data.fields.Account.value.fields.BillingPostalCode.value;
            this.billingState = data.fields.Account.value.fields.BillingState.value;
            this.billingCity = data.fields.Account.value.fields.BillingCity.value;
            this.billingStreet = data.fields.Account.value.fields.BillingStreet.value;
            this.opportunityCloseDate = data.fields.CloseDate.value;
            this.opportunityOrderNumber = data.fields.OrderNumber__c.value;
            this.opportunityOwnerEmail = data.fields.Owner.value.fields.Email.value;
            this.opportunityOwnerCompanyName = data.fields.Owner.value.fields.CompanyName.value;
            this.opportunityOwnerPhone = data.fields.Owner.value.fields.Phone.value;
            this.opportunityOwnerStreet = data.fields.Owner.value.fields.Street.value;
            this.opportunityOwnerPostalCode = data.fields.Owner.value.fields.PostalCode.value;
            this.bankName = data.fields.BankAccount__r.value.fields.BankName__c.value;
            this.bankAccountNumber = data.fields.BankAccount__r.value.fields.BankAccountNumber__c.value;
            this.branchName = data.fields.BankAccount__r.value.fields.BranchName__c.value;
            this.depositType = data.fields.BankAccount__r.value.fields.DepositType__c.value;
            this.accountHolderName = data.fields.BankAccount__r.value.fields.BankAccountHolderName__c.value;

            this.tenPercentAmount = this.calculateTenPercent(this.totalAmount);
            this.beforeTax = this.totalAmount - this.tenPercentAmount;
         
        }else if (error){
            this.error = error;
        }
    }

    @wire(getOpportunityLineItems, { recordId: '$recordId'})
    wiredOpportunityLineItems({ error, data }) {
        if (data) {
            this.opportunityLineItems = data.map(item => ({
                ServiceDate: item.ServiceDate,
                Name: item.Name,
                Quantity: item.Quantity,
                UnitPrice: item.UnitPrice,
                TotalPrice: item.TotalPrice
            }));
        } else if (error) {
            this.error = error;
        }
    }
    calculateTenPercent(amount){
        return amount ? (amount * 0.1) : 0;
    }
}
                

