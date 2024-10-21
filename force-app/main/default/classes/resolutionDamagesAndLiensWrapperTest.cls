@IsTest
public class resolutionDamagesAndLiensWrapperTest{
    @IsTest
    static void regressionTest(){
        resolutionDamagesAndLiensWrapper wrapper = new resolutionDamagesAndLiensWrapper();
        wrapper.totalLienesAmount = 00.0;
        wrapper.totalDamagesAmount = 0.0;
        wrapper.availableDamages = new List<litify_pm__Damage__c>();
        wrapper.availableLienes = new List<litify_pm__Lien__c>();
        wrapper.balanceAmount = 0.0;
        wrapper.emptyDamages = new List<litify_pm__Damage__c>();
        wrapper.emptyLienes = new List<litify_pm__Lien__c>();
        wrapper.currentResolution = new litify_pm__Resolution__c();
        wrapper.noOfPreBilled = 0.0;
        wrapper.noOfPreBilledWriteOff = 0.0;
        wrapper.noOfSelected = 0.0;
        wrapper.noOfUnSelected = 0.0;
        wrapper.noOfUnBilledWriteOff = 0.0;
        //wrapper.
    }
}