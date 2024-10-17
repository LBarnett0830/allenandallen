import { LightningElement, api } from 'lwc';

export default class BasePagination extends LightningElement {
    @api currentPage;
    @api itemsPerPage;
    @api totalItems;

    get totalPages() {
        return Math.ceil(this.totalItems/this.itemsPerPage);
    }

    handlePageChange(newPage) {
        const pageChangeEvent = new CustomEvent('pagechange', {
            detail: { currentPage: newPage }
        });
        this.dispatchEvent(pageChangeVent);
    }

    handleNext(){
        if (this.currentPage < this.totalPages) {
            this.handlePageChange(this.currentPage + 1)
        }
    }

    handlePrevious(){
        if (this.currentPage > 1) {
            this.handlePageChange(this.currentPage - 1)
        }
    }
}