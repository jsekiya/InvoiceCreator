public with sharing class InvoiceController {
    public Opportunity opportunity { get; set; }
    public List<OpportunityLineItem> opportunityLineItems { get; set; }
    public String opportunityCloseDate { get; set; }
    public String opportunityOrderNumber { get; set; }
    public String accountName { get; set; }
    public String billingPostalCode { get; set; }
    public String billingState { get; set; }    
    public String billingCity { get; set; }
    public String billingStreet { get; set; }
    public String bankName { get; set; }
    public String branchName { get; set; }
    public Decimal bankAccountNumber { get; set; }
    public String depositType { get; set; }
    public String bankAccountHolderName { get; set; }
    public String opportunityOwnerCompanyName { get; set; }
    public String opportunityOwnerPostalCode { get; set; }
    public String opportunityOwnerStreet { get; set; }
    public String opportunityOwnerPhone { get; set; }
    public String opportunityOwnerEmail { get; set; }
    public Decimal totalAmount { get; set; }
    public Decimal beforeTax { get; set; }
    public Decimal tenPercentAmount { get; set; }

    public InvoiceController() {
        try{
            Id oppId = ApexPages.currentPage().getParameters().get('oppId');

            opportunity = [SELECT Id, Account.Name, Amount, Account.BillingPostalCode, Account.BillingState,
                        Account.BillingCity, Account.BillingStreet, CloseDate, OrderNumber__c,
                        Owner.Email, Owner.CompanyName, Owner.Phone, Owner.Street, Owner.PostalCode,
                        BankAccount__r.BankName__c, BankAccount__r.BranchName__c, BankAccount__r.BankAccountNumber__c,
                        BankAccount__r.DepositType__c, BankAccount__r.BankAccountHolderName__c 
                        FROM Opportunity WHERE Id = :oppId LIMIT 1];
            List<OpportunityLineItem> opportunityLineItems = [SELECT ServiceDate, Name, Quantity, UnitPrice, TotalPrice FROM OpportunityLineItem WHERE OpportunityId = :oppId];

            opportunityCloseDate = opportunity.CloseDate.format();
            opportunityOrderNumber = opportunity.OrderNumber__c;
            accountName = opportunity.Account.Name;
            billingPostalCode = opportunity.Account.BillingPostalCode;
            billingState = opportunity.Account.BillingState;
            billingCity = opportunity.Account.BillingCity;
            billingStreet = opportunity.Account.BillingStreet;
            bankName = opportunity.BankAccount__r.BankName__c;
            branchName = opportunity.BankAccount__r.BranchName__c;
            bankAccountNumber = opportunity.BankAccount__r.BankAccountNumber__c;
            depositType = opportunity.BankAccount__r.DepositType__c;
            bankAccountHolderName = opportunity.BankAccount__r.BankAccountHolderName__c;
            opportunityOwnerCompanyName = opportunity.Owner.CompanyName;
            opportunityOwnerPostalCode = opportunity.Owner.PostalCode;
            opportunityOwnerStreet = opportunity.Owner.Street;
            opportunityOwnerPhone = opportunity.Owner.Phone;
            opportunityOwnerEmail = opportunity.Owner.Email;
            totalAmount = opportunity.Amount;
            beforeTax = totalAmount * 0.1;
            tenPercentAmount = totalAmount - beforeTax;    
        }catch(Exception e){
            System.debug('InvoiceController.InvoiceController() Exception: ' + e.getMessage());
        }
    }
}