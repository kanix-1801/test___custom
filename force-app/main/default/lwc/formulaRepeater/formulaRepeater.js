import { LightningElement, track, api } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';

export default class FormulaRepeater extends LightningElement {

    // Picklist options, input from Flow as JSON string
    _rawPicklistOptions;
    _picklistOptions = [];
    _formulaPicklistOptions = [];
    summaryPicklist = [];

    @api
    set picklistOptions(value) {
        if (value && Array.isArray(value)) {
            this._rawPicklistOptions = value;
            console.log(' this._rawPicklistOptions ',JSON.stringify( this._rawPicklistOptions ));

             const NumberTypeFilteredValues = value.filter(item => 
            item.type === 'DOUBLE' || item.type === 'NUMBER' || item.type === 'CURRENCY' || item.type === 'INTEGER'
        );

            this._picklistOptions = NumberTypeFilteredValues.map(item => {
                return {
                    label: item.label,
                    value: item.name
                };
            });
            this.summaryPicklist = this._picklistOptions; // Initialize summaryPicklist with the same options

         // Check if 'Other' is already added to the _formulaPicklistOptions
        if (!this._formulaPicklistOptions.some(option => option.value === 'other')) {
            // Add 'Other' option only once
            this._formulaPicklistOptions = [
                ...this._picklistOptions,  // Add the filtered options
                { label: 'Other', value: 'other' }  // Add 'Other' option at the end
            ];
        } else {
            // Otherwise, just append the filtered options without duplicating 'Other'
            this._formulaPicklistOptions = [...this._picklistOptions];
        }



            console.log('Processed Picklist Options: ', this._picklistOptions);
            console.log('Processed _formulaPicklistOptions: ', this._formulaPicklistOptions);
        }
    }

    get picklistOptions() {
        return this._picklistOptions;
    }

    get formulaPicklistOptions() {
    return this._formulaPicklistOptions;
}

// Formula Fields Configurations
@track rows = [
    {
        id: 1,
        fField: '',
        operator: '',  // Use 'operator' consistently
        sField: '',
        Column_Name: '',  // Corrected the misspelling
        manualValue: '',
        showManualValue: false  // New property to control visibility of manual value input
    }
];

operatorOptions = [
    { label: '+', value: '+' },
    { label: '-', value: '-' },
    { label: '*', value: '*' },
    { label: '/', value: '/' }
];

rowId = 1;

addRow() {
    this.rowId++;
    this.rows = [
        ...this.rows,
        {
            id: this.rowId,
            fField: '',
            operator: '',  // Use 'operator' consistently
            sField: '',
            Column_Name: '',  // Corrected the misspelling
            manualValue: '',
            showManualValue: false 
        }
    ];

    this.updateSummaryPicklist();

}

removeRow() {
    if (this.rows.length > 1) {
        this.rows = this.rows.slice(0, -1);
    }

    this.updateSummaryPicklist();

}


handleChange(event) {
    const index = event.target.dataset.index;
    const fieldName = event.target.name;
    const Value = event.target.value;
    this.rows[index][fieldName] = Value;

    //   if (fieldName === 'sField' && Value === 'other') {
    //     this.rows[index].showManualValue = true;
    // }else{
    //    this.rows[index].showManualValue = false; 
    // }

 if (fieldName === 'sField') {
        this.rows[index].showManualValue = (Value === 'other');
        // Optional: clear manualValue if sField changed to something other than 'other'
        if (Value !== 'other') {
            this.rows[index].manualValue = '';
        }
    }
    this.rows = [...this.rows];
     this.updateSummaryPicklist(); // Always update when anything changes
}


@api
get repeaterValues() {
    const repeaterMap = {};
    this.rows.forEach((row) => {
        // const { Column_Name, fField, operator, sField } = row;  // Corrected Column_Name
        // if (sField && operator && fField) {
        //     repeaterMap[Column_Name] = `${fField} ${operator} ${sField}`;
        // }

        const { Column_Name, fField, operator, sField, manualValue } = row;  // Added manualValue
        if (sField === 'other' && manualValue) {
            repeaterMap[Column_Name] = `${fField} ${operator} ${manualValue}`;  // Use manual value if "Other" selected
        } else if (sField && operator && fField) {
            repeaterMap[Column_Name] = `${fField} ${operator} ${sField}`;
        }

    });
    console.log("repeaterMap", repeaterMap);
    console.log("JSON repeaterMap", JSON.stringify(repeaterMap));
    return JSON.stringify(repeaterMap);
}

    // Output #2: Comma-separated column names string (columnNames)
    @api
    get columnNames() {
        const names = this.rows
            .map(row => row.Column_Name)
            .filter(name => !!name); // Remove empty/null names

        console.log('columnNames for formula filelds',names.join(','));
        return names.join(',');
    }

