public with sharing class OpportunityTriggerHandler {
    @future(callout = true)
    public static void handleClosedWonOpportunities(List<Id> opportuniyIds) {
        List<Opportunity> opportunities = [SELECT Id, Account.Name, Amount, Account.BillingPostalCode, Account.BillingState,
                            Account.BillingCity, Account.BillingStreet, CloseDate, OrderNumber__c,
                            Owner.Email, Owner.CompanyName, Owner.Phone, Owner.Street, Owner.PostalCode,
                            BankAccount__r.BankName__c, BankAccount__r.BranchName__c, BankAccount__r.BankAccountNumber__c,
                            BankAccount__r.DepositType__c, BankAccount__r.BankAccountHolderName__c 
                            FROM Opportunity WHERE Id = :opportuniyIds ];
        EmailService.sendInvoices(opportunities);
    }
}