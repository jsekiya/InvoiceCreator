trigger GenerateInvoice on Opportunity (after update) {
    for(Opportunity opp: Trigger.new){
        if(opp.StageName == 'Closed Won' && Trigger.oldMap.get(opp.Id).StageName != 'Closed Won') {
        
            InvoiceHelper.generateAndSendInvoice(opp.Id);
        }
    }
}