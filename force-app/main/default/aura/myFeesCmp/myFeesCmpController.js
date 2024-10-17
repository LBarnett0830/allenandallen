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
        helper.getTransactionWrapper(component);
    },
    
    sortByDate : function(component, event, helper) {
        component.set("v.sortBy",'date');
        component.set("v.amountDesc",null);
        component.set("v.partyDesc",null);
        component.set("v.trustCodeDesc",null);
        var objWrapper=  component.get("v.objWrapper");
        var listTransaction = objWrapper.listTransaction;
        var dateDesc =  component.get("v.dateDesc");
        dateDesc = dateDesc==null?true:dateDesc;
        if(dateDesc){
            listTransaction.sort(function(a,b){
                return new Date(b.transDate) - new Date(a.transDate);
            });
            component.set("v.dateDesc",false);
        }
        else{
            listTransaction.sort(function(b,a){
                return new Date(b.transDate) - new Date(a.transDate);
            });
            component.set("v.dateDesc",true);
        }
        
        objWrapper.listTransaction = listTransaction;
        component.set("v.objWrapper",objWrapper);
        
    },
    
    sortByAccPeriod : function(component, event, helper) {
        component.set("v.sortBy",'date');
        component.set("v.amountDesc",null);
        component.set("v.partyDesc",null);
        component.set("v.trustCodeDesc",null);
        var objWrapper=  component.get("v.objWrapper");
        var listTransaction = objWrapper.listTransaction;
        var accPeriodDesc =  component.get("v.accPeriodDesc");
        accPeriodDesc = accPeriodDesc==null?true:accPeriodDesc;
        if(accPeriodDesc){
            
            listTransaction.sort((a, b) => (a.accPeriodName > b.accPeriodName) ? 1 : -1);        
            component.set("v.accPeriodDesc",false);
        }
        else{
            listTransaction.sort((a, b) => (a.accPeriodName < b.accPeriodName) ? 1 : -1);        
            
            component.set("v.accPeriodDesc",true);
        }
        
        objWrapper.listTransaction = listTransaction;
        component.set("v.objWrapper",objWrapper);
        
    },    
    
    sortByProject : function(component, event, helper) {
        component.set("v.sortBy",'date');
        component.set("v.amountDesc",null);
        component.set("v.partyDesc",null);
        component.set("v.trustCodeDesc",null);
        var objWrapper=  component.get("v.objWrapper");
        var listTransaction = objWrapper.listTransaction;
        var projectDesc =  component.get("v.projectDesc");
        projectDesc = projectDesc==null?true:projectDesc;
        if(projectDesc){
            listTransaction.sort((a, b) => (a.projectName > b.projectName) ? 1 : -1);           
            component.set("v.projectDesc",false);
        }
        else{
            listTransaction.sort((a, b) => (a.projectName < b.projectName) ? 1 : -1);        
            component.set("v.projectDesc",true);
        }
        
        objWrapper.listTransaction = listTransaction;
        component.set("v.objWrapper",objWrapper);
        
    },    
    
    sortByAmount : function(component, event, helper) {
        component.set("v.sortBy",'amount');
        component.set("v.dateDesc",null);
        component.set("v.partyDesc",null);
        component.set("v.trustCodeDesc",null);
        var objWrapper=  component.get("v.objWrapper");
        var listTransaction = objWrapper.listTransaction;
        var amountDesc =  component.get("v.amountDesc");
        if(amountDesc){
            listTransaction.sort((a, b) => (a.amount > b.amount) ? 1 : -1);      
            component.set("v.amountDesc",false);
        }
        else{
            listTransaction.sort((a, b) => (a.amount < b.amount) ? 1 : -1);      
            component.set("v.amountDesc",true);
        }
        
        objWrapper.listTransaction = listTransaction;
        component.set("v.objWrapper",objWrapper);
        
    },
    
    sortByResolutionDate : function(component, event, helper) {
        component.set("v.sortBy",'date');
        component.set("v.amountDesc",null);
        component.set("v.partyDesc",null);
        component.set("v.trustCodeDesc",null);
        var objWrapper=  component.get("v.objWrapper");
        var listTransaction = objWrapper.listTransaction;
        var resDateDesc =  component.get("v.resDateDesc");
        resDateDesc = resDateDesc==null?true:resDateDesc;
        if(resDateDesc){
            listTransaction.sort(function(a,b){
                return new Date(b.transDate) - new Date(a.transDate);
            });
            component.set("v.resDateDesc",false);
        }
        else{
            listTransaction.sort(function(b,a){
                return new Date(b.transDate) - new Date(a.transDate);
            });
            component.set("v.resDateDesc",true);
        }
        
        objWrapper.listTransaction = listTransaction;
        component.set("v.objWrapper",objWrapper);
        
    },
    
    sortByResolution : function(component, event, helper) {
        component.set("v.sortBy",'date');
        component.set("v.amountDesc",null);
        component.set("v.partyDesc",null);
        component.set("v.trustCodeDesc",null);
        var objWrapper=  component.get("v.objWrapper");
        var listTransaction = objWrapper.listTransaction;
        var resolutionDesc =  component.get("v.resolutionDesc");
        resolutionDesc = resolutionDesc==null?true:resolutionDesc;
        if(resolutionDesc){
            listTransaction.sort((a, b) => (a.resolutionName > b.resolutionName) ? 1 : -1);           
            component.set("v.resolutionDesc",false);
        }
        else{
            listTransaction.sort((a, b) => (a.resolutionName < b.resolutionName) ? 1 : -1);        
            component.set("v.resolutionDesc",true);
        }
        
        objWrapper.listTransaction = listTransaction;
        component.set("v.objWrapper",objWrapper);
        
    },    
    
    
    
    
})