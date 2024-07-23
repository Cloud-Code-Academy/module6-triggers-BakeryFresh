trigger AccountTrigger_setTypeProspect on Account (before insert, after insert) {
    
    /* I left the trigger name as differnt so I can come back and 
    review this code to fix some problems 
    */
    
    
    if(Trigger.isBefore && Trigger.isInsert){
        
        for (Account acc : Trigger.new){
         
            //testAccountTrigger_setTypeProspect
            if (acc.Type == null) {
                acc.Type = 'Prospect'; 
            }
            
            //testAccountTrigger_addressCopy, can be improved
            if (acc.ShippingState != null){ 
                acc.BillingState = acc.ShippingState;
            }
            
            if (acc.ShippingStreet != null){ 
                acc.BillingStreet = acc.ShippingStreet;
            }
            
            if (acc.ShippingState != null){ 
                acc.BillingCity = acc.ShippingCity;
            }
            
            if (acc.ShippingPostalCode != null){ 
                acc.BillingPostalCode = acc.ShippingPostalCode;
            }
                
            if (acc.ShippingCountry != null){ 
                acc.BillingCountry = acc.ShippingCountry;
            }
            

            //testAccountTrigger_setRating
            if( acc.Phone != null && acc.Website != null && acc.Fax != null) {
                acc.Rating = 'Hot';
            }

        }
    }

    if(Trigger.isAfter && Trigger.isInsert) {
        //testAccountTrigger_defaultContact
        List<Contact> defaultContList = new List<Contact>();
        for (Account acc : Trigger.new) {
            Contact cont = new Contact();
            cont.AccountId = acc.Id;
            cont.LastName = 'DefaultContact';
            cont.Email = 'default@email.com';
            defaultContList.add(cont);
        }

        insert defaultContList; //insert the list of default contacts upon insert of a new acct
    }


}