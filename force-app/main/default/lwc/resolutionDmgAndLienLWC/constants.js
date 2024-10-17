/**
 * 
 */
export const damageTableColumns = [
    { label: 'Name', fieldName: 'name', type: 'button',typeAttributes: { label: {fieldName: 'name'}, name: 'name', target: 'base', variant: 'base'}},
    {label: 'Provider', fieldName: 'providerName', type: 'button', wraptext: false, typeAttributes: {
        label: { fieldName: 'providerName'},
        title: 'Click to view Provider',
        name: 'dmgProvider',
        variant: 'base',
        type: 'text'
    }},
    { label: 'Payee', fieldName: 'payee', type: 'text'},
    { label: 'Balance Due', fieldName: 'balanceDue', type: 'text'},
    { label: 'Type', fieldName: 'type', type: 'text'},
    { label: 'Verify Date', fieldName: 'verifyDate', type: 'date-local'},
    { label: 'Escrow', fieldName: 'escrow', type: 'boolean', typeAttributes: {
        label: {fieldName: 'escrow'},
        editable: false
    }}
];
/**
 * Liens Table columns
 */
export const liensTableColumns = [
    { label: 'Name', fieldName: 'name', type: 'button',typeAttributes: 
        { 
            label: {fieldName: 'name'}, 
            name: 'name', 
            target: 'base', 
            variant: 'base'
        }
    },
    { label: 'Provider', fieldName: 'providerName', type: 'button', wraptext: false, typeAttributes: 
        {
            label: { fieldName: 'providerName'},
            title: 'Click to view Provider',
            name: 'dmgProvider',
            variant: 'base',
            type: 'text'
        }
    },
    { label: 'Payee', fieldName: 'payee', type: 'text'},
    { label: 'Balance Due', fieldName: 'balanceDue', type: 'text'},
    { label: 'Type', fieldName: 'type', type: 'text'},
    { label: 'Verify Date', fieldName: 'verifyDate', type: 'date-local'},
    { label: 'Escrow', fieldName: 'escrow', type: 'boolean', typeAttributes: 
        {
        label: {fieldName: 'escrow'},
        editable: false
        }
    }
];
/**
 * Used Damage table columns
 */
export const usedDamagesColumns = [
    { label: 'Name', fieldName: 'name', type: 'button',typeAttributes: 
        { 
            label: {fieldName: 'name'}, 
            name: 'name', 
            target: 'base', 
            variant: 'base'
        }
    },
    { label: 'Provider', fieldName: 'providerName', type: 'button', wraptext: false, typeAttributes: 
        {
            label: { fieldName: 'providerName'},
            title: 'Click to view Provider',
            name: 'dmgProvider',
            variant: 'base',
            type: 'text'
        }
    },
    { label: 'Resolution', fieldName: 'resolutionName', type: 'text'},
    { label: 'Balance Due', fieldName: 'balanceDue', type: 'text'},
    { label: 'Type', fieldName: 'type', type: 'text'},
    { label: 'Verify Date', fieldName: 'verifyDate', type: 'date-local'},
    { label: 'Escrow', fieldName: 'escrow', type: 'boolean', typeAttributes: 
        {
        label: {fieldName: 'escrow'},
        editable: false
        }
    }
];

/**
 * Used Lien columns
 */
export const usedLiensColumns = [
    { label: 'Name', fieldName: 'name', type: 'button',typeAttributes: 
        { 
            label: {fieldName: 'name'}, 
            name: 'name', 
            target: 'base', 
            variant: 'base'
        }
    },
    { label: 'Provider', fieldName: 'providerName', type: 'button', wraptext: false, typeAttributes: 
        {
            label: { fieldName: 'providerName'},
            title: 'Click to view Provider',
            name: 'dmgProvider',
            variant: 'base',
            type: 'text'
        }
    },
    { label: 'Resolution', fieldName: 'resolutionName', type: 'text'},
    { label: 'Balance Due', fieldName: 'balanceDue', type: 'text'},
    { label: 'Type', fieldName: 'type', type: 'text'},
    { label: 'Verify Date', fieldName: 'verifyDate', type: 'date-local'},
    { label: 'Escrow', fieldName: 'escrow', type: 'boolean', typeAttributes: 
        {
        label: {fieldName: 'escrow'},
        editable: false
        }
    }
];