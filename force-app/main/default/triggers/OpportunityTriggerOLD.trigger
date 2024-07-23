trigger OpportunityTriggerOLD on Opportunity (before update, before delete) {
    
    //testOpportunityTrigger_amountValidation
    if(Trigger.isBefore && Trigger.isUpdate) {
        for (Opportunity opp : Trigger.new){
            if(opp.Amount < 5000){
                opp.addError('Opportunity amount must be greater than 5000');
            }
        }
 
    }

    if(Trigger.isUpdate && Trigger.isBefore){
         //testOpportunityTrigger_setPrimaryContact
        //When an opportunity is updated set the primary contact on the opportunity 
        //to the contact on the same account with the title of 'CEO'.
        Set<Id> accIdSet = new Set<Id>();

        for (Opportunity opp : Trigger.new){
            accIdSet.add(opp.AccountId);
        }
        //used a list instead of a map?
        Map<Id, Contact> contactList = new Map<Id, Contact>([ 
                SELECT Id, FirstName, AccountId
                FROM Contact
                WHERE AccountId IN :accIdSet AND Title = 'CEO'
                //i took this from the solution
                ORDER BY FirstName ASC
            ]);

        Map<Id, Contact> accContMap = new Map<Id, Contact>();

        for (Contact cont : contactList.values()){
            //i took this ! statement from the solution, I can see why its needed, no duplicates. I originally tried to do this with a set, but it doesnt work b/c you have contactId set not an acc ID set
            if (!accContMap.containsKey(cont.AccountId)){
                accContMap.put(cont.AccountId, cont); //I already had this line
            }
        }

        for (Opportunity opp : Trigger.new){
            //assign contact to the opportunity as the primary contact
            if(opp.Primary_Contact__c == null) { //I didnt have this null check
                if (accContMap.containsKey(opp.AccountId)) {
                    opp.Primary_Contact__c = accContMap.get(opp.AccountId).Id;
                }
            }
        }
    }

    //testOpportunityTrigger_deleteCloseWonOpportunity
    if(Trigger.isBefore && Trigger.isDelete){
        
        Set<Id> accIDs = new Set<Id>(); //I needed to add a set of IDs b/c I cant pull opp.account.industry, so I need to get the IDs and SOQL the info 
        
        for (Opportunity opp : Trigger.old) {
            accIds.add(opp.AccountId);
        }

        Map<Id, Account> accMap = new Map<Id, Account>([
            SELECT Id, Industry 
            FROM Account 
            WHERE Id IN :accIds
        ]);
       
        for(Opportunity opp : Trigger.old){
            Account acc = accMap.get(opp.AccountId); //create a temp acc using the map, get the acc via the get(opp.id)
            if(opp.StageName == 'Closed Won' && acc.Industry == 'Banking'){
                opp.addError('Cannot delete closed opportunity for a banking account that is won');
            }
        }
    }

    

}