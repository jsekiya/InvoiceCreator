import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

import { loadScript } from 'lightning/platformResourceLoader';
import JSPDF from '@salesforce/resourceUrl/jspdf';

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
    headers = this.createHeaders([
        "Id",
        "Product Name",
        "Quantity"
    ]);
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
        Promise.all(values, [
            loadScript(this, JSPDF)
        ]);
    }

    generatePdf(){
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF({
            encryption: {
                userPassword: "user",
                ownerPassword: "owner",
                userPermissions: ["print", "modify", "copy", "annot-forms"]
            }
        });
        doc.text("test", 28, 28);
        doc.table(30, 30, this.opportunityDetails, this.headers, { autosize:true });
        doc.save("demo.pdf");
    }

    createHeaders(keys){
        let result = [];
        for (let i = 0; i<keys.length; i += 1){
            result.push({
                id: keys[i],
                name: keys[i],
                prompt : keys[i],
                width: 65,
                align: "center",
                padding: 0
            });
        }
        return result;
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

            this.generatePdf();
            return data;
        }else if (error){
            this.error = error;
        }
    }

    @wire(getOpportunityLineItems, { recordId: '$recordId'})
    wiredOpportunityLineItems({ error, data }) {
        if (data) {
            this.opportunityLineItems = data;
        } else if (error) {
            this.error = error;
        }
    }
    calculateTenPercent(amount){
        return amount ? (amount * 0.1) : 0;
    }
}
                

