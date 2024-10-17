/*
Author: Cmentor/Neelesh
Description : CDBatchPrintCheckExt
Date        : 09-01-2020

Updated by  : Cmentor/Sampath Suranji
Date        : 09-08-2020
Description : fix issues
*/
public class CDBatchPrintCheckExt {
    public AcctSeed__Cash_Disbursement_Batch__c objCashDisbursementBatch {get; set;}

    public Map<String, list<AcctSeed__AP_Disbursement__c>> mapCDAndAPDisbursement {get; set;}
    public Map<String, list<AcctSeed__AP_Disbursement__c>> mapCDAndAPDisbursementTen {get; set;}
    public Map<String, list<AcctSeed__AP_Disbursement__c>> mapCDAndAPDisbursementOperationgTen {get; set;}
    public Map<String, AcctSeed__Cash_Disbursement__c> mapCDRecord {get; set;}
    public Map<String, String> mapCDAndTotal {get; set;}
    public Map<String, String> mapPayableWithMatter {get; set;}
    public Map<String, String> mapPayableWithClient {get; set;}
    public Map<String, String> mapPayableWithAlias {get; set;}
    public Boolean MapCheck {get; set;}

    public list<AcctSeed__Cash_Disbursement__c> listCashDisbursement {get; set;}
    public list<AcctSeed__Cash_Disbursement__c> listCashDisbursementFiltered {get; set;}
    
    public map<Id, Account> mapPayableIdVendor {get; set;}
    public AcctSeed__Cash_Disbursement__c objCD {get; set;}
    public String LayoutType {get; set;}
    public String Memo {get; set;}
    public Date TodayDate {get; set;}
    public map<String, AcctSeed__AP_Disbursement__c> alternatePayeeMap {get; set;}

