@react.component
let make = () => {
  open HSwitchSetupAccountUtils
  open APIUtils
  open HyperSwitchUtils
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let finalTickLottieFile = LottieFiles.useLottieJson("FinalTick.json")
  let (stepCounter, setStepCounter) = React.useState(_ => #INITIALIZE)
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()
  let getURL = useGetURL()
  let activeBusinessProfile =
    HyperswitchAtom.businessProfileFromIdAtom->Recoil.useRecoilValueFromAtom

  let indexOfStepCounterVal = listOfStepCounter->Array.indexOf(stepCounter)
  let {
    dashboardPageState,
    setDashboardPageState,
    integrationDetails,
    setIntegrationDetails,
  } = React.useContext(GlobalProvider.defaultContext)

  React.useEffect(() => {
    if dashboardPageState !== #HOME {
      RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/setup-account"))
    }
    None
  }, [dashboardPageState])

  let apiCalls = async () => {
    try {
      open LogicUtils
      let url = getURL(~entityName=V1(CONNECTOR), ~methodType=Post)
      // * STRIPE && PAYPAL TEST
      let stripeTestBody = constructBody(
        ~connectorName="stripe_test",
        ~json=Window.getConnectorConfig("stripe_test"),
        ~profileId=activeBusinessProfile.profile_id,
      )
      let stripeTest = (await updateDetails(url, stripeTestBody, Post))->getDictFromJsonObject
      let stripeTestRes = ConnectorInterface.mapDictToConnectorPayload(
        ConnectorInterface.connectorInterfaceV1,
        stripeTest,
      )

      let paypalTestBody = constructBody(
        ~connectorName="paypal_test",
        ~json=Window.getConnectorConfig("paypal_test"),
        ~profileId=activeBusinessProfile.profile_id,
      )
      let payPalTest = (await updateDetails(url, paypalTestBody, Post))->getDictFromJsonObject
      let payPalTestRes = ConnectorInterface.mapDictToConnectorPayload(
        ConnectorInterface.connectorInterfaceV1,
        payPalTest,
      )

      let _ = await fetchConnectorListResponse()
      setStepCounter(_ => #CONNECTORS_CONFIGURED)

      // *ROUTING
      let payPalTestRouting = {
        connector_name: "paypal_test",
        merchant_connector_id: payPalTestRes.merchant_connector_id,
      }
      let stripTestRouting = {
        connector_name: "stripe_test",
        merchant_connector_id: stripeTestRes.merchant_connector_id,
      }
      let routingUrl = getURL(~entityName=V1(ROUTING), ~methodType=Post, ~id=None)
      let activatingId =
        (
          await updateDetails(
            routingUrl,
            activeBusinessProfile.profile_id->routingPayload(stripTestRouting, payPalTestRouting),
            Post,
          )
        )
        ->getDictFromJsonObject
        ->getOptionString("id")
      let activateRuleURL = getURL(~entityName=V1(ROUTING), ~methodType=Post, ~id=activatingId)
      let _ = await updateDetails(activateRuleURL, Dict.make()->JSON.Encode.object, Post)
      setStepCounter(_ => #ROUTING_ENABLED)

      // *GENERATE_SAMPLE_DATA
      let generateSampleDataUrl = getURL(~entityName=V1(GENERATE_SAMPLE_DATA), ~methodType=Post)
      let _ = await updateDetails(generateSampleDataUrl, Dict.make()->JSON.Encode.object, Post)
      setStepCounter(_ => #GENERATE_SAMPLE_DATA)
      await delay(delayTime)
      setStepCounter(_ => #COMPLETED)

      await delay(delayTime)

      let body = HSwitchUtils.constructOnboardingBody(
        ~dashboardPageState,
        ~integrationDetails,
        ~is_done=true,
      )
      let integrationUrl = getURL(~entityName=V1(INTEGRATION_DETAILS), ~methodType=Post)
      let _ = await updateDetails(integrationUrl, body, Post)
      setIntegrationDetails(_ => body->ProviderHelper.getIntegrationDetails)
      setDashboardPageState(_ => #INTEGRATION_DOC)
    } catch {
    | _ => {
        await delay(delayTime - 1000)
        setDashboardPageState(_ => #HOME)
      }
    }
  }

  let getDetails = async () => {
    if activeBusinessProfile.profile_id->LogicUtils.isNonEmptyString {
      apiCalls()->ignore
    }
  }

  React.useEffect(() => {
    getDetails()->ignore
    None
  }, [])

  if indexOfStepCounterVal <= 3 {
    <div className="flex flex-col gap-5 items-center justify-center h-screen w-screen">
      <Loader />
      <div className="font-bold text-xl"> {React.string("Setting up your control center")} </div>
    </div>
  } else {
    <div className="flex flex-col justify-center items-center h-screen w-screen">
      <ReactSuspenseWrapper>
        <Lottie animationData={finalTickLottieFile} autoplay=true loop=false />
      </ReactSuspenseWrapper>
      <div className="font-semibold text-2xl"> {React.string("Setup complete")} </div>
    </div>
  }
}