    // Restrict from adding New formula fields if total Column count is equal to 20 for data table

get maxFormulaFieldsAllowed() {
    const maxAllowed = 20 - this._rawPicklistOptions.length;
    return maxAllowed > 0 ? maxAllowed : 0; // Prevent negative values
}


get disableAddRow() {
    return this.rows.length >= this.maxFormulaFieldsAllowed;
}

get remainingFields() {
    const remaining = this.maxFormulaFieldsAllowed - this.rows.length;
    return remaining > 0 ? remaining : 0;
}


//Summary Fields Configurations

@track summaryRows = [
    {
      id: 1,
      SField: "",
      operation: "",
      Summary_Column_Name: ""
    }
  ];


  summaryTypeOptions = [
    { label: "SUM", value: "SUM" },
    { label: "AVG", value: "AVG" },
    { label: "MIN", value: "MIN" },
    { label: "MAX", value: "MAX" },
    { label: "COUNT", value: "COUNT" }
  ];

  handleSummaryChange(event) {
    const index = event.target.dataset.index;
    const fieldName = event.target.name;
    this.summaryRows[index][fieldName] = event.target.value;
    this.summaryRows = [...this.summaryRows];
}

addSummaryRow() {
    const id = this.summaryRows.length + 1;
    this.summaryRows = [...this.summaryRows, { id, SField: '', operation: '', Summary_Column_Name: '' }];
}

removeSummaryRow() {
    if (this.summaryRows.length > 1) {
        this.summaryRows = this.summaryRows.slice(0, -1);
    }
}

updateSummaryPicklist() {
    const formulaFields = this.rows
        .map(row => row.Column_Name)
        .filter(name =>
            !!name &&
            !this._picklistOptions.some(opt => opt.value === name) // Avoid duplicate with existing fields
        )
        .map(name => ({
            label: name,
            value: name
        }));

    const combined = [...this._picklistOptions];

    // Avoid duplicating formula fields in summaryPicklist
    formulaFields.forEach(formulaOption => {
        if (!combined.some(opt => opt.value === formulaOption.value)) {
            combined.push(formulaOption);
        }
    });

    this.summaryPicklist = combined;
}

@api
  get summaryFieldValues() {
    const summaryMap = {};
    this.summaryRows.forEach((row) => {

        
        const { Summary_Column_Name, SField, operation } = row;


        const values = this.columnNames.split(',').map(val => val.trim());
        let temp = SField;
       // console.log('Processing Summary SField:', SField);
          //console.log('Processing Summary SField:', JSON.stringify(this.columnNames));
        if(values.includes(temp)){
             const baseColumn = temp.replace(/\s+/g, '_'); // The new column to add
                //console.log('Processing Formula Field:', baseColumn);
                temp = `${baseColumn}__f`;
        }

        console.log('Processed SField:', temp);

      if (SField && operation) {
        // summaryMap[Summary_Column_Name] = `{${SField},${operation}}`;
        summaryMap[Summary_Column_Name] = `{${temp},${operation}}`;
      }
    });
    console.log("summaryMap", summaryMap);
    console.log("JSON summaryMap", JSON.stringify(summaryMap));
    return JSON.stringify(summaryMap);
  }
 
    //Validations Fields Configurations

    @track validationRows = [
    {
      id: 1,
      vField: "",
      vOperation: "",
      Validation_Value: "",
      validationError: ""
    }
  ];


 validationTypeOptions = [
    { label: "> Greater", value: "greater" },
    { label: "< Less", value: "less" },
    { label: "= Equal", value: "equal" },
    { label: ">= Greater or Equal", value: "greater_or_equal" },
    { label: "<= Less or Equal", value: "less_or_equal" },
    { label: "<> Not Equal", value: "not_equal" }
];

handleValidationChange(event) {
    const index = event.target.dataset.index;
    const fieldName = event.target.name;
    this.validationRows[index][fieldName] = event.target.value;
    this.validationRows = [...this.validationRows];
}

addValidationRow() {
    const id = this.validationRows.length + 1;
    this.validationRows = [...this.validationRows, { id, vField: '', vOperation: '', Validation_Value: '',validationError:''}];
}

removeValidationRow() {
    if (this.validationRows.length > 1) {
        this.validationRows = this.validationRows.slice(0, -1);
    }
}


@api
  get validationFieldValues() {
    const validationMap = {};
    this.validationRows.forEach((row) => {
      const { validationError, Validation_Value, vField, vOperation } = row;
      if (vField && vOperation) {
        validationMap[validationError] = `{${vField},${vOperation},${Validation_Value}}`;
      }
    });
    console.log("summaryMap", validationMap);
    console.log("JSON summaryMap", JSON.stringify(validationMap));
    return JSON.stringify(validationMap);
  }


