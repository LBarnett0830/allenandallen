({
    doInit : function(component, event, helper) {
        // helper.checkValidation(component);
        helper.getResolutionDetails(component);
    },
    handleValidation : function(component, event, helper){
        helper.checkValidation(component);
    },
    
    doCheck : function(component, event, helper) {
        var chk1= component.find("chk1");
        //var chk2= component.find("chk2");
        var chk3= component.find("chk3");
        var chk4= component.find("chk4");
        var chk5= component.find("chk5");
        var chk6= component.find("chk6");
        var chk7= component.find("chk7");
        var chk8= component.find("chk8");
        
        if(chk1.get("v.value")==true &&  chk3.get("v.value")==true &&  chk4.get("v.value")==true && chk5.get("v.value")==true && chk6.get("v.value")==true && chk7.get("v.value")==true && chk8.get("v.value")==true ){
            component.set("v.showCloseBtn",true);
        }
        else{
            component.set("v.showCloseBtn",false);
        }
        
    },
    
    handleClose : function(component, event, helper) {
        component.set("v.showConfirmToClose",true);
    },
    hideConfirmation : function(component, event, helper){
        component.set("v.showConfirmToClose",false);
        component.set("v.showConfirmTrustBalance",false);
    },
    
    handleCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        
    },
    processClose : function(component, event, helper){
        component.set("v.showConfirmToClose",false);
        component.set("v.showConfirmTrustBalance",false);
        helper.closeResolution(component);
    },
     processCloseWithInsufficientTrust : function(component, event, helper){
          component.set("v.confirmTrustBalance",true);
        component.set("v.showConfirmTrustBalance",false);
        helper.closeResolution(component);
    },
    
    
})