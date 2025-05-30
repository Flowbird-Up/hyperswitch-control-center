let domain = "payment_attempts"

type paymentAttemptObject = {
  payment_id: string,
  merchant_id: string,
  status: string,
  amount: float,
  currency: string,
  amount_captured: float,
  customer_id: string,
  description: string,
  return_url: string,
  connector_id: string,
  statement_descriptor_name: string,
  statement_descriptor_suffix: string,
  created_at: int,
  modified_at: int,
  last_synced: int,
  setup_future_usage: string,
  off_session: string,
  client_secret: string,
  active_attempt_id: string,
  business_country: string,
  business_label: string,
  attempt_count: int,
  sign_flag: int,
  timestamp: string,
  confirm: bool,
  multiple_capture_count: int,
  attempt_id: string,
  save_to_locker: string,
  connector: string,
  error_message: string,
  offer_amount: string,
  surcharge_amount: string,
  tax_amount: string,
  payment_method_id: string,
  payment_method: string,
  connector_transaction_id: string,
  capture_method: string,
  capture_on: string,
  authentication_type: string,
  cancellation_reason: string,
  amount_to_capture: string,
  mandate_id: string,
  payment_method_type: string,
  payment_experience: string,
  error_reason: string,
  amount_capturable: string,
  merchant_connector_id: string,
  net_amount: string,
  unified_code: string,
  unified_message: string,
  client_source: string,
  client_version: string,
  profile_id: string,
  organization_id: string,
}

type cols =
  | PaymentId
  | MerchantId
  | Status
  | Amount
  | Currency
  | AmountCaptured
  | CustomerId
  | Description
  | ReturnUrl
  | ConnectorId
  | StatementDescriptorName
  | StatementDescriptorSuffix
  | CreatedAt
  | ModifiedAt
  | LastSynced
  | SetupFutureUsage
  | OffSession
  | ClientSecret
  | ActiveAttemptId
  | BusinessCountry
  | BusinessLabel
  | AttemptCount
  | SignFlag
  | Timestamp
  | Confirm
  | MultipleCaptureCount
  | AttemptId
  | SaveToLocker
  | Connector
  | ErrorMessage
  | OfferAmount
  | SurchargeAmount
  | TaxAmount
  | PaymentMethodId
  | PaymentMethod
  | ConnectorTransactionId
  | CaptureMethod
  | CaptureOn
  | AuthenticationType
  | CancellationReason
  | AmountToCapture
  | MandateId
  | PaymentMethodType
  | PaymentExperience
  | ErrorReason
  | AmountCapturable
  | MerchantConnectorId
  | NetAmount
  | UnifiedCode
  | UnifiedMessage
  | ClientSource
  | ClientVersion
  | ProfileId
  | OrganizationId

let visibleColumns = [
  PaymentId,
  MerchantId,
  Status,
  Amount,
  Currency,
  Connector,
  PaymentMethod,
  PaymentMethodType,
]

let colMapper = (col: cols) => {
  switch col {
  | PaymentId => "payment_id"
  | MerchantId => "merchant_id"
  | Status => "status"
  | Amount => "amount"
  | Currency => "currency"
  | AmountCaptured => "amount_captured"
  | CustomerId => "customer_id"
  | Description => "description"
  | ReturnUrl => "return_url"
  | ConnectorId => "connector_id"
  | StatementDescriptorName => "statement_descriptor_name"
  | StatementDescriptorSuffix => "statement_descriptor_suffix"
  | CreatedAt => "created_at"
  | ModifiedAt => "modified_at"
  | LastSynced => "last_synced"
  | SetupFutureUsage => "setup_future_usage"
  | OffSession => "off_session"
  | ClientSecret => "client_secret"
  | ActiveAttemptId => "active_attempt_id"
  | BusinessCountry => "business_country"
  | BusinessLabel => "business_label"
  | AttemptCount => "attempt_count"
  | SignFlag => "sign_flag"
  | Timestamp => "@timestamp"
  | Confirm => "confirm"
  | MultipleCaptureCount => "multiple_capture_count"
  | AttemptId => "attempt_id"
  | SaveToLocker => "save_to_locker"
  | Connector => "connector"
  | ErrorMessage => "error_message"
  | OfferAmount => "offer_amount"
  | SurchargeAmount => "surcharge_amount"
  | TaxAmount => "tax_amount"
  | PaymentMethodId => "payment_method_id"
  | PaymentMethod => "payment_method"
  | ConnectorTransactionId => "connector_transaction_id"
  | CaptureMethod => "capture_method"
  | CaptureOn => "capture_on"
  | AuthenticationType => "authentication_type"
  | CancellationReason => "cancellation_reason"
  | AmountToCapture => "amount_to_capture"
  | MandateId => "mandate_id"
  | PaymentMethodType => "payment_method_type"
  | PaymentExperience => "payment_experience"
  | ErrorReason => "error_reason"
  | AmountCapturable => "amount_capturable"
  | MerchantConnectorId => "merchant_connector_id"
  | NetAmount => "net_amount"
  | UnifiedCode => "unified_code"
  | UnifiedMessage => "unified_message"
  | ClientSource => "client_source"
  | ClientVersion => "client_version"
  | ProfileId => "profile_id"
  | OrganizationId => "organization_id"
  }
}

