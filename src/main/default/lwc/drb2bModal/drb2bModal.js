import { api, LightningElement } from "lwc";

const LOADING = "Loading";

export default class Drb2BModal extends LightningElement {
    
    isModalOpen = false;
    modalStyle = "display : none;";
    bodyStyle = "";
    modalSectionStyle;
    showBackdrop = true;
    @api size = "small";
    @api loading = false;
    @api hideCloseButton = false;
    @api fixPosition = false;
    LoadingLabel = LOADING;
    
    connectedCallback() {
        this.setModalSize();
    }
    
    renderedCallback() {
        this.bodyHeight = this.template.querySelector(".slds-modal__content").offsetHeight;
        this.loadingEl = this.template.querySelector(".loading");
        if (this.loadingEl) this.loadingEl.style.height = this.bodyHeight + "px";
        const modalBody = this.template.querySelector(".modal-body-overflow");
        if (modalBody) modalBody.style.minHeight = this.minHeight;
        
        if (this.fixPosition && window.innerHeight < 800) {
            this.template.querySelector(".slds-modal").classList.add("fix-position");
        }
    }
    
    @api
    open() {
        this.modalStyle = "";
    }
    
    @api
    close() {
        this.dispatchEvent(new CustomEvent("modalclose"));
        this.modalStyle = "display : none;";
    }
    
    @api
    overflowFix() {
        this.bodyStyle = "overflow: visible; overflow-y: visible";
    }
    
    @api
    overflowCustom() {
        let modalBody = this.template.querySelector(".modal-body-overflow");
        if (modalBody) {
            modalBody.className = "";
        }
        this.bodyStyle = "";
    }
    
    @api
    overflowScroll() {
        this.bodyStyle = "overflow: visible; overflow-y: auto";
    }
    
    @api
    removeBackdrop() {
        this.showBackdrop = false;
    }
    
    @api
    set minHeight(val) {
        this._minHeight = val;
    }
    
    get minHeight() {
        return this._minHeight;
    }
    
    setModalSize() {
        let baseCss = "slds-modal slds-fade-in-open disabled-modal-outline ";
        
        switch (this.size) {
            case "small":
                this.modalSectionStyle = baseCss + "slds-modal_small";
                break;
            
            case "medium":
                this.modalSectionStyle = baseCss + "slds-modal_medium";
                break;
            
            case "large":
                this.modalSectionStyle = baseCss + "slds-modal_large";
                break;
            
            case "default":
                this.modalSectionStyle = baseCss;
                break;
        }
    }
    
}