import { LightningElement , wire} from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import toggleShowTC from '@salesforce/messageChannel/digitalriverv3__TaxCertificateMessageChannel__c';

export default class LmsPublistTest extends LightningElement {

    @wire(MessageContext)
    messageContext;
    showLink = false;
    handleToggleButton(){
        this.showLink  = !this.showLink
        publish(this.messageContext, toggleShowTC, {
            showLink: this.showLink 
        });
    }

}