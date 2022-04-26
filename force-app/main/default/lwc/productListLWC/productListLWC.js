import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation'; 
import { registerListener, fireEvent } from 'c/pubsub';
import getImplementatationForParameters from '@salesforce/apex/LWCImplementationSelector.getImplementatationForParameters';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ProductListLWC extends LightningElement {
    selection = [];
    allRecords;
    rowsPerPagePicklistData = [
        { label: '10', value: '10' },
        { label: '20', value: '25' },
        { label: '50', value: '50' }
    ];
    rowsPerPageSelected = '10';

    @track orderActive = false;
    @track displayedTableRecords;
    @track columns = [
        {
            "label": "Name",
            "fieldName": "Name",
            "type" : "text"
        },
        {
            "label": "Unit Price",
            "fieldName": "UnitPrice",
            "type": "currency"
        }
    ];
    @track state = {
        page : 1,
        totalNumberOfPages : 0,
        isLoading : true,
        sortBy : 'Id',
        sortDirection : 'desc'
    };

    @wire(CurrentPageReference) pageRef; 

    async connectedCallback(){
        registerListener('orderisactivated', this.handleOrderIsActivated, this);

        this.allRecords = await getImplementatationForParameters({inputParameters: {getDistinctPriceBookEntries: true}});
        this.recalculatePageNavigationValues();
        this.state.isLoading = false;
    }

    handleAddProductsToOrder(event){
        console.log('%c handleAddProductsToOrder', 'color:yellow');
        if(this.selection?.length > 0){
            let selectedProducts = this.allRecords.filter(prod => this.selection.indexOf(prod.Id) > -1);
            fireEvent(this.pageRef, 'addproducttoorder', selectedProducts);
        }
        else{
            this.showToast('error', 'No records selected', 'Please select records for order');
        }
    }

    handleOrderIsActivated(event){
        this.orderActive = true;
    }

    getSelectedRecordsFromTable(event){
        let updatedItemsSet = new Set(); // List of selected items from the data table event.
        let selectedItemsSet = new Set(this.selection); // List of selected items we maintain.
        let loadedItemsSet = new Set(); // List of items currently loaded for the current view.

        this.displayedTableRecords.forEach((record) => {
            loadedItemsSet.add(record.Id);
        });

        if (event.detail.selectedRows){
            event.detail.selectedRows.forEach((event) => {
                updatedItemsSet.add(event.Id);
            });
            updatedItemsSet.forEach((id) => {
                if (!selectedItemsSet.has(id)) {
                    selectedItemsSet.add(id); // Add any new items to the selection list
                }
            }); 
        }

        loadedItemsSet.forEach((id) => {
            if (selectedItemsSet.has(id) && !updatedItemsSet.has(id)){
                selectedItemsSet.delete(id); // Remove any items that were unselected.
            }
        });
        this.selection = [...selectedItemsSet];
    }

    handleRowsPerPageChange(event){
        this.rowsPerPageSelected = event.detail.value;
        this.recalculatePageNavigationValues();
    }

    previousHandler(event){
        if(this.state.page > 1){
            this.state.page = parseInt(this.state.page - 1);
            this.recalculatePageNavigationValues();
        }
    }

    nextHandler(event){
        if(this.state.page < this.state.totalNumberOfPages){
            this.state.page = parseInt(this.state.page + 1);
            this.recalculatePageNavigationValues();
        }
    }

    recalculatePageNavigationValues(){
        if(this.allRecords){
            let pageSize = parseInt(this.rowsPerPageSelected);
            this.state.totalNumberOfPages = Math.ceil(this.allRecords.length / pageSize);
            let startingRecord = ((this.state.page - 1) * pageSize);
            let endingRecord = startingRecord + pageSize;
            this.displayedTableRecords = this.allRecords.slice(startingRecord, endingRecord);
        }
    }

    showToast(type, title, message) {
        this.dispatchEvent(new ShowToastEvent({
            variant: type,
            title: title,
            message: message
        }));
    }
}