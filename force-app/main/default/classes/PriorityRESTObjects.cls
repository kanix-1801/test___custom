/**
 * Created by chana.landau on 01/03/2022.
 */

public with sharing class PriorityRESTObjects {


    public class UpdateResponse {
        public String EXTCUST;
        public String CUSTDES;
        public Datetime UDATE;
        public String ADDRESS;
        public String ADDRESS2;
        public String ADDRESS3;
        public String CITY;
        public String PHONE1;
        public String PHONE2;
        public String PHONE3;
        public String PHONE4;
        public String SHIPPER_PHONE;
        public String EMAIL;
        public String ID;
        public String ORDI;
        public String DOCDATE;
        public String CUST;
        public String SUCCESS;
        public String STATDES;
        public String DETAILS;
        public String STREET;
        public String HOUSE;
        public String POBOX;
        public String APPT;
        public String ZIP;
        public String BIRTHDATE;
        public String CUSTNAME;
        public String DOCNUM;
        public String UPDDOCNO;
        public String PASSWORD;
        public String SOURCELOC;
        public String PROMOTION;
        public String FNCREF;
        public String FNCREF2;
        public String SUM1;
        public String SUM2;
        public String SUM3;
        public String CASHEXCEPTFLAG;
        public String CUSTNOTETYPEDES;
        public String WARHSNAME;
        public String TOWARHSNAME;
        public String LOCNAME;
        public String AGENTCODE;
        public String TOPICCODE;
        public String DOCNO;
        public String STIME;
        public String DOCCODE;
        public String TILLDATE;
        public String ETIME;
        public String CUSTNOTE;
        public String USERLOGIN;
        public String BRANCHNAME;
        public String CAMPAIGNCODE;
        public String CONTACTNAME;
        public String FIRMNAME;
        public String CTYPECODE;
        public String CTYPE2CODE;
        public String PAYCUSTNAME;
        public String SUPNAME;
        public String ORDNAME;
        public String BOOKNUM;
        public String SUPORDNUM;
        public String CURDATE;
        public String TYPECODE;
        public String EXCEPNOTE;
        public String SHAREDCUST;
        public String CURCODE;
        public String EDOCUMENTS;
        public String ACCNAME;
        public String SITEPHONE;
        public String QDOCNO;
        public String SERNUM;
        public String PDATE;
        public String CALLTYPECODE;
        public String SYMCODE;
        public String MALFCODE;
        public String PRIORITY;
        public String ZONECODE;
        public String METERREADING;
        public String CUSTSTATDES;
        public String FNCNUM;
        public String FNCPATNAME;
        public String FNCDATE;
        public String DEBIT;
        public String COSTCNAME;
        public String IVCOUNT;
        public String PROJDOCNO;
        public String SITENET;
        public String SITEVAT;
        public String SITEGROSS;
        public String CASHNAME;
        public String TXID;
        public String COMMISSTRANSACT;
        public String LOADCODE;
        public String LINE;
        public String INDICATOR;
        public String SUBJCODE;
        public String EXTENSION;
        public String MOVER;
        public String EXITDATE;
        public String CREDITNUM;
        public String CPROFNUM;
        public String CUBEORDER;
        public String DATE2;
        public String FTIME;
        public String TOTIME;
        public String PRIT_KWRD;
        public String PRIT_BILLFREQUENCY;
        public String PRIT_OYEARDISCOUNT;
        public String PRIT_XIIMONTHFREE;
        public String PRIT_AGENTPHONE2;
        public String PRIT_SFORDNAME;
        public String PRIT_STCODE;
        public String PRIT_DETAILS;
        public String PRIT_SHIPREMARK;
        public String NOLOAD;
        public String DOC;
        public String DOCLOAD;
        public String ORDNAME2;

    }

    public class AccountRequest {

        public String LOADCODE;
        public string CUSTNAME;
        public string EXTCUST;
        public string ID;
        public string CUSTDES;
        public string PHONE1;
        public string PHONE2;
        public string PHONE3;
        public string EMAIL;
        public string ADDRESS;
        public string CITY;
        public string ZIP;
        public string CUSTSTATDES;
        public List<PritCustspecSubform> PRIT_CUSTSPEC_SUBFORM;
        public List<PritLoadpaySubform> PRIT_LOADPAY_SUBFORM;
        public List<PritInterfaceSubform> PRIT_INTERFACE_SUBFORM;

    }

    public class PritCustspecSubform {

        public Decimal SPECNUM;
        public String SPECVALUE;
    }
    public class PritLoadpaySubform {
        public String PAYTYPE;
        public String CCUID;
        public String CARDNUM;
        public String CARDVALID;
        public String BANK;
        public String BANKBRANCH;
        public String PRIT_IDNUM;
    }

    public class ContactRequest {

        public String CUSTNAME;
        public String EXTCUST;
        public String LOADCODE;
        public List<PritCustpersonnelSubform> PRIT_CUSTPERSONNEL_SUBFORM;
        public List<PritInterfaceSubform> PRIT_INTERFACE_SUBFORM;

    }

    public class PritCustpersonnelSubform {

        public String PRIT_EXTERNALPHONE;
        public String HOMEPHONE;
        public String NAME;
        public String CELLPHONE;
        public String EMAIL;
        public String PRIT_ASSISTANTNAME;
        public String MAINPHONE;
        public String TIVFLAG;
        public String CIVFLAG;
        public String GUARANTEE;
        public String PROFESSION;
        public String POSITIONDES;
        public String STATDES;

    }

    public class OrderRequest {
        public String ID;
        public String CUSTDES;
        public String CUSTSTATDES;
        public String PHONE1;
        public String PHONE2;
        public String PHONE3;
        public String EMAIL;
        public String ADDRESS;
        public String CITY;
        public String ZIP;
        public String LOADCODE;
        public String CUSTNAME;
        public String EXTCUST;
        public String UPDDOCNO;
        public String PRIT_SFORDNAME;
        public String STATDES;
        public String DOCDATE;
        public String PRIT_BILLFREQUENCY;
        public String PRIT_OYEARDISCOUNT;
        public String PRIT_XIIMONTHFREE;
        public String DETAILS;
        public String PRIT_STCODE;
        public String TYPECODE;
        public String PDATE;
        public String PRIT_DETAILS;
        public String AGENTCODE;
        public String PRIT_AGENTPHONE2;
        public String WARHSNAME;
        public String PRIT_SHIPREMARK;
        public String PRIT_DISCOUNTFLAG;
        public List<PritCustpersonnelSubform> PRIT_CUSTPERSONNEL_SUBFORM;
        public List<PritDoclineSubform> PRIT_DOCLINE_SUBFORM;
        public List<PritInterfaceSubform> PRIT_INTERFACE_SUBFORM;
        public List<PritCustspecSubform> PRIT_CUSTSPEC_SUBFORM;
        public List<PritLoadpaySubform> PRIT_LOADPAY_SUBFORM;

    }

    public class PritDoclineSubform {

        public String PARTNAME;
        public String PDES;
        public Decimal QUANT;
        public Decimal PRICE;
        public String PRIT_MONCHARGECONST;
        public String DUEDATE;
        public String PRIT_BILLINGENDDATE;
        public Decimal DISCOUNT;
        public String REMARK;
        public String SERNUM;
        public String PRIT_CUSTREMARKS;
        public String PRIT_CLOSEDBOOL;
    }

    public class PritInterfaceSubform {
        public String EXECUTE;
    }
}