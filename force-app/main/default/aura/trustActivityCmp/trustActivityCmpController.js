({
    init : function(component, event, helper) {
        if(document.referrer.indexOf(".lightning.force.com") > 0){
            component.set("v.recordUrlBase",'/one/one.app?#/sObject/');
            component.set("v.recordUrlBaseEnd",'/view');
        }
        else{
            component.set("v.isClassic",true);
            component.set("v.recordUrlBase",'/');
            component.set("v.recordUrlBaseEnd",'');
        }
        helper.getMatterWrapper(component);
    },
    
    sortByDate : function(component, event, helper) {
        component.set("v.sortBy",'date');
        component.set("v.amountDesc",null);
        component.set("v.partyDesc",null);
        component.set("v.trustCodeDesc",null);
        var objWrapper=  component.get("v.matterWrapper");
        var trustActDetailList = objWrapper.trustActDetailList;
        var dateDesc =  component.get("v.dateDesc");
        dateDesc = dateDesc==null?true:dateDesc;
        if(dateDesc){
            trustActDetailList.sort(function(a,b){
                return new Date(b.transactioDate) - new Date(a.transactioDate);
            });
            component.set("v.dateDesc",false);
        }
        else{
            trustActDetailList.sort(function(b,a){
                return new Date(b.transactioDate) - new Date(a.transactioDate);
            });
            component.set("v.dateDesc",true);
        }
        
        objWrapper.trustActDetailList = trustActDetailList;
        component.set("v.matterWrapper",objWrapper);
        
    },
    
    sortByAmount : function(component, event, helper) {
        component.set("v.sortBy",'amount');
        component.set("v.dateDesc",null);
        component.set("v.partyDesc",null);
        component.set("v.trustCodeDesc",null);
        var objWrapper=  component.get("v.matterWrapper");
        var trustActDetailList = objWrapper.trustActDetailList;
        var amountDesc =  component.get("v.amountDesc");
        if(amountDesc){
            trustActDetailList.sort(function(a,b){
                return new Date(b.amount) - new Date(a.amount);
            });
            component.set("v.amountDesc",false);
        }
        else{
            trustActDetailList.sort(function(b,a){
                return new Date(b.amount) - new Date(a.amount);
            });
            component.set("v.amountDesc",true);
        }
        
        objWrapper.trustActDetailList = trustActDetailList;
        component.set("v.matterWrapper",objWrapper);
        
    },
    
    sortByParty : function(component, event, helper) {
        component.set("v.sortBy",'party');
        component.set("v.dateDesc",null);
        component.set("v.trustCodeDesc",null);
        component.set("v.amountDesc",null);
        var objWrapper=  component.get("v.matterWrapper");
        var trustActDetailList = objWrapper.trustActDetailList;
        var partyDesc =  component.get("v.partyDesc");
        if(partyDesc){
            trustActDetailList.sort((a, b) => (a.accountName > b.accountName) ? 1 : -1);
            component.set("v.partyDesc",false);
        }
        else{
            trustActDetailList.sort((a, b) => (a.accountName < b.accountName) ? 1 : -1);
            component.set("v.partyDesc",true);
        }
        
        objWrapper.trustActDetailList = trustActDetailList;
        component.set("v.matterWrapper",objWrapper);
        
    },
    
    sortByTrustCode : function(component, event, helper) {
        component.set("v.sortBy",'trustCode');
        component.set("v.amountDesc",null);
        component.set("v.dateDesc",null);
        component.set("v.partyDesc",null);
        var objWrapper=  component.get("v.matterWrapper");
        var trustActDetailList = objWrapper.trustActDetailList;
        var trustCodeDesc =  component.get("v.trustCodeDesc");
        if(trustCodeDesc){
            trustActDetailList.sort((a, b) => (a.trustCode > b.trustCode) ? 1 : -1);
            component.set("v.trustCodeDesc",false);
        }
        else{
            trustActDetailList.sort((a, b) => (a.trustCode < b.trustCode) ? 1 : -1);
            component.set("v.trustCodeDesc",true);
        }
        
        objWrapper.trustActDetailList = trustActDetailList;
        component.set("v.matterWrapper",objWrapper);
        
    }
    
    
    
    
})