    public CDBatchPrintCheckExt(ApexPages.StandardController stdController) {
        try{
            this.objCashDisbursementBatch = (AcctSeed__Cash_Disbursement_Batch__c)stdController.getRecord();
            MapCheck = false;

            mapCDRecord = new Map<String, AcctSeed__Cash_Disbursement__c>();
            mapCDAndAPDisbursement = new Map<String, list<AcctSeed__AP_Disbursement__c>>();
            mapCDAndAPDisbursementTen = new Map<String, list<AcctSeed__AP_Disbursement__c>>();
            mapCDAndAPDisbursementOperationgTen = new Map<String, list<AcctSeed__AP_Disbursement__c>>();
            mapCDAndTotal = new Map<String, String>();
            mapPayableWithMatter= new Map<String, String>();
            mapPayableWithClient = new Map<String, String>();
            mapPayableWithAlias = new Map<String, String>();
            listCashDisbursementFiltered = new list<AcctSeed__Cash_Disbursement__c>();
            set<id>setPayableIds = new set<id>();
            alternatePayeeMap = new  map<String, AcctSeed__AP_Disbursement__c>();
            LayoutType = '';

            TodayDate = date.today();

            listCashDisbursement = [select id, Name, AcctSeed__Bank_Account__c, AcctSeed__Bank_Account__r.Name,Check__c,AcctSeed__Check_Number__c, 
                                    AcctSeed__Vendor__c, AcctSeed__Vendor__r.Name, AcctSeed__Vendor__r.BillingStreet, AcctSeed__Amount__c,
                                    AcctSeed__Vendor__r.BillingAddress,AcctSeed__Vendor__r.BillingCity, AcctSeed__Vendor__r.BillingState, AcctSeed__Vendor__r.BillingPostalCode,
                                    (select id, name, AcctSeed__Account_Payable__c, AcctSeed__Account_Payable__r.name,
                                     AcctSeed__Account_Payable__r.AcctSeed__Payee_Reference__c,
                                     AcctSeed__Account_Payable__r.AcctSeed__Vendor__c,
                                     AcctSeed__Account_Payable__r.AcctSeed__Vendor__r.Name,
                                     AcctSeed__Account_Payable__r.Resolution__r.Alternate_Payee_Reason__c,
                                     AcctSeed__Account_Payable__r.Alternate_Payee__c,
                                     AcctSeed__Account_Payable__r.Resolution__r.litify_pm__Matter__r.Name,
                                     AcctSeed__Account_Payable__r.Resolution__r.litify_pm__Matter__r.litify_pm__Client__r.Name,
                                     AcctSeed__Account_Payable__r.Resolution__r.litify_pm__Matter__r.litify_pm__Principal_Attorney__r.Alias,
                                      AcctSeed__Account_Payable__r.Resolution__r.litify_pm__Matter__r.Claims_User__r.Alias,
                                     AcctSeed__Account_Payable__r.Damage__r.Party_Name__c,
                                     AcctSeed__Account_Payable__r.Damage__r.Account__c,
                                     AcctSeed__Account_Payable__r.Damage__r.litify_pm__Invoice__c,
                                     AcctSeed__Account_Payable__r.Damage__c,
                                     AcctSeed__Account_Payable__r.Lien__c,
                                     AcctSeed__Account_Payable__r.Damage_Lien_Account__c,
                                     AcctSeed__Account_Payable__r.Damage_Lien_Invoice__c,
                                     AcctSeed__Account_Payable__r.Lien__r.Account__c,
                                     AcctSeed__Account_Payable__r.Lien__r.litify_pm__lit_Invoice__c,AcctSeed__Account_Payable__r.Origin__c,
                                     AcctSeed__Paid_Amount__c
                                     from AcctSeed__Account_Payable_Cash_Disbursements__r)
                                    from AcctSeed__Cash_Disbursement__c where AcctSeed__Cash_Disbursement_Batch__c =: objCashDisbursementBatch.Id
                                    order by CreatedDate ASC];

            if(listCashDisbursement.size() != 0){

                for(AcctSeed__Cash_Disbursement__c objCD : listCashDisbursement){
                    if(objCD.AcctSeed__Bank_Account__r.Name == '1000-Cash - Operating' ||
                       objCD.AcctSeed__Bank_Account__r.Name == '1050-Cash - Case Costs' ||
                       objCD.AcctSeed__Bank_Account__r.Name == '1020-Cash - Trust'){

                           for(AcctSeed__AP_Disbursement__c objAPD: objCD.AcctSeed__Account_Payable_Cash_Disbursements__r){
                               setPayableIds.add(objAPD.AcctSeed__Account_Payable__c);
                               alternatePayeeMap.put(objCD.Id,objAPD);
                           }
                           mapCDAndAPDisbursement.put(objCD.Id, objCD.AcctSeed__Account_Payable_Cash_Disbursements__r);
                           mapCDRecord.put(objCD.Id,objCD);

                           list<AcctSeed__AP_Disbursement__c> lstPayable = new list<AcctSeed__AP_Disbursement__c>();
                           list<AcctSeed__AP_Disbursement__c> lstOpPayable = new list<AcctSeed__AP_Disbursement__c>();

                           Integer Counter = 1;

                           for(AcctSeed__AP_Disbursement__c obj : objCD.AcctSeed__Account_Payable_Cash_Disbursements__r){
                               /*if(Counter <= 4){
                                   lstPayable.add(obj);
                               }*/
                               if(Counter <= 8){
                                   lstOpPayable.add(obj);
                                   lstPayable.add(obj);
                               }
                               Counter++;
                           }

                           mapCDAndAPDisbursementTen.put(objCD.Id,lstPayable);
                           mapCDAndAPDisbursementOperationgTen.put(objCD.Id,lstOpPayable);

                           Integer DecimalValue = Integer.valueOf((objCD.AcctSeed__Amount__c - math.floor(objCD.AcctSeed__Amount__c)) * 100);
                           String NumberInWords = '';
                           if(DecimalValue == 0){
                               Integer TotalInWord = Integer.valueOf(objCD.AcctSeed__Amount__c);
                               NumberInWords = AnountInWords(TotalInWord) + ' And 00/100 Dollars';
                           }else{
                               if(objCD.AcctSeed__Amount__c >= 1){
                                   Integer TotalInWord = Integer.valueOf(objCD.AcctSeed__Amount__c);
                                   NumberInWords = AnountInWords(TotalInWord)+' And '+DecimalValue+'/100 Dollars';
                               }else{
                                   NumberInWords = 'Zero And '+DecimalValue+'/100 Dollars';
                               }
                           }

                           mapCDAndTotal.put(objCD.Id,NumberInWords);
                           listCashDisbursementFiltered.add(objCD);

                       }
                }

                if(listCashDisbursementFiltered.size() != 0){
                    MapCheck = True;
                    /*
                    DPW can add check Layout for CCA here if needed:
                        '1000-Cash - Operating' ||
                        '1050-Cash - Case Costs' ||
                        '1020-Cash - Trust'
                    */
                    if(listCashDisbursementFiltered[0].AcctSeed__Bank_Account__r.Name == '1000-Cash - Operating'){
                        LayoutType = 'Operating';
                    }else if(listCashDisbursementFiltered[0].AcctSeed__Bank_Account__r.Name == '1050-Cash - Case Costs'){
                        LayoutType = 'Trust';
                    }else{
                        LayoutType = 'Trust';
                    }
                }

                if(setPayableIds.size()>0){
                    for(AcctSeed__Account_Payable_Line__c objPayLine:[select id,AcctSeed__Account_Payable__c,AcctSeed__Project__r.Matter__r.Name,AcctSeed__Project__r.Matter__r.litify_pm__Client__r.Name, AcctSeed__Project__r.Matter__r.litify_pm__Principal_Attorney__r.Alias,AcctSeed__Project__r.Matter__r.Claims_User__r.Alias  from AcctSeed__Account_Payable_Line__c where AcctSeed__Account_Payable__c in: setPayableIds]){
                        mapPayableWithMatter.put(objPayLine.AcctSeed__Account_Payable__c,objPayLine.AcctSeed__Project__r.Matter__r.Name);
                        mapPayableWithClient.put(objPayLine.AcctSeed__Account_Payable__c,objPayLine.AcctSeed__Project__r.Matter__r.litify_pm__Client__r.Name);
                        if(objPayLine.AcctSeed__Project__r.Matter__r.litify_pm__Principal_Attorney__c!=null){
                             mapPayableWithAlias.put(objPayLine.AcctSeed__Account_Payable__c, objPayLine.AcctSeed__Project__r.Matter__r.litify_pm__Principal_Attorney__r.Alias);
                        }else if(objPayLine.AcctSeed__Project__r.Matter__r.Claims_User__c!=null){
                             mapPayableWithAlias.put(objPayLine.AcctSeed__Account_Payable__c, objPayLine.AcctSeed__Project__r.Matter__r.Claims_User__r.Alias);
                        }else{
                             mapPayableWithAlias.put(objPayLine.AcctSeed__Account_Payable__c,'');
                        }

                    }
                }
            }
        }
        catch(Exception ex){}


    }

