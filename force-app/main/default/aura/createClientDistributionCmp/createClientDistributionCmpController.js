({
	doInit : function(component, event, helper) {
        helper.checkValidations(component);
    },
    
    hideConfirmation : function(component, event, helper){
        component.set("v.showConfirm",false);
        $A.get("e.force:closeQuickAction").fire();
    },   
    
    processCreatePayable : function(component, event, helper){
        component.set("v.showConfirm",false);
        helper.createPayable(component);
    },
    
    processWithInsufficientTrust : function(component, event, helper){
        component.set("v.confirmTrustBalance",true);
        component.set("v.showConfirmTrustBalance",false);
        helper.createPayable(component);
    },
    
})