import objectWithNamespace from '@salesforce/schema/Digital_River_Tax_Mapping__c';

const DOUBLE_UNDERSCORE = '__';
const DEFAULT_COMPONENT_PREFIX = 'c';

let namespace = revolveNamespace();

export function revolveNamespace() {
  let objectApiName = objectWithNamespace.objectApiName;
  return hasNamespace(objectApiName) ? objectApiName.split(DOUBLE_UNDERSCORE)[0] : '';
}

export function hasNamespace(value) {
  const parts = value.split(DOUBLE_UNDERSCORE);
  return parts.length === 3;
}

export function getNamespace() {
  return namespace;
}

export function getNamespaceForNavigationScope() {
  return (getNamespace() ? getNamespace() : DEFAULT_COMPONENT_PREFIX) + DOUBLE_UNDERSCORE;
}

export function getNamespacePrefix() {
  return getNamespace() ? getNamespace() + DOUBLE_UNDERSCORE : '';
}

export function addNamespacePrefixToFieldName(fieldName) {
  const ns = getNamespace();
  if (ns &&  !hasFieldAnyNamespace(fieldName) && isCustomObjectField(fieldName)) {
    fieldName = getNamespacePrefix() + fieldName;
  }
  return fieldName;
}

export function hasCurrentNamespaceName(fieldName){
  return fieldName.toLowerCase().startsWith(getNamespacePrefix().toLowerCase());
}

export function isCustomObjectField(fieldName) {
  return (
    fieldName.indexOf(
      DOUBLE_UNDERSCORE
    ) !== -1
  );
}

export function hasFieldAnyNamespace(fieldName){
  return hasNamespace(fieldName);
}

export function addNamespacePrefixToFieldPath(fieldPath) {
  return fieldPath
    .split('.')
    .map(item => {
      return addNamespacePrefixToFieldName(item);
    })
    .join('.');
}

/**
 * The utility function to avoid redundant try/catch statement by wrapping async functions and returning back an array
 * with error and data.
 *
 * @example
 * const [error, account] = await to(getAccount());
 *
 * const [updateContactError, contact] = await to(updateContact())
 */

/**
 * @param { Promise } promise
 * @param { Object= } errorExt - Additional Information you can pass to the err object
 * @return { Promise }
 */
export function to(promise, errorExt) {
    return promise
        .then(function (data) {
            return [null, data];
        })
        .catch(function (err) {
            if (errorExt) {
                Object.assign(err, errorExt);
            }
            return [err, undefined];
        });
}

/**
 * Formats a string label by received attributes
 *
 * @example
 * formatLabel('{0} Options Selects', 5); - the result will be '5 Options Selected'
 *
 * @param label {String} the label to format
 * @param attributes the list of attributes to format of a string
 * @returns {string}
 */
export function formatLabel() {
    let label = arguments[0];

    for (let i = 1; i < arguments.length; i++) {
        label = label.replace(`{${i - 1}}`, arguments[i]);
    }

    return label || '';
}

/**
 * Splits a string by comma and space;
 * Trims items of returned array;
 *
 * @example
 * splitByComma('Item 1, Item 2 , Item3 '); - the result will be ['Item 1', 'Item 2', 'Item3']
 *
 * @param {string} stringToSplit the string to split
 * @returns {Array}
 */
export function splitByComma(stringToSplit) {
    if (!stringToSplit) {
        return [];
    }
    return stringToSplit
        .trim()
        .split(/\s*,+\s*/)
        .filter((i) => {
            return i;
        });
}

export function cloneObject(value) {
    return JSON.parse(JSON.stringify(value));
}

export function normaliseId(id) {
    return id.substring(0, 18);
}

export function isUndefined(value) {
    return value === undefined;
}

