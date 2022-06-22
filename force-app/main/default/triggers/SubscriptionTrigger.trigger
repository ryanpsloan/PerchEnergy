trigger SubscriptionTrigger on Perch_Subscription__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    if(Trigger.isInsert){
        if(Trigger.isBefore){
            SubscriptionTriggerHandler.beforeInsert(Trigger.new);
        }else if(Trigger.isAfter){
            
        }
    }else if(Trigger.isUpdate){
        if(Trigger.isBefore){
             SubscriptionTriggerHandler.beforeUpdate(Trigger.new);
        }else if(Trigger.isAfter){
            
        }
    }else if(Trigger.isDelete){
        if(Trigger.isBefore){
            
        }else if(Trigger.isAfter){
            
        }
    }else if(Trigger.isUndelete){
        if(Trigger.isAfter){
            
        }
    }
    
}