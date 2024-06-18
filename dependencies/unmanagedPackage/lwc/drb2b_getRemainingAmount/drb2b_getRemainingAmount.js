import { LightningElement,api,track  } from 'lwc';
import getRemainingAmount from "@salesforce/apex/digitalriverv3.DRB2B_CustomerCreditService.getAmountRemainingforCheckout";

export default class Drb2b_getRemainingAmount extends LightningElement {
    @api recordId;
    @track response;

    getRemainingAmount(){
        let input = {
            cartId:this.recordId
        };
        getRemainingAmount({inputData:JSON.stringify(input)})
        .then((data)=>{
            if(data){
               this.response = data;
                //console.log('response',JSON.parse(JSON.stringify(data)));
            }
        })
        .catch((error)=>{
            console.log('error',error);
        })
    }
}