import { LightningElement, track, api } from 'lwc';

export default class FormulaRepeater extends LightningElement {

    // Picklist options, input from Flow as JSON string
    _rawPicklistOptions;
    _picklistOptions = [];

    @api
    set picklistOptions(value) {
        if (value && Array.isArray(value)) {
            this._rawPicklistOptions = value;
            console.log(' this._rawPicklistOptions ',JSON.stringify( this._rawPicklistOptions ));

             const NumberTypeFilteredValues = value.filter(item => 
            item.type === 'DOUBLE' || item.type === 'NUMBER'
        );

            this._picklistOptions = NumberTypeFilteredValues.map(item => {
                return {
                    label: item.label,
                    value: item.name
                };
            });

            console.log('Processed Picklist Options: ', this._picklistOptions);
        }
    }

    get picklistOptions() {
        return this._picklistOptions;
    }


// Formula Fields Configurations
@track rows = [
    {
        id: 1,
        fField: '',
        operator: '',  // Use 'operator' consistently
        sField: '',
        Column_Name: '',  // Corrected the misspelling
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
        }
    ];
}

removeRow() {
    if (this.rows.length > 1) {
        this.rows = this.rows.slice(0, -1);
    }
}

handleChange(event) {
    const index = event.target.dataset.index;
    const fieldName = event.target.name;
    this.rows[index][fieldName] = event.target.value;
    this.rows = [...this.rows];
}

@api
get repeaterValues() {
    const repeaterMap = {};
    this.rows.forEach((row) => {
        const { Column_Name, fField, operator, sField } = row;  // Corrected Column_Name
        if (sField && operator && fField) {
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

@api
  get summaryFieldValues() {
    const summaryMap = {};
    this.summaryRows.forEach((row) => {
      const { Summary_Column_Name, SField, operation } = row;
      if (SField && operation) {
        summaryMap[Summary_Column_Name] = `{${SField},${operation}}`;
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
}