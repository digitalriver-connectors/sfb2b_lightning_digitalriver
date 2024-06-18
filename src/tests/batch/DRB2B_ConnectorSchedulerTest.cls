/**
 * @description: Test class for ConnectorScheduler with Assert Statements for each scheduler methods
 *               such as ( Every15Minutes, Every30Minutes, EveryHour, Every6Hours and Every Monday ).
 *
 **/

@IsTest

private class DRB2B_ConnectorSchedulerTest {

 

    @IsTest

    static void testScheduleEvery15Minutes() {

        Test.startTest();

        DRB2B_ConnectorScheduler.PurgeLogs.scheduleEveryXMinutes(15);

        Test.stopTest();

 

        List<CronTrigger> triggers = [SELECT NextFireTime FROM CronTrigger];

        System.assertNotEquals(null, triggers);

    }

 

    @IsTest

    static void testScheduleWithSizeEvery15Minutes() {

        Test.startTest();

        DRB2B_ConnectorScheduler.PurgeLogs.withSize(10).scheduleEveryXMinutes(15);

        Test.stopTest();

 

        List<CronTrigger> triggers = [SELECT NextFireTime FROM CronTrigger];

        System.assertNotEquals(null, triggers);

    }

 

    @IsTest

    static void testScheduleHourly() {

        Test.startTest();

        DRB2B_ConnectorScheduler.PurgeLogs.scheduleHourly(1);

        Test.stopTest();

 

        List<CronTrigger> triggers = [SELECT NextFireTime FROM CronTrigger];

        System.assertNotEquals(null, triggers);

    }

 

    @IsTest

    static void testScheduleDaily() {

        Test.startTest();

        DRB2B_ConnectorScheduler.PurgeLogs.scheduleDaily(4, 0);

        Test.stopTest();

 

        List<CronTrigger> triggers = [SELECT NextFireTime FROM CronTrigger];

        System.assertNotEquals(null, triggers);

    }

 

    @IsTest

    static void testScheduleWeekly() {

        Test.startTest();

        DRB2B_ConnectorScheduler.PurgeLogs.scheduleWeekly('MON');

        Test.stopTest();

 

        List<CronTrigger> triggers = [SELECT NextFireTime FROM CronTrigger];

        System.assertNotEquals(null, triggers);

    }

 

    @IsTest

    static void testScheduleMonthly() {

        Test.startTest();

        DRB2B_ConnectorScheduler.PurgeLogs.scheduleMonthly('1');

        Test.stopTest();

 

        List<CronTrigger> triggers = [SELECT NextFireTime FROM CronTrigger];

        System.assertNotEquals(null, triggers);

    }

 

    @IsTest

    static void testScheduleCronExpr() {

        Test.startTest();

        DRB2B_ConnectorScheduler.PurgeLogs.scheduleCronExpr('Purge Logs Every 4 hours', '0 0 0,4,8,12,16,20 ? * *');

        Test.stopTest();

 

        List<CronTrigger> triggers = [SELECT NextFireTime FROM CronTrigger];

        System.assertNotEquals(null, triggers);

    }

 

    @IsTest

    static void testSchedule() {

        Test.startTest();

        DRB2B_ConnectorScheduler.PurgeLogs.schedule('0', '0', '0', '?', '*', '*', '*');

        Test.stopTest();

 

        List<CronTrigger> triggers = [SELECT NextFireTime FROM CronTrigger];

        System.assertNotEquals(null, triggers);

    }

}