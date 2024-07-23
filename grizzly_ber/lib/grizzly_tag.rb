# frozen_string_literal: true

module GrizzlyTag
  def self.new_tag(params)
    params[:format] ||= :binary
    params
  end

  def self.all
    @@tags
  end

  def self.tagged(tag)
    @@tags.find{|o| o[:tag] == tag}
  end

  def self.named(name)
    @@tags.find{|o| o[:name] == name}
  end

  def self.tag_from_name(name)
    tag = self.named(name)
    tag &&= tag[:tag]
  end

  @@tags = [
    #Tags taken from EMV 4.3 Book 3 Annex A
    new_tag(:tag => "5F57", :name => "Account Type", :description => "Indicates the type of account selected on the terminal, coded as specified in Annex G"),
    new_tag(:tag => "9F01", :name => "Acquirer Identifier", :description => "Uniquely identifies the acquirer within each payment system"),
    new_tag(:tag => "9F40", :name => "Additional Terminal Capabilities", :description => "Indicates the data input and output capabilities of the terminal"),
    new_tag(:tag => "81",   :name => "Amount, Authorised (Binary)", :description => "Authorised amount of the transaction (excluding adjustments)"),
    new_tag(:tag => "9F02", :name => "Amount, Authorised (Numeric)", :description => "Authorised amount of the transaction (excluding adjustments)"),
    new_tag(:tag => "9F04", :name => "Amount, Other (Binary)", :description => "Secondary amount associated with the transaction representing a cashback amount"),
    new_tag(:tag => "9F03", :name => "Amount, Other (Numeric)", :description => "Secondary amount associated with the transaction representing a cashback amount"),
    new_tag(:tag => "9F3A", :name => "Amount, Reference Currency", :description => "Authorised amount expressed in the reference currency"),
    new_tag(:tag => "9F26", :name => "Application Cryptogram", :description => "Cryptogram returned by the ICC in response of the GENERATE AC command"),
    new_tag(:tag => "9F42", :name => "Application Currency Code", :description => "Indicates the currency in which the account is managed according to ISO 4217"),
    new_tag(:tag => "9F44", :name => "Application Currency Exponent", :description => "Indicates the implied position of the decimal point from the right of the amount represented according to ISO 4217"),
    new_tag(:tag => "9F05", :name => "Application Discretionary Data", :description => "Issuer or payment system specified data relating to the application"),
    new_tag(:tag => "5F25", :name => "Application Effective Date", :description => "Date from which the application may be used"),
    new_tag(:tag => "5F24", :name => "Application Expiration Date", :description => "Date after which application expires"),
    new_tag(:tag => "94",   :name => "Application File Locator (AFL)", :description => "Indicates the location (SFI, range of records) of the AEFs related to a given application"),
    new_tag(:tag => "4F",   :name => "Application Dedicated File (ADF) Name", :description => "Identifies the application as described in ISO/IEC 7816-5"),
    new_tag(:tag => "9F06", :name => "Application Identifier (AID) – terminal", :description => "Identifies the application as described in ISO/IEC 7816-5"),
    new_tag(:tag => "82",   :name => "Application Interchange Profile", :description => "Indicates the capabilities of the card to support specific functions in the application"),
    new_tag(:tag => "50",   :name => "Application Label", :format => :string, :description => "Mnemonic associated with the AID according to ISO/IEC 7816-5"),
    new_tag(:tag => "9F12", :name => "Application Preferred Name", :description => "Preferred mnemonic associated with the AID"), #Note: This makes use of ISO 8859 additions to ASCII. Not using string format because we need to look at another tag to know which code table to use.
    new_tag(:tag => "5A",   :name => "Application Primary Account Number (PAN)", :description => "Valid cardholder account number"),
    new_tag(:tag => "5F34", :name => "Application Primary Account Number (PAN) Sequence Number", :description => "Identifies and differentiates cards with the same PAN"),
    new_tag(:tag => "87",   :name => "Application Priority Indicator", :description => "Indicates the priority of a given application or group of applications in a directory"),
    new_tag(:tag => "9F3B", :name => "Application Reference Currency", :description => "1-4 currency codes used between the terminal and the ICC when the Transaction Currency Code is different from the Application Currency Code; each code is 3 digits according to ISO 4217"),
    new_tag(:tag => "9F43", :name => "Application Reference Currency Exponent", :description => "Indicates the implied position of the decimal point from the right of the amount, for each of the 1-4 reference currencies represented according to ISO 4217"),
    new_tag(:tag => "70",   :name => "Application Template", :description => "Contains one or more data objects relevant to an application directory entry according to ISO/IEC 7816-5"),
    new_tag(:tag => "9F36", :name => "Application Transaction Counter (ATC)", :description => "Counter maintained by the application in the ICC (incrementing the ATC is managed by the ICC)"),
    new_tag(:tag => "9F07", :name => "Application Usage Control", :description => "Indicates issuer’s specified restrictions on the geographic usage and services allowed for the application"),
    new_tag(:tag => "9F08", :name => "Application Version Number", :description => "Version number assigned by the payment system for the application"),
    new_tag(:tag => "9F09", :name => "Application Version Number", :description => "Version number assigned by the payment system for the application"),
    new_tag(:tag => "89",   :name => "Authorisation Code", :description => "Value generated by the authorisation authority for an approved transaction"),
    new_tag(:tag => "8A",   :name => "Authorisation Response Code", :description => "Code that defines the disposition of a message"),
    new_tag(:tag => "5F54", :name => "Bank Identifier Code (BIC)", :description => "Uniquely identifies a bank as defined in ISO 9362."),
    new_tag(:tag => "8C",   :name => "Risk Management Data Object List 1 (CDOL1)", :description => "List of data objects (tag and length) to be passed to the ICC in the first GENERATE AC command"),
    new_tag(:tag => "8D",   :name => "Card Risk Management Data Object List 2 (CDOL2)", :description => "List of data objects (tag and length) to be passed to the ICC in the second GENERATE AC command"),
    new_tag(:tag => "5F20", :name => "Cardholder Name", :format => :string, :description => "Indicates cardholder name according to ISO 7813"),
    new_tag(:tag => "9F0B", :name => "Cardholder Name Extended", :format => :string, :description => "Indicates the whole cardholder name when greater than 26 characters using the same coding convention as in ISO 7813"),
    new_tag(:tag => "8E",   :name => "Cardholder Verification Method (CVM) List", :description => "Identifies a method of verification of the cardholder supported by the application"),
    new_tag(:tag => "9F34", :name => "Cardholder Verification Method (CVM) Results", :description => "Indicates the results of the last CVM performed"),
    new_tag(:tag => "8F",   :name => "Certification Authority Public Key Index", :description => "Identifies the certification authority’s public key in conjunction with the RID"),
    new_tag(:tag => "9F22", :name => "Certification Authority Public Key Index", :description => "Identifies the certification authority’s public key in conjunction with the RID"),
    new_tag(:tag => "83",   :name => "Command Template", :description => "Identifies the data field of a command message"),
    new_tag(:tag => "9F27", :name => "Cryptogram Information Data", :description => "Indicates the type of cryptogram and the actions to be performed by the terminal"),
    new_tag(:tag => "9F45", :name => "Data Authentication Code", :description => "An issuer assigned value that is retained by the terminal during the verification process of the Signed Static Application Data"),
    new_tag(:tag => "84",   :name => "Dedicated File (DF) Name", :description => "Identifies the name of the DF as described in ISO/IEC 7816-4"),
    new_tag(:tag => "9D",   :name => "Directory Definition File (DDF) Name", :description => "Identifies the name of a DF associated with a directory"),
    new_tag(:tag => "73",   :name => "Directory Discretionary Template", :description => "Issuer discretionary part of the directory according to ISO/IEC 7816-5"),
    new_tag(:tag => "9F49", :name => "Dynamic Data Authentication Data Object List (DDOL)", :description => "List of data objects (tag and length) to be passed to the ICC in the INTERNAL AUTHENTICATE command"),
    new_tag(:tag => "BF0C", :name => "File Control Information (FCI) Issuer Discretionary Data", :description => "Issuer discretionary part of the FCI"),
    new_tag(:tag => "A5",   :name => "File Control Information (FCI) Proprietary Template", :description => "Identifies the data object proprietary to this specification in the FCI template according to ISO/IEC 7816-4"),
    new_tag(:tag => "6F",   :name => "File Control Information (FCI) Template", :description => "Identifies the FCI template according to ISO/IEC 7816-4"),
    new_tag(:tag => "9F4C", :name => "ICC Dynamic Number", :description => "Time-variant number generated by the ICC, to be captured by the terminal"),
    new_tag(:tag => "9F2D", :name => "Integrated Circuit Card (ICC) PIN Encipherment Public Key Certificate", :description => "ICC PIN Encipherment Public Key certified by the issuer"),
    new_tag(:tag => "9F2E", :name => "Integrated Circuit Card (ICC) PIN Encipherment Public Key Exponent", :description => "ICC PIN Encipherment Public Key Exponent used for PIN encipherment"),
    new_tag(:tag => "9F2F", :name => "Integrated Circuit Card (ICC) PIN Encipherment Public Key Remainder", :description => "Remaining digits of the ICC PIN Encipherment Public Key Modulus"),
    new_tag(:tag => "9F46", :name => "Integrated Circuit Card (ICC) Public Key Certificate", :description => "ICC Public Key certified by the issuer"),
    new_tag(:tag => "9F47", :name => "Integrated Circuit Card (ICC) Public Key Exponent", :description => "ICC Public Key Exponent used for the verification of the Signed Dynamic Application Data"),
    new_tag(:tag => "9F48", :name => "Integrated Circuit Card (ICC) Public Key Remainder", :description => "Remaining digits of the ICC Public Key Modulus"),
    new_tag(:tag => "9F1E", :name => "Interface Device (IFD) Serial Number", :format => :string, :description => "Unique and permanent serial number assigned to the IFD by the manufacturer"),
    new_tag(:tag => "5F53", :name => "International Bank Account Number (IBAN)", :description => "Uniquely identifies the account of a customer at a financial institution as defined in ISO 13616."),
    new_tag(:tag => "9F0D", :name => "Issuer Action Code - Default", :description => "Specifies the issuer’s conditions that cause a transaction to be rejected if it might have been approved online, but the terminal is unable to process the transaction online"),
    new_tag(:tag => "9F0E", :name => "Issuer Action Code - Denial", :description => "Specifies the issuer’s conditions that cause the denial of a transaction without attempt to go online"),
    new_tag(:tag => "9F0F", :name => "Issuer Action Code - Online", :description => "Specifies the issuer’s conditions that cause a transaction to be transmitted online"),
    new_tag(:tag => "9F10", :name => "Issuer Application Data", :description => "Contains proprietary application data for transmission to the issuer in an online transaction."),
    new_tag(:tag => "91",   :name => "Issuer Authentication Data", :description => "Data sent to the ICC for online issuer authentication"),
    new_tag(:tag => "9F11", :name => "Issuer Code Table Index", :description => "Indicates the code table according to ISO/IEC 8859 for displaying the Application Preferred Name"),
    new_tag(:tag => "5F28", :name => "Issuer Country Code", :description => "Indicates the country of the issuer according to ISO 3166"),
    new_tag(:tag => "5F55", :name => "Issuer Country Code (alpha2 format)", :description => "Indicates the country of the issuer as defined in ISO 3166 (using a 2 character alphabetic code)"),
    new_tag(:tag => "5F56", :name => "Issuer Country Code (alpha3 format)", :description => "Indicates the country of the issuer as defined in ISO 3166 (using a 3 character alphabetic code)"),
    new_tag(:tag => "42",   :name => "Issuer Identification Number (IIN)", :description => "The number that identifies the major industry and the card issuer and that forms the first part of the Primary Account Number (PAN)"),
    new_tag(:tag => "90",   :name => "Issuer Public Key Certificate", :description => "Issuer public key certified by a certification authority"),
    new_tag(:tag => "9F32", :name => "Issuer Public Key Exponent", :description => "Issuer public key exponent used for the verification of the Signed Static Application Data and the ICC Public Key Certificate"),
    new_tag(:tag => "92",   :name => "Issuer Public Key Remainder", :description => "Remaining digits of the Issuer Public Key Modulus"),
    new_tag(:tag => "86",   :name => "Issuer Script Command", :description => "Contains a command for transmission to the ICC"),
    new_tag(:tag => "9F18", :name => "Issuer Script Identifier", :description => "Identification of the Issuer Script"),
    new_tag(:tag => "71",   :name => "Issuer Script Template 1", :description => "Contains proprietary issuer data for transmission to the ICC before the second GENERATE AC command"),
    new_tag(:tag => "72",   :name => "Issuer Script Template 2", :description => "Contains proprietary issuer data for transmission to the ICC after the second GENERATE AC command"),
    new_tag(:tag => "5F50", :name => "Issuer URL", :format => :string, :description => "The URL provides the location of the Issuer’s Library Server on the Internet."),
    new_tag(:tag => "5F2D", :name => "Language Preference", :format => :string, :description => "1-4 languages stored in order of preference, each represented by 2 alphabetical characters according to ISO 639"),
    new_tag(:tag => "9F13", :name => "Last Online Application Transaction Counter (ATC) Register", :description => "ATC value of the last transaction that went online"),
    new_tag(:tag => "9F4D", :name => "Log Entry", :description => "Provides the SFI of the Transaction Log file and its number of records"),
    new_tag(:tag => "9F4F", :name => "Log Format", :description => "List (in tag and length format) of data objects representing the logged data elements that are passed to the terminal when a transaction log record is read"),
    new_tag(:tag => "9F14", :name => "Lower Consecutive Offline Limit", :description => "Issuer-specified preference for the maximum number of consecutive offline transactions for this ICC application allowed in a terminal with online capability"),
    new_tag(:tag => "9F15", :name => "Merchant Category Code", :description => "Classifies the type of business being done by the merchant, represented according to ISO 8583:1993 for Card Acceptor Business Code"),
    new_tag(:tag => "9F16", :name => "Merchant Identifier", :format => :string, :description => "When concatenated with the Acquirer Identifier, uniquely identifies a given merchant"),
    new_tag(:tag => "9F4E", :name => "Merchant Name and Location", :format => :string, :description => "Indicates the name and location of the merchant"),
    new_tag(:tag => "9F17", :name => "Personal Identification Number (PIN) Try Counter", :description => "Number of PIN tries remaining"),
    new_tag(:tag => "9F39", :name => "Point-of-Service (POS) Entry Mode", :description => "Indicates the method by which the PAN was entered, according to the first two digits of the ISO 8583:1987 POS Entry Mode"),
    new_tag(:tag => "9F38", :name => "Processing Options Data Object List (PDOL)", :description => "Contains a list of terminal resident data objects (tags and lengths) needed by the ICC in processing the GET PROCESSING OPTIONS command"),
    new_tag(:tag => "70",   :name => "READ RECORD Response Message Template", :description => "Contains the contents of the record read. (Mandatory for SFIs 1-10. Response messages for SFIs 11-30 are outside the scope of EMV, but may use template '70')"),
    new_tag(:tag => "80",   :name => "Response Message Template Format 1", :description => "Contains the data objects (without tags and lengths) returned by the ICC in response to a command"),
    new_tag(:tag => "77",   :name => "Response Message Template Format 2", :description => "Contains the data objects (with tags and lengths) returned by the ICC in response to a command"),
    new_tag(:tag => "5F30", :name => "Service Code", :description => "Service code as defined in ISO/IEC 7813 for track 1 and track 2"),
    new_tag(:tag => "88",   :name => "Short File Identifier (SFI)", :description => "Identifies the AEF referenced in commands related to a given ADF or DDF. It is a binary data object having a value in the range 1 to 30 and with the three high order bits set to zero."),
    new_tag(:tag => "9F4B", :name => "Signed Dynamic Application Data", :description => "Digital signature on critical application parameters for DDA or CDA"),
    new_tag(:tag => "93",   :name => "Signed Static Application Data", :description => "Digital signature on critical application parameters for SDA"),
    new_tag(:tag => "9F4A", :name => "Static Data Authentication Tag List", :description => "List of tags of primitive data objects defined in this specification whose value fields are to be included in the Signed Static or Dynamic Application Data"),
    new_tag(:tag => "9F33", :name => "Terminal Capabilities", :description => "Indicates the card data input, CVM, and security capabilities of the terminal"),
    new_tag(:tag => "9F1A", :name => "Terminal Country Code", :description => "Indicates the country of the terminal, represented according to ISO 3166"),
    new_tag(:tag => "9F1B", :name => "Terminal Floor Limit", :description => "Indicates the floor limit in the terminal in conjunction with the AID"),
    new_tag(:tag => "9F1C", :name => "Terminal Identification", :format => :string, :description => "Designates the unique location of a terminal at a merchant"),
    new_tag(:tag => "9F1D", :name => "Terminal Risk Management Data", :description => "Application-specific value used by the card for risk management purposes"),
    new_tag(:tag => "9F35", :name => "Terminal Type", :description => "Indicates the environment of the terminal, its communications capability, and its operational control"),
    new_tag(:tag => "95",   :name => "Terminal Verification Results", :description => "Status of the different functions as seen from the terminal"),
    new_tag(:tag => "9F1F", :name => "Track 1 Discretionary Data", :description => "Discretionary part of track 1 according to ISO/IEC 7813"),
    new_tag(:tag => "9F20", :name => "Track 2 Discretionary Data", :description => "Discretionary part of track 2 according to ISO/IEC 7813"),
    new_tag(:tag => "57",   :name => "Track 2 Equivalent Data", :description => "Contains the data elements of track 2 according to ISO/IEC 7813, excluding start sentinel, end sentinel, and Longitudinal Redundancy Check (LRC)"),
    new_tag(:tag => "97",   :name => "Transaction Certificate Data Object List (TDOL)", :description => "List of data objects (tag and length) to be used by the terminal in generating the TC Hash Value"),
    new_tag(:tag => "98",   :name => "Transaction Certificate (TC) Hash Value", :description => "Result of a hash function specified in Book 2, Annex B3.1"),
    new_tag(:tag => "5F2A", :name => "Transaction Currency Code", :description => "Indicates the currency code of the transaction according to ISO 4217"),
    new_tag(:tag => "5F36", :name => "Transaction Currency Exponent", :description => "Indicates the implied position of the decimal point from the right of the transaction amount represented according to ISO 4217"),
    new_tag(:tag => "9A",   :name => "Transaction Date", :description => "Local date that the transaction was authorised"),
    new_tag(:tag => "99",   :name => "Transaction Personal Identification Number (PIN) Data", :description => "Data entered by the cardholder for the purpose of the PIN verification"),
    new_tag(:tag => "9F3C", :name => "Transaction Reference Currency Code", :description => "Code defining the common currency used by the terminal in case the Transaction Currency Code is different from the Application Currency Code"),
    new_tag(:tag => "9F3D", :name => "Transaction Reference Currency Exponent", :description => "Indicates the implied position of the decimal point from the right of the transaction amount, with the Transaction Reference Currency Code represented according to ISO 4217"),
    new_tag(:tag => "9F41", :name => "Transaction Sequence Counter", :description => "Counter maintained by the terminal that is incremented by one for each transaction"),
    new_tag(:tag => "9B",   :name => "Transaction Status Information", :description => "Indicates the functions performed in a transaction"),
    new_tag(:tag => "9F21", :name => "Transaction Time", :description => "Local time that the transaction was authorised"),
    new_tag(:tag => "9C",   :name => "Transaction Type", :description => "Indicates the type of financial transaction, represented by the first two digits of the ISO 8583:1987 Processing Code. The actual values to be used for the Transaction Type data element are defined by the relevant payment system"),
    new_tag(:tag => "9F37", :name => "Unpredictable Number", :description => "Value to provide variability and uniqueness to the generation of a cryptogram"),
    new_tag(:tag => "9F23", :name => "Upper Consecutive Offline Limit", :description => "Issuer-specified preference for the maximum number of consecutive offline transactions for this ICC application allowed in a terminal without online capability"),
    new_tag(:tag => "9F5B", :name => "Issuer Script Results", :description => "Indicates the results of Issuer Script processing. When the reader/terminal transmits this data element to the acquirer, in this version of Kernel 3, it is acceptable that only byte 1 is transmitted, although it is preferable for all five bytes to be transmitted."),
  ]
end