export function destructWiredRecord(wiredRecord) {
    return {
        values: {
            sobjectType: wiredRecord.apiName,
            ...Object.keys(wiredRecord.fields).reduce((object, field) => {
                if (isObjectHaveProperty(wiredRecord.fields[field].value, 'apiName')) {
                    object[field] = destructWiredRecord(wiredRecord.fields[field].value);
                } else {
                    object[field] = wiredRecord.fields[field].value;
                }
                return object;
            }, {}),
        },
        displayValues: {
            sobjectType: wiredRecord.apiName,
            ...Object.keys(wiredRecord.fields).reduce((object, field) => {
                object[field] = wiredRecord.fields[field].displayValue;
                return object;
            }, {}),
        },
        labels: {
            sobjectType: wiredRecord.apiName,
            ...Object.keys(wiredRecord.fields).reduce((object, field) => {
                object[field] = wiredRecord.fields[field].label;
                return object;
            }, {}),
        },
        inlineHelpTexts: {
            sobjectType: wiredRecord.apiName,
            ...Object.keys(wiredRecord.fields).reduce((object, field) => {
                object[field] = wiredRecord.fields[field].inlineHelpText;
                return object;
            }, {}),
        },
    };
}

export function isObjectHaveProperty(object, property) {
    return object && object.hasOwnProperty(property);
}

export function isInputsValid(inputs) {
    return [...inputs].reduce((validSoFar, inputFields) => {
        inputFields.reportValidity();
        return validSoFar && inputFields.checkValidity();
    }, true);
}

/**
 * Generates unique id value based on requested length.
 * It is alternative function to replace "uniqueId" function without dependency on window object.
 *
 * @param length {Number} - the length of id value
 * @returns {string} - the unique generated id value
 */
export function guid(length) {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    const charactersLength = characters.length;
    let result = '';

    for (let i = 0; i < length; i++) {
        result += characters.charAt(Math.floor(Math.random() * charactersLength));
    }

    return result;
}

export function isEmptyArray(arr) {
    return !(Array.isArray(arr) && arr.length);
}

export function isEmpty(value) {
    if (value === undefined || value === null) {
        return true;
    }

    if (Array.isArray(value)) {
        return value.length === 0;
    } else if (typeof value === 'object') {
        return Object.keys(value).length === 0 && value.constructor === Object;
    } else {
        return Boolean(value);
    }
}

export function isNotEmpty(obj) {
    return !isEmpty(obj);
}

export function convertToBoolean(bool) {
    return typeof bool === 'string' || bool instanceof String
        ? bool.toLowerCase() === 'true'
        : typeof bool === 'boolean' || bool instanceof Boolean
        ? bool
        : false;
}

/**
 * Set callback into interval to break Event Loop and wait for DOM changes (components properties changes)
 *
 * @param callback
 */
export function wait(callback) {
    setTimeout(callback, 0);
}

/**
 * Executes function by function by passing the return of a previous call to the consequent one
 *
 * @param functions the list of functions
 * @returns {function(*=): *}
 */
export const pipe = (...functions) => (args) => functions.reduce((arg, fn) => fn(arg), args);

/**
 * Parses an error which Apex action returns to a uniform structure that other
 * components (toastify, logger) depends on
 *
 * @param err an Apex action error
 * @returns {{details: {}, code: string, message: string}}
 */
export function parseError(err) {
    let message = '',
        details = {},
        code = '';

    if (err) {
        if (err.body && err.body.output) {
            message = err.body.message;

            if (err.body.output.errors.length > 0) {
                code = err.body.output.errors[0].message;
            }

            details = JSON.parse(JSON.stringify(err.body.output));
        } else if (Array.isArray(err.body) && err.body.length > 0) {
            message = err.body[0].message;
            code = err.body[0].errorCode;
        } else if (err.body && err.body.message) {
            message = err.body.message;
        } else if (err.body) {
            message = err.body;
        } else if (err.statusText) {
            message.err = err.statusText;
        } else if (err.message) {
            message = err.message;
        } else {
            message = err;
        }
    }

    return { message, code, details };
}
