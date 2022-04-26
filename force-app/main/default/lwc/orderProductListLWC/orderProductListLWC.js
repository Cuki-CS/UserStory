import { LightningElement, track, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation'; 
import { registerListener, fireEvent } from 'c/pubsub';
import getImplementatationForParameters from '@salesforce/apex/LWCImplementationSelector.getImplementatationForParameters';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OrderProductListLWC extends LightningElement {
    @api recordId;

    allRecords = [];
    allRecordIds = [];
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
        },
        {
            "label": "Quantity",
            "fieldName": "Quantity",
            "type": "text"
        },
        {
            "label": "Total Price",
            "fieldName": "TotalPrice",
            "type": "currency"
        }
    ];
    @track state = {
        page : 1,
        totalNumberOfPages : 0,
        isLoading : true
    };

    @wire(CurrentPageReference) pageRef; 

    async connectedCallback(){
        registerListener('addproducttoorder', this.handleAddProductToOrder, this);
        const orderStatus = await getImplementatationForParameters({inputParameters: {selectOrderStatus: true, orderId: this.recordId}});

        if(JSON.parse(orderStatus).Status === 'Activated'){
            this.orderActive = true;
            fireEvent(this.pageRef, 'orderisactivated', true);
        }
        this.state.isLoading = false;
    }

    handleAddProductToOrder(payload){
        payload.forEach(element => {
            if(this.allRecordIds.indexOf(element.Id) === -1){
                this.allRecordIds.push(element.Id);
                let newEl = {...element};
                newEl['TotalPrice'] = newEl.UnitPrice;
                newEl['Quantity'] = 1;
                this.allRecords.push(newEl);
            }
            else{
                this.allRecords.forEach(record => {
                    if(element.Id === record.Id){
                        record.Quantity = record.Quantity + 1;
                        record.TotalPrice = record.UnitPrice * record.Quantity;
                    }
                });
            }
        });
        this.recalculatePageNavigationValues();
    }

    async handleRemoteCallToValidateOrder(event){
        try {
            this.isLoading = true;
            const response = await getImplementatationForParameters({inputParameters: {callOrderActivationService: true, orderItems: this.allRecords, orderId: this.recordId}});
            this.isLoading = false;   
            if(JSON.parse(response).IsSuccess){
                this.showToast('success', 'OK', 'Order is updated');
                this.orderActive = true;
                fireEvent(this.pageRef, 'orderisactivated', true);
            }
            else{
                this.showToast('error', 'Failed', 'Order is not updated');
            }
        } catch (error) {
            this.showToast('error', 'Failed', error.body.message);
        }
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