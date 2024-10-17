import { LightningElement, wire, api, track } from 'lwc';

import {
    subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled
} from 'lightning/empApi';

import userId from '@salesforce/user/Id';

export default class wdipopup extends LightningElement {
  
    @api channelName='/event/WDI_Message_Event__e';
    @api currentRecord;
    @track error;
    @track isLoading = true;
    subscription = {};

    @api popupTitle;
    @api popupNubbin = 'bottom-left';
    @api popupSize = 'large';
    @api popupFooter = '';
    @track confirmLabel = 'OK';
    @track cancelLabel = 'Exit';

    @track popupValue;
    @track showPopup;

    isLoaded = false;

    connectedCallBack() {
        console.log ('In connectedCallBack');
        //this.popupValue = 'In connectedCallBack';
        console.log('Channel Name:' + this.channelName);
    }

    /*
    constructor() {
        super();
        console.log('in constructor');
    }
 */ 

    renderedCallback() {
        console.log ('in renderedCallback');
        //this.popupValue = 'In renderedCallback';

        this.registerListener();
        this.handleSubscribe();
    }

    handleSubscribe() {
        console.log('in handleSubscribe');
        //const thisReference = this;
        const messageCallback = (response) => {
            this.handleResponse(response);
        };

        console.log('checking to see if subscribed already');
        if (!this.isloaded) {
            console.log('subscribing');
            subscribe(this.channelName,-1,messageCallback).then(response => {
                console.log('Subscription requeast sent to:',JSON.stringify(response.channel));
                this.subscription = response;
            });
            this.isloaded = true;
        }

    }

    handleResponse(response) {
        console.log('in handleResponse');
        console.log('new message received 1:',JSON.stringify(response));
        console.log('new messsage received 2:',response);

        var obj = JSON.parse(JSON.stringify(response));
        console.log('new message received 4:',obj.data.payload.Message__c);
        console.log('for the user:',obj.data.payload.UserID__c);
        console.log('new message received 5:',this.channelName);
        /*
        if (thisReference.isConnected) {
            const evt = new ShowToastEvent({
                title:'New Text Message received.',
                messsage:'New text message received',
                variant: 'success',
            });
            thisReference.dispatchEvent(evt);
        */
            console.log('calling refresh now');
            //verifying that message is for current user
            if (userId === obj.data.payload.UserID__c) {
                this.popupValue = obj.data.payload.Message__c;
                //this.popupValue = obj.data.payload.Message__c + '  UserId:' + userId + '    UserId in message:' + obj.data.payload.UserID__c;
                this.showPopup = true;
            }
            
    }

    registerListener() {
        console.log('in registerListener');
        onError(error => {
            console.log('Received error from server:',JSON.stringify(error) );
        });
    }

    handleClick(event) {
        console.log('in handleClick event');

        if (event.detail !== 1) {
            this.showPopup = false;
        }
    }
}