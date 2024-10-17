import { LightningElement, api, track } from 'lwc';

export default class BaseTableWrapperLWC extends LightningElement {
    @api title;
    @api tabledata;
    @api columns;
    @track currentPage = 1;
    @track itemsPerPage = 10;

    @track selectedItems = [];

    get paginatedData() {
        const start = (this.currentPage - 1) * this.itemsPerPage;
        const end = start + this.itemsPerPage;
        return this.table-data.slice(start, end);
    }

    handlePagination(event) {
        this.currentPage = event.detail.currentPage;
    }

    handleRowSelect(event) {
        const selectedId = event.detail;
        if(!this.selectedItems.includes(selectedId)) {
            this.selectedItems.push(selectedId);
        }
        console.log('Selected Items: ', this.selectedItems);
    }
}