    public string AnountInWords(Integer Amount){
        if(Amount == 1)
            return 'One';
        if(Amount == 2)
            return 'Two';
        if(Amount == 3)
            return 'Three';
        if(Amount == 4)
            return 'Four';
        if(Amount == 5)
            return 'Five';
        if(Amount == 6)
            return 'Six';
        if(Amount == 7)
            return 'Seven';
        if(Amount == 8)
            return 'Eight';
        if(Amount == 9)
            return 'Nine';
        if(Amount == 10)
            return 'Ten';

        if(Amount == 11)
            return 'Eleven';
        if(Amount == 12)
            return 'Twelve';
        if(Amount == 13)
            return 'Thirteen';
        if(Amount == 14)
            return 'Fourteen';
        if(Amount == 15)
            return 'Fifteen';
        if(Amount == 16)
            return 'Sixteen';
        if(Amount == 17)
            return 'Seventeen';
        if(Amount == 18)
            return 'Eighteen';
        if(Amount == 19)
            return 'Nineteen';
        if(Amount == 20)
            return 'Twenty';

        if(Amount > 20 && Amount < 100){
            if(math.mod(Amount, 10) == 0){
                if(Amount == 20)
                    return 'Twenty';
                if(Amount == 30)
                    return 'Thirty';
                if(Amount == 40)
                    return 'Forty';
                if(Amount == 50)
                    return 'Fifty';
                if(Amount == 60)
                    return 'Sixty';
                if(Amount == 70)
                    return 'Seventy';
                if(Amount == 80)
                    return 'Eighty';
                if(Amount == 90)
                    return 'Ninety';
            }else{
                if(Amount/10 == 2)
                    return 'Twenty '+AnountInWords(math.mod(Amount, 10));
                if(Amount/10 == 3)
                    return 'Thirty '+AnountInWords(math.mod(Amount, 10));
                if(Amount/10 == 4)
                    return 'Forty '+AnountInWords(math.mod(Amount, 10));
                if(Amount/10 == 5)
                    return 'Fifty '+AnountInWords(math.mod(Amount, 10));
                if(Amount/10 == 6)
                    return 'Sixty '+AnountInWords(math.mod(Amount, 10));
                if(Amount/10 == 7)
                    return 'Seventy '+AnountInWords(math.mod(Amount, 10));
                if(Amount/10 == 8)
                    return 'Eighty '+AnountInWords(math.mod(Amount, 10));
                if(Amount/10 == 9)
                    return 'Ninety '+AnountInWords(math.mod(Amount, 10));

            }
        }

        if(Amount >= 100 && Amount < 1000){
            string str = AnountInWords(Amount/100);
            if(math.mod(Amount, 100) == 0){
                str = str + ' Hundred';
            }else{
                str = str + ' Hundred ' + AnountInWords(math.mod(Amount, 100));
            }

            return str;

        }

        if(Amount >= 1000 && Amount < 1000000){
            string str = AnountInWords(Amount/1000);
            if(math.mod(Amount, 1000) == 0){
                str = str + ' Thousand';
            }else{
                str = str + ' Thousand ' + AnountInWords(math.mod(Amount, 1000));
            }

            return str;

        }

        if(Amount >= 1000000 && Amount < 1000000000){
            string str = AnountInWords(Amount/1000000);
            if(math.mod(Amount, 1000000) == 0){
                str = str + ' Million';
            }else{
                str = str + ' Million ' + AnountInWords(math.mod(Amount, 1000000));
            }

            return str;

        }

        return null;
    }
}