let tableItemToObjMapper: Dict.t<JSON.t> => paymentAttemptObject = dict => {
  open LogicUtils

  {
    payment_id: dict->getString(PaymentId->colMapper, "NA"),
    merchant_id: dict->getString(MerchantId->colMapper, "NA"),
    status: dict->getString(Status->colMapper, "NA"),
    amount: dict->getFloat(Amount->colMapper, 0.0),
    currency: dict->getString(Currency->colMapper, "NA"),
    amount_captured: dict->getFloat(AmountCaptured->colMapper, 0.0),
    customer_id: dict->getString(CustomerId->colMapper, "NA"),
    description: dict->getString(Description->colMapper, "NA"),
    return_url: dict->getString(ReturnUrl->colMapper, "NA"),
    connector_id: dict->getString(ConnectorId->colMapper, "NA"),
    statement_descriptor_name: dict->getString(StatementDescriptorName->colMapper, "NA"),
    statement_descriptor_suffix: dict->getString(StatementDescriptorSuffix->colMapper, "NA"),
    created_at: dict->getInt(CreatedAt->colMapper, 0),
    modified_at: dict->getInt(ModifiedAt->colMapper, 0),
    last_synced: dict->getInt(LastSynced->colMapper, 0),
    setup_future_usage: dict->getString(SetupFutureUsage->colMapper, "NA"),
    off_session: dict->getString(OffSession->colMapper, "NA"),
    client_secret: dict->getString(ClientSecret->colMapper, "NA"),
    active_attempt_id: dict->getString(ActiveAttemptId->colMapper, "NA"),
    business_country: dict->getString(BusinessCountry->colMapper, "NA"),
    business_label: dict->getString(BusinessLabel->colMapper, "NA"),
    attempt_count: dict->getInt(AttemptCount->colMapper, 0),
    sign_flag: dict->getInt(SignFlag->colMapper, 0),
    timestamp: dict->getString(Timestamp->colMapper, "NA"),
    confirm: dict->getBool(Confirm->colMapper, false),
    multiple_capture_count: dict->getInt(MultipleCaptureCount->colMapper, 0),
    attempt_id: dict->getString(AttemptId->colMapper, "NA"),
    save_to_locker: dict->getString(SaveToLocker->colMapper, "NA"),
    connector: dict->getString(Connector->colMapper, "NA"),
    error_message: dict->getString(ErrorMessage->colMapper, "NA"),
    offer_amount: dict->getString(OfferAmount->colMapper, "NA"),
    surcharge_amount: dict->getString(SurchargeAmount->colMapper, "NA"),
    tax_amount: dict->getString(TaxAmount->colMapper, "NA"),
    payment_method_id: dict->getString(PaymentMethodId->colMapper, "NA"),
    payment_method: dict->getString(PaymentMethod->colMapper, "NA"),
    connector_transaction_id: dict->getString(ConnectorTransactionId->colMapper, "NA"),
    capture_method: dict->getString(CaptureMethod->colMapper, "NA"),
    capture_on: dict->getString(CaptureOn->colMapper, "NA"),
    authentication_type: dict->getString(AuthenticationType->colMapper, "NA"),
    cancellation_reason: dict->getString(CancellationReason->colMapper, "NA"),
    amount_to_capture: dict->getString(AmountToCapture->colMapper, "NA"),
    mandate_id: dict->getString(MerchantId->colMapper, "NA"),
    payment_method_type: dict->getString(PaymentMethodType->colMapper, "NA"),
    payment_experience: dict->getString(PaymentExperience->colMapper, "NA"),
    error_reason: dict->getString(ErrorReason->colMapper, "NA"),
    amount_capturable: dict->getString(AmountCapturable->colMapper, "NA"),
    merchant_connector_id: dict->getString(MerchantConnectorId->colMapper, "NA"),
    net_amount: dict->getString(NetAmount->colMapper, "NA"),
    unified_code: dict->getString(UnifiedCode->colMapper, "NA"),
    unified_message: dict->getString(UnifiedMessage->colMapper, "NA"),
    client_source: dict->getString(ClientSource->colMapper, "NA"),
    client_version: dict->getString(ClientVersion->colMapper, "NA"),
    profile_id: dict->getString(ProfileId->colMapper, "NA"),
    organization_id: dict->getString(OrganizationId->colMapper, "NA"),
  }
}

