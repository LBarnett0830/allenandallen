({
    hideConfirmation : function(component, event, helper) {
        component.set('v.showConfirm',false);
    },
    
    downloadExcel : function(component, event, helper) {
        window.open('/apex/requestForDmgVerificationXLS','_blank');
        component.set('v.showConfirm',false);
    }
})