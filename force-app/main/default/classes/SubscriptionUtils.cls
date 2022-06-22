/*
 * class   : SubscriptionUtils
 * author  : Ryan Sloan
 * date    : 06/22/2022
 * ==============================================================================================
 * version 1.0 : Developed Class and determineEffectivityDateAlignment() method           
 */

//want without sharing here to ensure that queries inside methods returns all subscriptions to evaluate against
public without sharing class SubscriptionUtils {

    //custom exception
    public class SubscriptionUtilsException extends Exception{} 
    //boolean used in testing
    public static Boolean testCatch = false;
    
    /*
     * date   : 06/22/22
     * author : Ryan Sloan
     * method : determineEffectivityDateAlignment()
     * params : List<Perch_Subscription__c> records
     * context: Before Insert and Before Update, called by SubscriptionTriggerHandler 
     * This method will determine if the dates for Effectivity Start or End fall
     * within the same range on an existing Subscription
     */

    public static void determineEffectivityDateAlignment(List<Perch_Subscription__c> records){
        
        try{

            //Throw custom exception to cover and test catch statement
            if(testCatch && Test.isRunningTest()){
                throw new SubscriptionUtilsException('Test Exception');
            }

            //Sets to collect relevant Ids
            Set<Id> systemIdSet = new Set<Id>();
            Set<Id> customerIdSet = new Set<Id>();
            Set<Id> processedRecordIdSet = new Set<Id>();
            
            //Collect the Ids for the System and Customer
            for(Perch_Subscription__c ps : records){
                processedRecordIdSet.add(ps.Id);
                systemIdSet.add(ps.Perch_Shared_System__c); //will be present and not null because it is required upon insert at the object level to create a record
                customerIdSet.add(ps.Perch_Customer__c);    //this will exist because of Master Detail relationship which requires it on insert
            }
            
            //Query Subscriptions by System and Customer, exclude the records currently being processed
            List<Perch_Subscription__c> subscriptionListBySystemAndCustomer = [SELECT Id, Name, Effectivity_Start_Date__c, Effectivity_End_Date__c, 
                                                                                    Perch_Shared_System__r.Name, Perch_Customer__r.Name 
                                                                               FROM Perch_Subscription__c 
                                                                               WHERE Perch_Shared_System__c IN: systemIdSet 
                                                                               AND Perch_Customer__c IN: customerIdSet
                                                                               //exclude the records being processed to avoid matching against itself
                                                                               AND (NOT Id IN: processedRecordIdSet)];
            System.debug(subscriptionListBySystemAndCustomer.size());

            //If no other subscriptions that meet criteria are present, skip the logic below
            if(subscriptionListBySystemAndCustomer.size() > 0){
            
                //Iterate over processed subscription records
                for(Perch_Subscription__c subscription : records){
                    System.debug(subscription);

                    //Iterate over queried subscriptions that met criteria 
                    for(Perch_Subscription__c sub : subscriptionListBySystemAndCustomer){
                        System.debug(sub);

                        //Perform the check to determine if the effectivity start or end dates fall with the range of any of the
                        //other queried subscriptions
                        if((subscription.Effectivity_Start_Date__c >= sub.Effectivity_Start_Date__c 
                            && subscription.Effectivity_Start_Date__c < sub.Effectivity_End_Date__c) 
                        ||
                            (subscription.Effectivity_End_Date__c > sub.Effectivity_Start_Date__c 
                            && subscription.Effectivity_End_Date__c <= sub.Effectivity_End_Date__c)){
                                //Add error to processed record and stop execution of the dml if processed record dates fall within range of another subscription
                                subscription.addError('The Effectivity Dates of the Subscription being created fall within the range of Effectivity Dates for another existing Subscription. Please check the dates and try again.');
                        }
                    }
                }
            }
        }catch(Exception e){
            //Here I would install error tracking where we would publish an Exception_Log__e custom platform event and in it's trigger create a Process_Error__c custom object record with all exception details
            //By immediately publishing an event we can still persist a Process_Error__c record to the database despite DML Rollback of the transaction.
            
            //String exceptionDetails = e.getMessage() + ' | ' + e.getLineNumber() + ' | ' + e.getTypeName() + ' | ' + e.getStackTraceString() + ' | UserInfo: ' + UserInfo.getName();
            //Eventbus.publish(new Exception_Log__e(Running_Process__c = 'SubscriptionTrigger', Executing_Class__c = 'SubscriptionUtils', Executing_Method__c = 'determineEffectivityDateAlignment', Exception_Details__c = exceptionDetails)); 
            
            //Want to throw the error here to stop execution and return info to user on the UI          
            throw e;
        }
    }
}
