import { LightningElement, api, wire } from "lwc";
import dr_lms from '@salesforce/messageChannel/digitalriverv3__DigitalRiverMessageChannel__c';
import { publish, MessageContext } from "lightning/messageService";

export default class Drb2b_genricPublisher extends LightningElement {
    @api purpose;
    @api payload;
    puposevalue;
    payloadValue;
    isrendered = false;
    @wire(MessageContext)
    messageContext;

    renderedCallback() {
        if (this.isrendered) return;
        this.isrendered = true;
        this.handlepublish(this.purpose, this.payload);
    }

    handlePublishEvent() {
        let purpose = this.template.querySelector(".purpose").value;
        let payload = this.template.querySelector(".payload").value;
        this.handlepublish(purpose, payload);
    }

    handlepublish(purpose, payload) {
        publish(this.messageContext, dr_lms, {
            purpose: purpose,
            payload: payload
        });
    }
}