      // This method is triggered by the "Next" button
    handleFlowUpdate() {

    let allValid = true;

    //Formula Builder Errors validation
    // Clear previous errors only for formula field group
    const inputs = this.template.querySelectorAll('[data-group="formula"]');
    inputs.forEach(input => input.setCustomValidity('')); // Reset all

    //Validate each row
    this.rows.forEach((row, index) => {
        const isAnySelected = row.fField || row.operator || row.sField || row.Column_Name;

        if (isAnySelected) {
            // Find matching inputs
            const fFieldInput = [...inputs].find(input => input.name === 'fField' && input.dataset.index == index);
            const operatorInput = [...inputs].find(input => input.name === 'operator' && input.dataset.index == index);
            const sFieldInput = [...inputs].find(input => input.name === 'sField' && input.dataset.index == index);
            const columnNameInput = [...inputs].find(input => input.name === 'Column_Name' && input.dataset.index == index);
            const manualInput = [...inputs].find(input => input.name === 'manualValue' && input.dataset.index == index);

            // Validate required fields
            if (!row.fField && fFieldInput) {
                fFieldInput.setCustomValidity('Required');
                fFieldInput.reportValidity();
                allValid = false;
            }
            if (!row.operator && operatorInput) {
                operatorInput.setCustomValidity('Required');
                operatorInput.reportValidity();
                allValid = false;
            }
            if (!row.sField && sFieldInput) {
                sFieldInput.setCustomValidity('Required');
                sFieldInput.reportValidity();
                allValid = false;
            }
            if (!row.Column_Name && columnNameInput) {
                columnNameInput.setCustomValidity('Required');
                columnNameInput.reportValidity();
                allValid = false;
            }

            // Extra: If "other" is selected, manualValue is required and must be a number
                    if (row.sField === 'other' && manualInput) {
                if (!row.manualValue) {
                    manualInput.setCustomValidity('Required');
                    manualInput.reportValidity();
                    allValid = false;
                } else if (isNaN(row.manualValue)) {
                    manualInput.setCustomValidity('Manual value must be a number');
                    manualInput.reportValidity();
                    allValid = false;
                } else {
                    manualInput.setCustomValidity(''); // Clear if valid
                }
            }
        }
    });


// Summary validation
const summaryInputs = this.template.querySelectorAll('[data-group="summary"]');

// Clear previous errors for summary inputs
summaryInputs.forEach(input => {
    input.setCustomValidity('');
});

// Validate each summary row
this.summaryRows.forEach((row, index) => {
    const isAnySelected = row.SField || row.operation || row.Summary_Column_Name;

    if (isAnySelected) {
        const sFieldInput = [...summaryInputs].find(input => input.name === 'SField' && input.dataset.index == index);
        const operationInput = [...summaryInputs].find(input => input.name === 'operation' && input.dataset.index == index);
        const columnNameInput = [...summaryInputs].find(input => input.name === 'Summary_Column_Name' && input.dataset.index == index);

        if (!row.SField && sFieldInput) {
            sFieldInput.setCustomValidity('Required');
            sFieldInput.reportValidity();
            allValid = false;
        }

        if (!row.operation && operationInput) {
            operationInput.setCustomValidity('Required');
            operationInput.reportValidity();
            allValid = false;
        }

        if (!row.Summary_Column_Name && columnNameInput) {
            columnNameInput.setCustomValidity('Required');
            columnNameInput.reportValidity();
            allValid = false;
        }
    }
});


// validation Errorrs checks

// Clear previous errors for validation section
const validationInputs = this.template.querySelectorAll('[data-group="validation"]');
validationInputs.forEach(input => input.setCustomValidity(''));

// Validate validation rows
this.validationRows.forEach((row, index) => {
    const isAnySelected = row.vField || row.vOperation || row.Validation_Value || row.validationError;

    if (isAnySelected) {
        const vFieldInput = [...validationInputs].find(input => input.name === 'vField' && input.dataset.index == index);
        const vOperationInput = [...validationInputs].find(input => input.name === 'vOperation' && input.dataset.index == index);
        const valueInput = [...validationInputs].find(input => input.name === 'Validation_Value' && input.dataset.index == index);
        const errorInput = [...validationInputs].find(input => input.name === 'validationError' && input.dataset.index == index);

        if (!row.vField && vFieldInput) {
            vFieldInput.setCustomValidity('Required');
            vFieldInput.reportValidity();
            allValid = false;
        }

        if (!row.vOperation && vOperationInput) {
            vOperationInput.setCustomValidity('Required');
            vOperationInput.reportValidity();
            allValid = false;
        }

        if (!row.Validation_Value && valueInput) {
            valueInput.setCustomValidity('Required');
            valueInput.reportValidity();
            allValid = false;
        } else if (valueInput && isNaN(Number(row.Validation_Value))) {
            valueInput.setCustomValidity('Must be a number');
            valueInput.reportValidity();
            allValid = false;
        }

        if (!row.validationError && errorInput) {
            errorInput.setCustomValidity('Required');
            errorInput.reportValidity();
            allValid = false;
        }
    }
});

    // Final check
    if (!allValid) {
        console.warn('Validation failed. Flow will not proceed.');
        return;
    }

        this.dispatchEvent(new FlowAttributeChangeEvent('repeaterValues', this.repeaterValues));
        this.dispatchEvent(new FlowAttributeChangeEvent('summaryFieldValues', this.summaryFieldValues));
        this.dispatchEvent(new FlowAttributeChangeEvent('validationFieldValues', this.validationFieldValues));
        this.dispatchEvent(new FlowAttributeChangeEvent('columnNames', this.columnNames));

        this.dispatchEvent(new FlowNavigationNextEvent());
    }

    // This method is triggered by the "Back" button
    handleGoBack() {
        this.dispatchEvent(new FlowNavigationBackEvent());
    }
}