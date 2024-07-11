public with sharing class InvoiceController {
    public Opportunity opportunity { get; set; }
    public List<OpportunityLineItem> opportunityLineItems { get; set; }
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
            opportunityLineItems = [SELECT ServiceDate, Name, Quantity, UnitPrice, TotalPrice FROM OpportunityLineItem WHERE OpportunityId = :oppId];

            totalAmount = opportunity.Amount;
            beforeTax = totalAmount - totalAmount * 0.1;
            tenPercentAmount = totalAmount - beforeTax;    
        }catch(Exception e){
            System.debug('InvoiceController.InvoiceController() Exception: ' + e.getMessage());
        }
    }
}