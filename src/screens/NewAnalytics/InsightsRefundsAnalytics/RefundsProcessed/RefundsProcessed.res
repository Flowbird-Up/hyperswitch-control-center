open InsightsTypes
open InsightsHelper
open InsightsRefundsAnalyticsEntity
open RefundsProcessedUtils
open RefundsProcessedTypes

module TableModule = {
  open LogicUtils
  @react.component
  let make = (~data, ~className="") => {
    let (offset, setOffset) = React.useState(_ => 0)
    let defaultSort: Table.sortedObject = {
      key: "",
      order: Table.INC,
    }
    let tableBorderClass = "border-collapse border border-jp-gray-940 border-solid border-2 border-opacity-30 dark:border-jp-gray-dark_table_border_color dark:border-opacity-30"

    let refundsProcessed =
      data
      ->Array.map(item => {
        item->getDictFromJsonObject->tableItemToObjMapper
      })
      ->Array.map(Nullable.make)

    let defaultCols = [Refund_Processed_Amount, Refund_Processed_Count]
    let visibleColumns = defaultCols->Array.concat(visibleColumns)

    <div className>
      <LoadedTable
        visibleColumns
        title="Refunds Processed"
        hideTitle=true
        actualData={refundsProcessed}
        entity=refundsProcessedTableEntity
        resultsPerPage=10
        totalResults={refundsProcessed->Array.length}
        offset
        setOffset
        defaultSort
        currrentFetchCount={refundsProcessed->Array.length}
        tableLocalFilter=false
        tableheadingClass=tableBorderClass
        tableBorderClass
        ignoreHeaderBg=true
        showSerialNumber=true
        tableDataBorderClass=tableBorderClass
        isAnalyticsModule=true
      />
    </div>
  }
}

module RefundsProcessedHeader = {
  open InsightsUtils
  open LogicUtils
  open LogicUtilsTypes

