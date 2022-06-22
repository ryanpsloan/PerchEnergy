/*
 * class   : SubscriptionTriggerHandler
 * author  : Ryan Sloan
 * date    : 06/22/2022
 * ==============================================================================
 * version 1.0 Developed TriggerHandler beforeInsert and beforeUpdate Methods       
 */
public without sharing class SubscriptionTriggerHandler{

    //custom exception
    public class SubscriptionTriggerHandlerException extends Exception{}

    //Static booleans to test catch statements
    public static boolean isTestBeforeInsert = false;
    public static boolean isTestBeforeUpdate  = false;

    /*
     * date    : 06/22/22
     * author  : Ryan Sloan
     * method  : beforeInsert()
     * params  : List<Perch_Subscription__c> records
     */
    public static void beforeInsert(List<Perch_Subscription__c> records){
        try{

            //throw custom exception to cover and test catch statement
            if(isTestBeforeInsert && Test.isRunningTest()){
                throw new SubscriptionTriggerHandlerException('Test Exception');
            }

            SubscriptionUtils.determineEffectivityDateAlignment(records);     
        }catch(Exception e){
            /*
              Here I would install error tracking where we would publish an Exception_Log__e custom platform event and in it's trigger create a Process_Error__c custom object record with all exception details
              By immediately publishing an event we can still persist a Process_Error__c record to the database despite DML Rollback of the transaction.
            
              String exceptionDetails = e.getMessage() + ' | ' + e.getLineNumber() + ' | ' + e.getTypeName() + ' | ' + e.getStackTraceString() + ' | UserInfo: ' + UserInfo.getName();
              Eventbus.publish(new Exception_Log__e(Running_Process__c = 'SubscriptionTrigger', Executing_Class__c = 'SubscriptionTriggerHandler', Executing_Method__c = 'beforeInsert', Exception_Details__c = exceptionDetails)); 
            */
            
            //Want to throw the error here to stop execution and return info to user on the UI
            throw e;
        }
    }
    
    /*
     * date   : 06/22/22
     * author : Ryan Sloan
     * method : beforeUpdate()
     * params : List<Perch_Subscription__c> records
     */
    public static void beforeUpdate(List<Perch_Subscription__c> records){
        try{

            //throw custom exception to cover and test catch statement
            if(isTestBeforeUpdate && Test.isRunningTest()){
                throw new SubscriptionTriggerHandlerException('Test Exception');
            }

            SubscriptionUtils.determineEffectivityDateAlignment(records);     
        }catch(Exception e){
            /*
              Here I would install error tracking where we would publish an Exception_Log__e custom platform event and in it's trigger create a Process_Error__c custom object record with all exception details
              By immediately publishing an event we can still persist a Process_Error__c record to the database despite DML Rollback of the transaction.
            
              String exceptionDetails = e.getMessage() + ' | ' + e.getLineNumber() + ' | ' + e.getTypeName() + ' | ' + e.getStackTraceString() + ' | UserInfo: ' + UserInfo.getName();
              Eventbus.publish(new Exception_Log__e(Running_Process__c = 'SubscriptionTrigger', Executing_Class__c = 'SubscriptionTriggerHandler', Executing_Method__c = 'beforeUpdate', Exception_Details__c = exceptionDetails)); 
            */
            
            //Want to throw the error here to stop execution and return info to user on the UI
            throw e;
        }
    }     
}
