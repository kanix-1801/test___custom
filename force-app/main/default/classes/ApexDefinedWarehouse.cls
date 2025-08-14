// Apex-Defined Variable Sample Descriptor Class
public with sharing class ApexDefinedWarehouse{
 
    // @AuraEnabled annotation exposes the methods to Lightning Components and Flows
    @AuraEnabled
    public Date Billing_End_Date;
    @AuraEnabled
    public Date Billing_Start_Date;
    @AuraEnabled
    public Boolean Current_Date_In_Reservation_Range;
    @AuraEnabled
    public String Customer;
    @AuraEnabled
    public String Description;
    @AuraEnabled
    public Decimal Discount_Percent;
    @AuraEnabled
    public Boolean Fixed_Monthly_Price;
    @AuraEnabled
    public Boolean Future_Reserved;
    @AuraEnabled
    public String Opportunity;
    @AuraEnabled
    public String Orders;
    @AuraEnabled
    public Boolean Order_Without_End_Date;
    @AuraEnabled
    public Decimal Price;
    @AuraEnabled
    public Integer Quantity;
    @AuraEnabled
    public Date Reservation_End_Date;
    @AuraEnabled
    public Date Reservation_Start_Date;
    @AuraEnabled
    public String Reserved_Status;
    @AuraEnabled
    public Decimal Total_Line_Sum;
    @AuraEnabled
    public Decimal Total_Line_Sum_Plus_VAT;
    @AuraEnabled
    public String Warehouse;
    @AuraEnabled
    public Decimal Warehouse_Volume_m3;
    @AuraEnabled
    public String Branch;
    @AuraEnabled
    public String Name;
    @AuraEnabled
    public String Priority_Code;
    @AuraEnabled
    public Decimal Volume_m3;
    @AuraEnabled
    public String Dimensions;
    @AuraEnabled
    public String Accessibility;
    @AuraEnabled
    public String Building;
    @AuraEnabled
    public String Wing;
    @AuraEnabled
    public String Door;
    @AuraEnabled
    public Date ExitDate;
    @AuraEnabled
    public String Warehouse_Price_List;
    @AuraEnabled
    public String tempId;
    
    // Define the structure of the Apex-Defined Variable
    public ApexDefinedWarehouse(
    Date Billing_End_Date,  
    Date Billing_Start_Date,    
    Boolean Current_Date_In_Reservation_Range,  
    String Customer,    
    String Description, 
    Decimal Discount_Percent,   
    Boolean Fixed_Monthly_Price,    
    Boolean Future_Reserved,    
    String Opportunity, 
    String Orders,  
    Boolean Order_Without_End_Date, 
    Decimal Price,  
    Date Reservation_End_Date,  
    Date Reservation_Start_Date,    
    String Reserved_Status, 
    Decimal Total_Line_Sum, 
    Decimal Total_Line_Sum_Plus_VAT,    
    String Warehouse,   
    Decimal Warehouse_Volume_m3,
    String Branch,
    String Name,
    String Priority_Code,
    Decimal Volume_m3,
    String Dimensions,
    String Accessibility,
    String Building,
    String Wing,
    String Door,
    String Warehouse_Price_List,
    Date ExitDate,
    String tempId
    ) {
    this.Billing_End_Date = Billing_End_Date;
    this.Billing_Start_Date = Billing_Start_Date;
    this.Current_Date_In_Reservation_Range = Current_Date_In_Reservation_Range;
    this.Customer = Customer;
    this.Description = Description;
    this.Discount_Percent = Discount_Percent;
    this.Fixed_Monthly_Price = Fixed_Monthly_Price;
    this.Future_Reserved = Future_Reserved;
    this.Opportunity = Opportunity;
    this.Orders = Orders;
    this.Order_Without_End_Date = Order_Without_End_Date;
    this.Price = Price;
    this.Reservation_End_Date = Reservation_End_Date;
    this.Reservation_Start_Date = Reservation_Start_Date;
    this.Reserved_Status = Reserved_Status;
    this.Total_Line_Sum = Total_Line_Sum;
    this.Total_Line_Sum_Plus_VAT = Total_Line_Sum_Plus_VAT;
    this.Warehouse = Warehouse;
    this.Warehouse_Volume_m3 = Warehouse_Volume_m3;
    this.Branch = Branch;
    this.Name = Name;
    this.Priority_Code = Priority_Code;
    this.Volume_m3 = Volume_m3;
    this.Dimensions = Dimensions;
    this.Accessibility = Accessibility;
    this.Building = Building;
    this.Wing = Wing;
    this.Door = Door;
    this.ExitDate = ExitDate;
    this.Warehouse_Price_List = Warehouse_Price_List;
    this.tempId = tempId;
    }
 
    // Required no-argument constructor
    public ApexDefinedWarehouse() {}
}