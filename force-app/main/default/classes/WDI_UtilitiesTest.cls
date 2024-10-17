@IsTest (seealldata=false)


private class WDI_UtilitiesTest {

    static testMethod void WDI_UtilitiesTest1() {
        test.starttest();
        WDI_Utilities.launchScheduleJob();
        test.stoptest();
    }
}