  @react.component
  let make = (
    ~data: JSON.t,
    ~viewType,
    ~setViewType,
    ~selectedMetric,
    ~setSelectedMetric,
    ~granularity,
    ~setGranularity,
    ~granularityOptions,
  ) => {
    let {filterValueJson} = React.useContext(FilterContext.filterContext)
    let comparison = filterValueJson->getString("comparison", "")->DateRangeUtils.comparisonMapprer
    let currency = filterValueJson->getString((#currency: filters :> string), "")
    let featureFlag = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

    let primaryValue = getMetaDataValue(
      ~data,
      ~index=0,
      ~key=selectedMetric.value->getMetaDataMapper(~currency),
    )
    let secondaryValue = getMetaDataValue(
      ~data,
      ~index=1,
      ~key=selectedMetric.value->getMetaDataMapper(~currency),
    )

    let (primaryValue, secondaryValue) = if (
      selectedMetric.value->getMetaDataMapper(~currency)->isAmountMetric
    ) {
      (primaryValue /. 100.0, secondaryValue /. 100.0)
    } else {
      (primaryValue, secondaryValue)
    }

    let (value, direction) = calculatePercentageChange(~primaryValue, ~secondaryValue)

    let setViewType = value => {
      setViewType(_ => value)
    }

    let setSelectedMetric = value => {
      setSelectedMetric(_ => value)
    }

    let setGranularity = value => {
      setGranularity(_ => value)
    }

    let metricType = switch selectedMetric.value->getVariantValueFromString {
    | Refund_Processed_Amount => Amount
    | _ => Volume
    }

    <div className="w-full px-7 py-8 grid grid-cols-3">
      <div className="flex gap-2 items-center">
        <div className="text-fs-28 font-semibold">
          {primaryValue->valueFormatter(metricType, ~currency)->React.string}
        </div>
        <RenderIf condition={comparison == EnableComparison}>
          <StatisticsCard
            value direction tooltipValue={secondaryValue->valueFormatter(metricType, ~currency)}
          />
        </RenderIf>
      </div>
      <div className="flex justify-center">
        <RenderIf condition={featureFlag.granularity}>
          <Tabs
            option={granularity}
            setOption={setGranularity}
            options={granularityOptions}
            showSingleTab=false
          />
        </RenderIf>
      </div>
      <div className="flex gap-2 justify-end">
        <CustomDropDown
          buttonText={selectedMetric} options={dropDownOptions} setOption={setSelectedMetric}
        />
        <TabSwitch viewType setViewType />
      </div>
    </div>
  }
}

@react.component
let make = (
  ~entity: moduleEntity,
  ~chartEntity: chartEntity<
    LineGraphTypes.lineGraphPayload,
    LineGraphTypes.lineGraphOptions,
    JSON.t,
  >,
) => {
  open LogicUtils
  open APIUtils
  open InsightsUtils
  open InsightsContainerUtils
  let getURL = useGetURL()
  let fetchApi = AuthHooks.useApiFetcher()
  let updateDetails = useUpdateMethod()
  let isoStringToCustomTimeZone = TimeZoneHook.useIsoStringToCustomTimeZone()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let (refundsProcessedData, setRefundsProcessedData) = React.useState(_ => JSON.Encode.array([]))
  let (refundsProcessedTableData, setRefundsProcessedTableData) = React.useState(_ => [])
  let (refundsProcessedMetaData, setRefundsProcessedMetaData) = React.useState(_ =>
    JSON.Encode.array([])
  )
  let (selectedMetric, setSelectedMetric) = React.useState(_ => defaultMetric)
  let (viewType, setViewType) = React.useState(_ => Graph)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")
  let compareToStartTime = filterValueJson->getString("compareToStartTime", "")
  let compareToEndTime = filterValueJson->getString("compareToEndTime", "")
  let comparison = filterValueJson->getString("comparison", "")->DateRangeUtils.comparisonMapprer
  let currency = filterValueJson->getString((#currency: filters :> string), "")
  let isSampleDataEnabled = filterValueJson->getStringFromDictAsBool(sampleDataKey, false)
  let featureFlag = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let granularityOptions = getGranularityOptions(~startTime=startTimeVal, ~endTime=endTimeVal)
  let defaulGranularity = getDefaultGranularity(
    ~startTime=startTimeVal,
    ~endTime=endTimeVal,
    ~granularity=featureFlag.granularity,
  )
  let (granularity, setGranularity) = React.useState(_ => defaulGranularity)

  React.useEffect(() => {
    if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
      setGranularity(_ => defaulGranularity)
    }
    None
  }, (startTimeVal, endTimeVal))

  let getRefundsProcessed = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let url = getURL(
        ~entityName=V1(ANALYTICS_PAYMENTS),
        ~methodType=Post,
        ~id=Some((entity.domain: domain :> string)),
      )

      let primaryResponse = if isSampleDataEnabled {
        let refundsUrl = `${GlobalVars.getHostUrl}/test-data/analytics/refunds.json`
        let res = await fetchApi(
          refundsUrl,
          ~method_=Get,
          ~xFeatureRoute=false,
          ~forceCookies=false,
        )
        let refundsResponse = await res->(res => res->Fetch.Response.json)
        refundsResponse->getDictFromJsonObject->getJsonObjectFromDict("refundsSampleData")
      } else {
        let primaryBody = requestBody(
          ~startTime=startTimeVal,
          ~endTime=endTimeVal,
          ~delta=entity.requestBodyConfig.delta,
          ~metrics=entity.requestBodyConfig.metrics,
          ~granularity=granularity.value->Some,
          ~filter=generateFilterObject(~globalFilters=filterValueJson)->Some,
        )
        await updateDetails(url, primaryBody, Post)
      }
      let primaryData =
        primaryResponse
        ->getDictFromJsonObject
        ->getArrayFromDict("queryData", [])
        ->modifyQueryData(~currency)
        ->sortQueryDataByDate
      let primaryMetaData = primaryResponse->getDictFromJsonObject->getArrayFromDict("metaData", [])
      setRefundsProcessedTableData(_ => primaryData)

      let (secondaryMetaData, secondaryModifiedData) = switch comparison {
      | EnableComparison => {
          let secondaryResponse = if isSampleDataEnabled {
            let refundsUrl = `${GlobalVars.getHostUrl}/test-data/analytics/refunds.json`
            let res = await fetchApi(
              refundsUrl,
              ~method_=Get,
              ~xFeatureRoute=false,
              ~forceCookies=false,
            )
            let refundsResponse = await res->(res => res->Fetch.Response.json)
            refundsResponse
            ->getDictFromJsonObject
            ->getJsonObjectFromDict("comparisonRefundsSampleData")
          } else {
            let secondaryBody = requestBody(
              ~startTime=compareToStartTime,
              ~endTime=compareToEndTime,
              ~delta=entity.requestBodyConfig.delta,
              ~metrics=entity.requestBodyConfig.metrics,
              ~granularity=granularity.value->Some,
              ~filter=generateFilterObject(~globalFilters=filterValueJson)->Some,
            )
            await updateDetails(url, secondaryBody, Post)
          }
          let secondaryData =
            secondaryResponse
            ->getDictFromJsonObject
            ->getArrayFromDict("queryData", [])
            ->modifyQueryData(~currency)
          let secondaryMetaData =
            secondaryResponse->getDictFromJsonObject->getArrayFromDict("metaData", [])
          let secondaryModifiedData = [secondaryData]->Array.map(data => {
            fillMissingDataPoints(
              ~data,
              ~startDate=compareToStartTime,
              ~endDate=compareToEndTime,
              ~timeKey="time_bucket",
              ~defaultValue={
                "payment_count": 0,
                "payment_processed_amount": 0,
                "time_bucket": startTimeVal,
              }->Identity.genericTypeToJson,
              ~granularity=granularity.value,
              ~isoStringToCustomTimeZone,
              ~granularityEnabled=featureFlag.granularity,
            )
          })
          (secondaryMetaData, secondaryModifiedData)
        }
      | DisableComparison => ([], [])
      }

      if primaryData->Array.length > 0 {
        let primaryModifiedData = [primaryData]->Array.map(data => {
          fillMissingDataPoints(
            ~data,
            ~startDate=startTimeVal,
            ~endDate=endTimeVal,
            ~timeKey="time_bucket",
            ~defaultValue={
              "payment_count": 0,
              "payment_processed_amount": 0,
              "time_bucket": startTimeVal,
            }->Identity.genericTypeToJson,
            ~isoStringToCustomTimeZone,
            ~granularity=granularity.value,
            ~granularityEnabled=featureFlag.granularity,
          )
        })

        setRefundsProcessedData(_ =>
          primaryModifiedData->Array.concat(secondaryModifiedData)->Identity.genericTypeToJson
        )
        setRefundsProcessedMetaData(_ =>
          primaryMetaData->Array.concat(secondaryMetaData)->Identity.genericTypeToJson
        )
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        setScreenState(_ => PageLoaderWrapper.Custom)
      }
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }
  React.useEffect(() => {
    if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
      getRefundsProcessed()->ignore
    }
    None
  }, (
    startTimeVal,
    endTimeVal,
    compareToStartTime,
    compareToEndTime,
    comparison,
    currency,
    granularity.value,
    isSampleDataEnabled,
  ))

  let params = {
    data: refundsProcessedData,
    xKey: selectedMetric.value->getKeyForModule,
    yKey: Time_Bucket->getStringFromVariant,
    comparison,
    currency,
  }

  let options = chartEntity.getObjects(~params)->chartEntity.getChatOptions

  <div>
    <ModuleHeader title={entity.title} />
    <Card>
      <PageLoaderWrapper
        screenState customLoader={<Shimmer layoutId=entity.title />} customUI={<NoData />}>
        // Need to modify
        <RefundsProcessedHeader
          data=refundsProcessedMetaData
          viewType
          setViewType
          selectedMetric
          setSelectedMetric
          granularity
          setGranularity
          granularityOptions
        />
        <div className="mb-5">
          {switch viewType {
          | Graph => <LineGraph options className="mr-3" />
          | Table => <TableModule data={refundsProcessedTableData} className="mx-7" />
          }}
        </div>
      </PageLoaderWrapper>
    </Card>
  </div>
}
