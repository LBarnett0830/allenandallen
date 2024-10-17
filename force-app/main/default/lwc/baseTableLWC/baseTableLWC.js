import { LightningElement, api } from 'lwc';

export default class BaseTableLWC extends LightningElement {
    @api columns;
    @api tabledata;

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;


        const selectedEvent = new CustomEvent("select", { detail: row.Id, bubbles: true, composed: true })

        this.dispatchEvent(selectedEvent);
    }
}