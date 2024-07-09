trigger OpportunityTrigger on Opportunity (after update) {
    List<Id> opportunityIdsToProcess = new List<Id>();
    for (Opportunity opp : Trigger.new){
        if (opp.StageName == 'Closed Won' && Trigger.oldMap.get(opp.Id).StageName != 'ClosedWon'){
            opportunityIdsToProcess.add(opp.Id);
        }
    }
    if (opportunityIdsToProcess.size() > 0){
        OpportunityTriggerHandler.handleClosedWonOpportunities(opportunityIdsToProcess);
    }
}