@isTest
public class SubscriptionTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        Test.startTest();

        List<Perch_Customer__c> customerList = new List<Perch_Customer__c>();
        customerList.add(new Perch_Customer__c(Name = 'Ryan Sloan'));
        customerList.add(new Perch_Customer__c(Name = 'Jeff Martin'));
        insert customerList;

        List<Perch_Shared_System__c> systemList = new List<Perch_Shared_System__c>();
        systemList.add(new Perch_Shared_System__c(Name = 'System A'));
        systemList.add(new Perch_Shared_System__c(Name = 'System B'));
        insert systemList;

        Test.stopTest();
    }

    @isTest
    public static void determineEffectivityDateAlignmentTest_BeforeInsert(){
        Test.startTest();
        Perch_Customer__c ryan = [SELECT Id, Name FROM Perch_Customer__c WHERE Name = 'Ryan Sloan' LIMIT 1];
        Perch_Customer__c jeff = [SELECT Id, Name FROM Perch_Customer__c WHERE Name = 'Jeff Martin' LIMIT 1];

        Perch_Shared_System__c sysA = [SELECT Id, Name FROM Perch_Shared_System__c WHERE Name = 'System A' LIMIT 1];
        Perch_Shared_System__c sysB = [SELECT Id, Name FROM Perch_Shared_System__c WHERE Name = 'System B' LIMIT 1];

        /*
         * System A, Ryan
         * Should insert without issue 
         */
        Perch_Subscription__c subscription1A = new Perch_Subscription__c(
            Effectivity_Start_Date__c = Date.newInstance(2022,7,1),
            Effectivity_End_Date__c   = Date.newInstance(2023,7,1),
            Status__c                 = 'Pending',
            Perch_Customer__c         = ryan.Id,
            Perch_Shared_System__c    = sysA.Id
        );
        insert subscription1A;

        /*
         * System A, Jeff
         * Same dates and System as sub1A but different customer
         * should insert without issue
         */
        Perch_Subscription__c subscription2A = new Perch_Subscription__c(
            Effectivity_Start_Date__c = Date.newInstance(2022,7,1),
            Effectivity_End_Date__c   = Date.newInstance(2023,7,1),
            Status__c                 = 'Pending',
            Perch_Customer__c         = jeff.Id,
            Perch_Shared_System__c    = sysA.Id
        );
        insert subscription2A;

        /*
         * System B, Ryan
         * Same dates and Customer as sub1A but different system
         * should insert without issue
         */
        Perch_Subscription__c subscription1B = new Perch_Subscription__c(
            Effectivity_Start_Date__c = Date.newInstance(2022,7,1),
            Effectivity_End_Date__c   = Date.newInstance(2023,7,1),
            Status__c                 = 'Pending',
            Perch_Customer__c         = ryan.Id,
            Perch_Shared_System__c    = sysB.Id
        );
        insert subscription1B;

        /*
         * System B, Jeff
         * Same dates and Customer as sub2A but different system
         * should insert without issue
         */
        Perch_Subscription__c subscription2B = new Perch_Subscription__c(
            Effectivity_Start_Date__c = Date.newInstance(2022,7,1),
            Effectivity_End_Date__c   = Date.newInstance(2023,7,1),
            Status__c                 = 'Pending',
            Perch_Customer__c         = jeff.Id,
            Perch_Shared_System__c    = sysB.Id
        );
        insert subscription2B;

        /********* Begin Error Testing *******/
        Boolean hasError = false; //boolean to ensure that catch statement is hit and not skipped over
        try{
            /*
             * System A, Ryan
             * Start Date overlaps with Date range of sub1A
             * Should return an error 
             */
            insert new Perch_Subscription__c(
                Effectivity_Start_Date__c = Date.newInstance(2022,8,1),
                Effectivity_End_Date__c   = Date.newInstance(2023,8,1),
                Status__c                 = 'Pending',
                Perch_Customer__c         = ryan.Id,
                Perch_Shared_System__c    = sysA.Id
            );


        }catch(Exception e){
            System.assertEquals(true, e.getMessage().contains('The Effectivity Dates of the Subscription being created fall within the range of Effectivity Dates for another existing Subscription. Please check the dates and try again.'));
            hasError = true;
        }

        System.assertEquals(true, hasError);

        hasError = false; 
        try{
            /*
             * System A, Ryan
             * End Date overlaps with Date range of sub1A
             * Should return an error 
             */
            insert new Perch_Subscription__c(
                Effectivity_Start_Date__c = Date.newInstance(2022,6,1),
                Effectivity_End_Date__c   = Date.newInstance(2023,6,1),
                Status__c                 = 'Pending',
                Perch_Customer__c         = ryan.Id,
                Perch_Shared_System__c    = sysA.Id
            );


        }catch(Exception e){
            System.assertEquals(true, e.getMessage().contains('The Effectivity Dates of the Subscription being created fall within the range of Effectivity Dates for another existing Subscription. Please check the dates and try again.'));
            hasError = true;
        }

        System.assertEquals(true, hasError);

        Test.stopTest();
    }

    @isTest
    public static void determineEffectivityDateAlignmentTest_BeforeUpdate(){
        Test.startTest();
        Perch_Customer__c ryan = [SELECT Id, Name FROM Perch_Customer__c WHERE Name = 'Ryan Sloan' LIMIT 1];
        Perch_Customer__c jeff = [SELECT Id, Name FROM Perch_Customer__c WHERE Name = 'Jeff Martin' LIMIT 1];

        Perch_Shared_System__c sysA = [SELECT Id, Name FROM Perch_Shared_System__c WHERE Name = 'System A' LIMIT 1];
        Perch_Shared_System__c sysB = [SELECT Id, Name FROM Perch_Shared_System__c WHERE Name = 'System B' LIMIT 1];

        /*
         * System A, Ryan
         * Should insert without issue 
         */
        Perch_Subscription__c subscription1A = new Perch_Subscription__c(
            Effectivity_Start_Date__c = Date.newInstance(2022,7,1),
            Effectivity_End_Date__c   = Date.newInstance(2022,7,31),
            Status__c                 = 'Pending',
            Perch_Customer__c         = ryan.Id,
            Perch_Shared_System__c    = sysA.Id
        );
        insert subscription1A;

        /*
         * System A, Ryan
         * Same System and Customer as sub1A but different dates
         * should insert without issue
         */
        Perch_Subscription__c subscription1B = new Perch_Subscription__c(
            Effectivity_Start_Date__c = Date.newInstance(2022,8,1),
            Effectivity_End_Date__c   = Date.newInstance(2022,8,31),
            Status__c                 = 'Pending',
            Perch_Customer__c         = ryan.Id,
            Perch_Shared_System__c    = sysA.Id
        );
        insert subscription1B;

        /********* Begin Error Testing *******/
        Boolean hasError = false; //boolean to ensure that catch statement is hit and not skipped over
        try{
            /*
             * System A, Ryan
             * Start Date overlaps with Date range of sub1A
             * Should return an error 
             */
            subscription1A.Effectivity_Start_Date__c = Date.newInstance(2022,8,10);
            update subscription1A;

        }catch(Exception e){
            System.assertEquals(true, e.getMessage().contains('The Effectivity Dates of the Subscription being created fall within the range of Effectivity Dates for another existing Subscription. Please check the dates and try again.'));
            hasError = true;
        }

        System.assertEquals(true, hasError);

        hasError = false; 
        try{
            /*
             * System A, Ryan
             * End Date overlaps with Date range of sub1A
             * Should return an error 
             */
            
            subscription1A.Effectivity_End_Date__c = Date.newInstance(2022,8,20);
            update subscription1A;   

        }catch(Exception e){
            System.assertEquals(true, e.getMessage().contains('The Effectivity Dates of the Subscription being created fall within the range of Effectivity Dates for another existing Subscription. Please check the dates and try again.'));
            hasError = true;
        }

        System.assertEquals(true, hasError);

        hasError = false; 
        try{
            /*
             * System A, Ryan
             * End Date overlaps with Date range of sub1A
             * Should return an error 
             */
            subscription1A.Effectivity_Start_Date__c = Date.newInstance(2022,8,1);
            subscription1A.Effectivity_End_Date__c = Date.newInstance(2022,8,31);
            update subscription1A;   

        }catch(Exception e){
            System.assertEquals(true, e.getMessage().contains('The Effectivity Dates of the Subscription being created fall within the range of Effectivity Dates for another existing Subscription. Please check the dates and try again.'));
            hasError = true;
        }

        System.assertEquals(true, hasError);
        Test.stopTest();
    }

    @isTest
    public static void determineEffectivityDateAlignmentTest_CoverCatchStatement(){
        Test.startTest();

        Perch_Customer__c ryan = [SELECT Id, Name FROM Perch_Customer__c WHERE Name = 'Ryan Sloan' LIMIT 1];

        Perch_Shared_System__c sysA = [SELECT Id, Name FROM Perch_Shared_System__c WHERE Name = 'System A' LIMIT 1];

        Perch_Subscription__c subscription1A = new Perch_Subscription__c(
            Effectivity_Start_Date__c = Date.newInstance(2022,7,1),
            Effectivity_End_Date__c   = Date.newInstance(2022,7,31),
            Status__c                 = 'Pending',
            Perch_Customer__c         = ryan.Id,
            Perch_Shared_System__c    = sysA.Id
        );

        SubscriptionTriggerHandler.isTestBeforeInsert = true;
        Boolean hasError = false;
        try{
            insert subscription1A;
        }catch(Exception e){
            System.assertEquals(true, e.getMessage().contains('Test Exception'));
            hasError = true;
        }

        System.assertEquals(true, hasError);

        SubscriptionTriggerHandler.isTestBeforeInsert = false;
        SubscriptionUtils.testCatch = true;
        hasError = false;
        try{
            insert subscription1A;
        }catch(Exception e){
            System.assertEquals(true, e.getMessage().contains('Test Exception'));
            hasError = true;
        }

        System.assertEquals(true, hasError);

        SubscriptionUtils.testCatch = false;
        insert subscription1A;

        SubscriptionTriggerHandler.isTestBeforeUpdate = true;
        hasError = false;
        try{
            update subscription1A;
        }catch(Exception e){
            System.assertEquals(true, e.getMessage().contains('Test Exception'));
            hasError = true;
        }

        System.assertEquals(true, hasError);

        Test.stopTest();
    }
}
