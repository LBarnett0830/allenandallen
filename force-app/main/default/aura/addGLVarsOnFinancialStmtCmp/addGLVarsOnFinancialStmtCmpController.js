({
    init : function(component, event, helper) {
        component.set("v.recordUrlBase",'/one/one.app?#/sObject/');
        component.set("v.recordUrlBaseEnd",'/view');
        helper.getStmtWrapper(component);
    },
    
    hideConfirmation : function(component, event, helper){
        component.set("v.showConfirm",false);
         
    },
    showConfirmation : function(component, event, helper){
        component.set("v.showConfirm",true);        
        
    },
    
    submitToProcess: function(component, event, helper){
        component.set("v.showConfirm",false);        
        helper.updateGLVars(component);
    },
    
})