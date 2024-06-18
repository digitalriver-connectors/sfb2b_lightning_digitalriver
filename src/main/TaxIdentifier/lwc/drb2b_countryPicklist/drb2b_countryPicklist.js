import { LightningElement, wire, api } from "lwc";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import PRODUCT_OBJECT from "@salesforce/schema/Product2";
import COUNTRY_FIELD from "@salesforce/schema/Product2.DR_Product_Country_Origin__c";
//labels
import DR_Country from "@salesforce/label/c.DR_Country";
import DR_Select_Country_placeholder from "@salesforce/label/c.DR_Select_Country_placeholder";

export default class Drb2b_countryPicklist extends LightningElement {
    labels = {
        DR_Country,
        DR_Select_Country_placeholder
    };

    @wire(getObjectInfo, { objectApiName: PRODUCT_OBJECT })
    productMetadata;

    @wire(getPicklistValues, {
        recordTypeId: "$productMetadata.data.defaultRecordTypeId",
        fieldApiName: COUNTRY_FIELD
    })
    countryPicklist;

    handleChange(event) {
        const selectedEvent = new CustomEvent("selected", { detail: event });
        this.dispatchEvent(selectedEvent);
    }
    @api getCountryList() {
        return this.countryPicklist;
    }
    @api getCountryPickListMap() {
        var countryAndISOCodeMap = [];
        this.countryPicklist.data.values.forEach(function (e) {
            countryAndISOCodeMap[e.label] = e.value;
        });
        return countryAndISOCodeMap;
    }
    @api getCountryPickListMapWithKeyUpperCase() {
        var countryAndISOCodeMap = [];
        this.countryPicklist.data.values.forEach(function (e) {
            countryAndISOCodeMap[e.label.toUpperCase()] = e.value;
        });
        return countryAndISOCodeMap;
    }

    @api getCountryNamePickListMap() {
        var isoCodeAndCountryNameMap = [];
        this.countryPicklist.data.values.forEach(function (e) {
            isoCodeAndCountryNameMap[e.value] = e.label;
        });
        return isoCodeAndCountryNameMap;
    }
}