let getObjects: JSON.t => array<paymentAttemptObject> = json => {
  open LogicUtils
  json
  ->LogicUtils.getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

let getHeading = colType => {
  let key = colType->colMapper
  switch colType {
  | PaymentId => Table.makeHeaderInfo(~key, ~title="Payment ID", ~dataType=TextType)
  | MerchantId => Table.makeHeaderInfo(~key, ~title="Merchant ID", ~dataType=TextType)
  | Status => Table.makeHeaderInfo(~key, ~title="Status", ~dataType=TextType)
  | Amount => Table.makeHeaderInfo(~key, ~title="Amount", ~dataType=TextType)
  | Currency => Table.makeHeaderInfo(~key, ~title="Currency", ~dataType=TextType)
  | AmountCaptured => Table.makeHeaderInfo(~key, ~title="Amount Captured", ~dataType=TextType)
  | CustomerId => Table.makeHeaderInfo(~key, ~title="Customer Id", ~dataType=TextType)
  | Description => Table.makeHeaderInfo(~key, ~title="Description", ~dataType=TextType)
  | ReturnUrl => Table.makeHeaderInfo(~key, ~title="Return Url", ~dataType=TextType)
  | ConnectorId => Table.makeHeaderInfo(~key, ~title="Connector Id", ~dataType=TextType)
  | StatementDescriptorName =>
    Table.makeHeaderInfo(~key, ~title="Statement Descriptor Name", ~dataType=TextType)
  | StatementDescriptorSuffix =>
    Table.makeHeaderInfo(~key, ~title="Statement Descriptor Suffix", ~dataType=TextType)
  | CreatedAt => Table.makeHeaderInfo(~key, ~title="Created At", ~dataType=TextType)
  | ModifiedAt => Table.makeHeaderInfo(~key, ~title="Modified At", ~dataType=TextType)
  | LastSynced => Table.makeHeaderInfo(~key, ~title="Last Synced", ~dataType=TextType)
  | SetupFutureUsage => Table.makeHeaderInfo(~key, ~title="Setup Future Usage", ~dataType=TextType)
  | OffSession => Table.makeHeaderInfo(~key, ~title="Off Session", ~dataType=TextType)
  | ClientSecret => Table.makeHeaderInfo(~key, ~title="Client Secret", ~dataType=TextType)
  | ActiveAttemptId => Table.makeHeaderInfo(~key, ~title="Active Attempt Id", ~dataType=TextType)
  | BusinessCountry => Table.makeHeaderInfo(~key, ~title="Business Country", ~dataType=TextType)
  | BusinessLabel => Table.makeHeaderInfo(~key, ~title="Business Label", ~dataType=TextType)
  | AttemptCount => Table.makeHeaderInfo(~key, ~title="Attempt Count", ~dataType=TextType)
  | SignFlag => Table.makeHeaderInfo(~key, ~title="Sign Flag", ~dataType=TextType)
  | Timestamp => Table.makeHeaderInfo(~key, ~title="Time Stamp", ~dataType=TextType)
  | Confirm => Table.makeHeaderInfo(~key, ~title="Confirm", ~dataType=TextType)
  | MultipleCaptureCount =>
    Table.makeHeaderInfo(~key, ~title="Multiple Capture Count", ~dataType=TextType)
  | AttemptId => Table.makeHeaderInfo(~key, ~title="Attempt Id", ~dataType=TextType)
  | SaveToLocker => Table.makeHeaderInfo(~key, ~title="Save To Locker", ~dataType=TextType)
  | Connector => Table.makeHeaderInfo(~key, ~title="Connector", ~dataType=TextType)
  | ErrorMessage => Table.makeHeaderInfo(~key, ~title="Error Message", ~dataType=TextType)
  | OfferAmount => Table.makeHeaderInfo(~key, ~title="Offer Amount", ~dataType=TextType)
  | SurchargeAmount => Table.makeHeaderInfo(~key, ~title="Surcharge Amount", ~dataType=TextType)
  | TaxAmount => Table.makeHeaderInfo(~key, ~title="Tax Amount", ~dataType=TextType)
  | PaymentMethodId => Table.makeHeaderInfo(~key, ~title="Payment Method Id", ~dataType=TextType)
  | PaymentMethod => Table.makeHeaderInfo(~key, ~title="Payment Method", ~dataType=TextType)
  | ConnectorTransactionId =>
    Table.makeHeaderInfo(~key, ~title="Connector Transaction Id", ~dataType=TextType)
  | CaptureMethod => Table.makeHeaderInfo(~key, ~title="Capture Method", ~dataType=TextType)
  | CaptureOn => Table.makeHeaderInfo(~key, ~title="Capture On", ~dataType=TextType)
  | AuthenticationType =>
    Table.makeHeaderInfo(~key, ~title="Authentication Type", ~dataType=TextType)
  | CancellationReason =>
    Table.makeHeaderInfo(~key, ~title="Cancellation Reason", ~dataType=TextType)
  | AmountToCapture => Table.makeHeaderInfo(~key, ~title="Amount To Capture", ~dataType=TextType)
  | MandateId => Table.makeHeaderInfo(~key, ~title="Mandate Id", ~dataType=TextType)
  | PaymentMethodType =>
    Table.makeHeaderInfo(~key, ~title="Payment Method Type", ~dataType=TextType)
  | PaymentExperience => Table.makeHeaderInfo(~key, ~title="Payment Experience", ~dataType=TextType)
  | ErrorReason => Table.makeHeaderInfo(~key, ~title="Error Reason", ~dataType=TextType)
  | AmountCapturable => Table.makeHeaderInfo(~key, ~title="Amount Capturable", ~dataType=TextType)
  | MerchantConnectorId =>
    Table.makeHeaderInfo(~key, ~title="Merchant Connector Id", ~dataType=TextType)
  | NetAmount => Table.makeHeaderInfo(~key, ~title="Net Amount", ~dataType=TextType)
  | UnifiedCode => Table.makeHeaderInfo(~key, ~title="Unified Code", ~dataType=TextType)
  | UnifiedMessage => Table.makeHeaderInfo(~key, ~title="Unified Message", ~dataType=TextType)
  | ClientSource => Table.makeHeaderInfo(~key, ~title="Client Source", ~dataType=TextType)
  | ClientVersion => Table.makeHeaderInfo(~key, ~title="Client Version", ~dataType=TextType)
  | ProfileId => Table.makeHeaderInfo(~key, ~title="Profile Id", ~dataType=TextType)
  | OrganizationId => Table.makeHeaderInfo(~key, ~title="Organization Id", ~dataType=TextType)
  }
}

let getCell = (paymentObj, colType): Table.cell => {
  switch colType {
  | PaymentId =>
    CustomCell(
      <HSwitchOrderUtils.CopyLinkTableCell
        url={`/payments/${paymentObj.payment_id}/${paymentObj.profile_id}/${paymentObj.merchant_id}/${paymentObj.organization_id}`}
        displayValue={paymentObj.payment_id}
        copyValue={Some(paymentObj.payment_id)}
      />,
      "",
    )
  | MerchantId => Text(paymentObj.merchant_id)
  | Status =>
    let orderStatus = paymentObj.status->HSwitchOrderUtils.paymentAttemptStatusVariantMapper
    Label({
      title: paymentObj.status->String.toUpperCase,
      color: switch orderStatus {
      | #CHARGED
      | #PARTIAL_CHARGED
      | #COD_INITIATED
      | #AUTO_REFUNDED =>
        LabelGreen
      | #AUTHENTICATION_FAILED
      | #ROUTER_DECLINED
      | #AUTHORIZATION_FAILED
      | #CAPTURE_FAILED
      | #VOID_FAILED
      | #FAILURE =>
        LabelRed
      | #AUTHENTICATION_PENDING
      | #AUTHORIZING
      | #VOID_INITIATED
      | #CAPTURE_INITIATED
      | #PENDING =>
        LabelOrange
      | _ => LabelLightGray
      },
    })
  | Amount =>
    CustomCell(
      <OrderEntity.CurrencyCell
        amount={(paymentObj.amount /. 100.0)->Float.toString} currency={paymentObj.currency}
      />,
      "",
    )
  | Currency => Text(paymentObj.currency)
  | AmountCaptured =>
    CustomCell(
      <OrderEntity.CurrencyCell
        amount={(paymentObj.amount_captured /. 100.0)->Float.toString}
        currency={paymentObj.currency}
      />,
      "",
    )
  | CustomerId => Text(paymentObj.customer_id)
  | Description => Text(paymentObj.description)
  | ReturnUrl => Text(paymentObj.return_url)
  | ConnectorId => Text(paymentObj.connector_id)
  | StatementDescriptorName => Text(paymentObj.statement_descriptor_name)
  | StatementDescriptorSuffix => Text(paymentObj.statement_descriptor_suffix)
  | CreatedAt => Text(paymentObj.created_at->Int.toString)
  | ModifiedAt => Text(paymentObj.modified_at->Int.toString)
  | LastSynced => Text(paymentObj.last_synced->Int.toString)
  | SetupFutureUsage => Text(paymentObj.setup_future_usage)
  | OffSession => Text(paymentObj.off_session)
  | ClientSecret => Text(paymentObj.client_secret)
  | ActiveAttemptId => Text(paymentObj.active_attempt_id)
  | BusinessCountry => Text(paymentObj.business_country)
  | BusinessLabel => Text(paymentObj.business_label)
  | AttemptCount => Text(paymentObj.attempt_count->Int.toString)
  | SignFlag => Text(paymentObj.sign_flag->Int.toString)
  | Timestamp => Text(paymentObj.timestamp)
  | Confirm => Text(paymentObj.confirm->LogicUtils.getStringFromBool)
  | MultipleCaptureCount => Text(paymentObj.multiple_capture_count->Int.toString)
  | AttemptId => Text(paymentObj.attempt_id)
  | SaveToLocker => Text(paymentObj.save_to_locker)
  | Connector => Text(paymentObj.connector)
  | ErrorMessage => Text(paymentObj.error_message)
  | OfferAmount => Text(paymentObj.offer_amount)
  | SurchargeAmount => Text(paymentObj.surcharge_amount)
  | TaxAmount => Text(paymentObj.tax_amount)
  | PaymentMethodId => Text(paymentObj.payment_method_id)
  | PaymentMethod => Text(paymentObj.payment_method)
  | ConnectorTransactionId => Text(paymentObj.connector_transaction_id)
  | CaptureMethod => Text(paymentObj.capture_method)
  | CaptureOn => Text(paymentObj.capture_on)
  | AuthenticationType => Text(paymentObj.authentication_type)
  | CancellationReason => Text(paymentObj.cancellation_reason)
  | AmountToCapture => Text(paymentObj.amount_to_capture)
  | MandateId => Text(paymentObj.mandate_id)
  | PaymentMethodType => Text(paymentObj.payment_method_type)
  | PaymentExperience => Text(paymentObj.payment_experience)
  | ErrorReason => Text(paymentObj.error_reason)
  | AmountCapturable => Text(paymentObj.amount_capturable)
  | MerchantConnectorId => Text(paymentObj.merchant_connector_id)
  | NetAmount => Text(paymentObj.net_amount)
  | UnifiedCode => Text(paymentObj.unified_code)
  | UnifiedMessage => Text(paymentObj.unified_message)
  | ClientSource => Text(paymentObj.client_source)
  | ClientVersion => Text(paymentObj.client_version)
  | ProfileId => Text(paymentObj.profile_id)
  | OrganizationId => Text(paymentObj.organization_id)
  }
}

let tableEntity = EntityType.makeEntity(
  ~uri=``,
  ~getObjects,
  ~dataKey="queryData",
  ~defaultColumns=visibleColumns,
  ~requiredSearchFieldsList=[],
  ~allColumns=visibleColumns,
  ~getCell,
  ~getHeading,
  ~getShowLink={
    order =>
      GlobalVars.appendDashboardPath(
        ~url=`/payments/${order.payment_id}/${order.profile_id}/${order.merchant_id}/${order.organization_id}`,
      )
  },
)
