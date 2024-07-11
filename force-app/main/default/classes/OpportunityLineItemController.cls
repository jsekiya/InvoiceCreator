//invoice lightning component`s controller
public with sharing class OpportunityLineItemController {
    @AuraEnabled(cacheable = true)
    public static List<OpportunityLineItem> getOpportunityLineItems(String recordId){
        return [SELECT Id, Quantity, Product2Id, UnitPrice, TotalPrice, OpportunityId, Name, ServiceDate 
                FROM OpportunityLineItem WHERE OpportunityId = :recordId];
    }   
}

