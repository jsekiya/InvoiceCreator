public with sharing class OpportunityTriggerHandler {
    @future(callout = true)
    public static void handleClosedWonOpportunities(List<Id> opportuniyIds) {
        List<Opportunity> opportunities = [SELECT Id, Account.Name, Amount, Owner.Email
                                            FROM Opportunity WHERE Id = :opportuniyIds ];
        EmailService.sendInvoices(opportunities);
    }
}