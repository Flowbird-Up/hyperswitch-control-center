@react.component
let make = () => {
  open ThreeDsProcessorTypes
  open ConnectorUtils
  open APIUtils
  open LogicUtils
  let getURL = useGetURL()
  let showToast = ToastState.useShowToast()
  let url = RescriptReactRouter.useUrl()
  let updateAPIHook = useUpdateMethod(~showErrorToast=false)
  let fetchDetails = useGetMethod()
  let connectorName = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("name", "")
  let connectorID = HSwitchUtils.getConnectorIDFromUrl(url.path->List.toArray, "")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)
  let (currentStep, setCurrentStep) = React.useState(_ => ConfigurationFields)
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()

  let activeBusinessProfile =
    Recoil.useRecoilValueFromAtom(
      HyperswitchAtom.businessProfilesAtom,
    )->MerchantAccountUtils.getValueFromBusinessProfile

  let isUpdateFlow = switch url.path->HSwitchUtils.urlPath {
  | list{"3ds-authenticators", "new"} => false
  | _ => true
  }

  let getConnectorDetails = async () => {
    try {
      let connectorUrl = getURL(~entityName=V1(CONNECTOR), ~methodType=Get, ~id=Some(connectorID))
      let json = await fetchDetails(connectorUrl)
      setInitialValues(_ => json)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to update!")
        Exn.raiseError(err)
      }
    | _ => Exn.raiseError("Something went wrong")
    }
  }

  let getDetails = async () => {
    try {
      setScreenState(_ => Loading)
      let _ = await Window.connectorWasmInit()
      if isUpdateFlow {
        await getConnectorDetails()
        setCurrentStep(_ => Preview)
      } else {
        setCurrentStep(_ => ConfigurationFields)
      }
      setScreenState(_ => Success)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Something went wrong")
        setScreenState(_ => Error(err))
      }
    | _ => setScreenState(_ => Error("Something went wrong"))
    }
  }

  let connectorDetails = React.useMemo(() => {
    try {
      if connectorName->LogicUtils.isNonEmptyString {
        let dict = Window.getAuthenticationConnectorConfig(connectorName)
        dict
      } else {
        Dict.make()->JSON.Encode.object
      }
    } catch {
    | Exn.Error(e) => {
        Js.log2("FAILED TO LOAD CONNECTOR CONFIG", e)
        let err = Exn.message(e)->Option.getOr("Something went wrong")
        setScreenState(_ => PageLoaderWrapper.Error(err))
        Dict.make()->JSON.Encode.object
      }
    }
  }, [connectorName])

  let (
    bodyType,
    connectorAccountFields,
    connectorMetaDataFields,
    _,
    connectorWebHookDetails,
    connectorLabelDetailField,
    connectorAdditionalMerchantData,
  ) = getConnectorFields(connectorDetails)

  React.useEffect(() => {
    let initialValuesToDict = initialValues->LogicUtils.getDictFromJsonObject

    if !isUpdateFlow {
      initialValuesToDict->Dict.set(
        "profile_id",
        activeBusinessProfile.profile_id->JSON.Encode.string,
      )
      initialValuesToDict->Dict.set(
        "connector_label",
        `${connectorName}_${activeBusinessProfile.profile_name}`->JSON.Encode.string,
      )
    }
    None
  }, [connectorName, activeBusinessProfile.profile_id])

  React.useEffect(() => {
    if connectorName->LogicUtils.isNonEmptyString {
      getDetails()->ignore
    }
    None
  }, [connectorName])

  let onSubmit = async (values, _) => {
    try {
      let body =
        generateInitialValuesDict(
          ~values,
          ~connector=connectorName,
          ~bodyType,
          ~isLiveMode={false},
          ~connectorType=ConnectorTypes.ThreeDsAuthenticator,
        )->ignoreFields(connectorID, connectorIgnoredField)
      let connectorUrl = getURL(
        ~entityName=V1(CONNECTOR),
        ~methodType=Post,
        ~id=isUpdateFlow ? Some(connectorID) : None,
      )
      let response = await updateAPIHook(connectorUrl, body, Post)
      let _ = await fetchConnectorListResponse()
      setInitialValues(_ => response)
      setCurrentStep(_ => Summary)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Something went wrong")
        let errorCode = err->safeParse->getDictFromJsonObject->getString("code", "")
        let errorMessage = err->safeParse->getDictFromJsonObject->getString("message", "")

        if errorCode === "HE_01" {
          showToast(~message="Connector label already exist!", ~toastType=ToastError)
          setCurrentStep(_ => ConfigurationFields)
        } else {
          showToast(~message=errorMessage, ~toastType=ToastError)
          setScreenState(_ => PageLoaderWrapper.Error(err))
        }
      }
    }
    Nullable.null
  }

  let validateMandatoryField = values => {
    let errors = Dict.make()
    let valuesFlattenJson = values->JsonFlattenUtils.flattenObject(true)

    validateConnectorRequiredFields(
      connectorName->getConnectorNameTypeFromString(~connectorType=ThreeDsAuthenticator),
      valuesFlattenJson,
      connectorAccountFields,
      connectorMetaDataFields,
      connectorWebHookDetails,
      connectorLabelDetailField,
      errors->JSON.Encode.object,
    )
  }

  let summaryPageButton = switch currentStep {
  | Preview => React.null
  | _ =>
    <Button
      text="Done"
      buttonType=Primary
      onClick={_ =>
        RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/3ds-authenticators"))}
    />
  }

  <PageLoaderWrapper screenState>
    <div className="flex flex-col gap-10 overflow-scroll h-full w-full">
      <BreadCrumbNavigation
        path=[
          connectorID === "new"
            ? {
                title: "3DS Authenticator",
                link: "/3ds-authenticators",
                warning: `You have not yet completed configuring your ${connectorName->LogicUtils.snakeToTitle} connector. Are you sure you want to go back?`,
              }
            : {
                title: "3DS Authenticator",
                link: "/3ds-authenticators",
              },
        ]
        currentPageTitle={connectorName->getDisplayNameForConnector(
          ~connectorType=ThreeDsAuthenticator,
        )}
        cursorStyle="cursor-pointer"
      />
      <div
        className="bg-white rounded-lg border h-3/4 overflow-scroll shadow-boxShadowMultiple show-scrollbar">
        {switch currentStep {
        | ConfigurationFields =>
          <Form initialValues={initialValues} onSubmit validate={validateMandatoryField}>
            <ConnectorAccountDetailsHelper.ConnectorHeaderWrapper
              connector=connectorName
              connectorType=ThreeDsAuthenticator
              headerButton={<AddDataAttributes
                attributes=[("data-testid", "connector-submit-button")]>
                <FormRenderer.SubmitButton loadingText="Processing..." text="Connect and Proceed" />
              </AddDataAttributes>}>
              <div className="flex flex-col gap-2 p-2 md:px-10">
                <ConnectorAccountDetailsHelper.BusinessProfileRender
                  isUpdateFlow selectedConnector={connectorName}
                />
              </div>
              <div className={`flex flex-col gap-2 p-2 md:p-10`}>
                <ConnectorAccountDetailsHelper.ConnectorConfigurationFields
                  connector={connectorName->getConnectorNameTypeFromString(
                    ~connectorType=ThreeDsAuthenticator,
                  )}
                  connectorAccountFields
                  selectedConnector={connectorName
                  ->getConnectorNameTypeFromString(~connectorType=ThreeDsAuthenticator)
                  ->getConnectorInfo}
                  connectorMetaDataFields
                  connectorWebHookDetails
                  connectorLabelDetailField
                  connectorAdditionalMerchantData
                />
              </div>
            </ConnectorAccountDetailsHelper.ConnectorHeaderWrapper>
            <FormValuesSpy />
          </Form>

        | Summary | Preview =>
          <ConnectorAccountDetailsHelper.ConnectorHeaderWrapper
            connector=connectorName
            connectorType=ThreeDsAuthenticator
            headerButton={summaryPageButton}>
            <ConnectorPreview.ConnectorSummaryGrid
              connectorInfo={ConnectorInterface.mapDictToConnectorPayload(
                ConnectorInterface.connectorInterfaceV1,
                initialValues->LogicUtils.getDictFromJsonObject,
              )}
              connector=connectorName
              setCurrentStep={_ => ()}
              getConnectorDetails={Some(getConnectorDetails)}
            />
          </ConnectorAccountDetailsHelper.ConnectorHeaderWrapper>
        }}
      </div>
    </div>
  </PageLoaderWrapper>
}
