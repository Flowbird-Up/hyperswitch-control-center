@react.component
let make = (
  ~max="5000",
  ~min="1200",
  ~width="200px",
  ~maxSlide: ReactFinalForm.fieldRenderPropsInput,
  ~minSlide: ReactFinalForm.fieldRenderPropsInput,
) => {
  let max = Math.ceil(max->Js.Float.fromString)
  let min = Math.floor(min->Js.Float.fromString)
  let (minSlideVal, setMinSlideVal) = React.useState(_ =>
    minSlide.value->LogicUtils.getFloatFromJson(min)
  )
  let (maxSlideVal, setMaxSlideVal) = React.useState(_ =>
    maxSlide.value->LogicUtils.getFloatFromJson(max)
  )
  let (hasError, setHasError) = React.useState(_ => (false, false))
  let (isFocused, setIsFocused) = React.useState(_ => (false, false))
  let (isInputFocused, setIsInputFocused) = React.useState(_ => (false, false))

  let (isMinFocused, isMaxFocused) = isFocused
  let (isMinInputFocused, isMaxInputFocused) = isInputFocused
  let (hasMinError, hasMaxError) = hasError

  let maxSlide = {
    ...maxSlide,
    value: maxSlide.value <= minSlide.value
      ? minSlide.value
      : maxSlide.value > max->JSON.Encode.float
      ? max->JSON.Encode.float
      : maxSlide.value,
  }

  let minSlide = {
    ...minSlide,
    value: minSlide.value >= maxSlide.value
      ? maxSlide.value
      : minSlide.value < min->JSON.Encode.float
      ? min->JSON.Encode.float
      : minSlide.value,
  }

  let diff = React.useMemo(() => {
    Math.max(max -. min, 1.)
  }, (max, min))

  let maxsliderVal = React.useMemo(() => {
    switch maxSlide.value->JSON.Decode.float {
    | Some(num) => Math.ceil(num)->Float.toString
    | None => "0"
    }
  }, [maxSlide.value])

  let minsliderVal = React.useMemo(() => {
    switch minSlide.value->JSON.Decode.float {
    | Some(num) => Math.floor(num)->Float.toString
    | None => "0"
    }
  }, [minSlide.value])

  let minborderClass = hasMinError
    ? "border-jp-2-light-red-600"
    : `${isMinFocused || isMinInputFocused ? "border-jp-2-light-primary-600" : ""}`

  let maxborderClass = hasMaxError
    ? "border-jp-2-light-red-600"
    : `${isMaxFocused || isMaxInputFocused ? "border-jp-2-light-primary-600" : ""}`

  let inputClassname = (hasError, isFocused) => {
    let bg = hasError
      ? "bg-jp-2-red-100"
      : `${isFocused
            ? "bg-jp-2-light-primary-200"
            : "focus:bg-jp-2-light-primary-200 hover:bg-jp-2-light-gray-100"}`
    `w-max numberInput outline-none p-1 ${bg} `
  }

  let bgClass = isMinFocused || isMaxFocused ? "bg-primary" : "bg-jp-2-light-gray-2000"
  <div className="relative pt-1 w-max">
    <div className={`h-1 rounded relative bg-gray-200`} style={width: width}>
      <div
        className={`h-1 rounded absolute ${bgClass}`}
        style={
          width: ((maxsliderVal->LogicUtils.getFloatFromString(0.) -.
            minsliderVal->LogicUtils.getFloatFromString(0.)) *.
          100. /.
          diff)->Float.toString ++ "%",
          left: ((minsliderVal->LogicUtils.getFloatFromString(0.) -. min) *. 100. /. diff)
            ->Float.toString ++ "%",
          right: ((max -. maxsliderVal->LogicUtils.getFloatFromString(0.)) *. 100. /. diff)
            ->Float.toString ++ "%",
        }
      />
    </div>
    <div className={`absolute top-0`}>
      <input
        style={width: width}
        className={`absolute bg-transparent pointer-events-none appearance-none slider hover:sliderFocus active:sliderFocus outline-none`}
        type_="range"
        value=minsliderVal
        min={min->Float.toString}
        max={max->Float.toString}
        onBlur={minSlide.onBlur}
        onChange={ev => {
          minSlide.onChange(ev)
          setHasError(((_, max)) => (false, max))
          setMinSlideVal(_ => ReactEvent.Form.target(ev)["value"])
        }}
        onFocus={ev => {
          minSlide.onFocus(ev)
        }}
        onMouseEnter={_ => setIsFocused(((_, max)) => (true, max))}
        onMouseLeave={_ => setIsFocused(((_, max)) => (false, max))}
      />
      <input
        style={width: width}
        className={`absolute bg-transparent pointer-events-none appearance-none slider hover:sliderFocus active:sliderFocus outline-none`}
        type_="range"
        value=maxsliderVal
        min={min->Float.toString}
        max={max->Float.toString}
        onBlur={maxSlide.onBlur}
        onChange={ev => {
          maxSlide.onChange(ev)
          setHasError(((min, _)) => (min, false))
          setMaxSlideVal(_ => ReactEvent.Form.target(ev)["value"])
        }}
        onFocus={ev => {
          minSlide.onFocus(ev)
        }}
        onMouseEnter={_ => setIsFocused(((min, _)) => (min, true))}
        onMouseLeave={_ => setIsFocused(((min, _)) => (min, false))}
      />
    </div>
    <div className="mt-4 flex flex-row justify-between w-full">
      <span className={`font-bold p-1 border-b ${minborderClass}`}>
        <input
          type_="number"
          className={inputClassname(hasMinError, isMinFocused)}
          value={minSlideVal->Float.toString}
          min={min->Float.toString}
          max={max->Float.toString}
          onBlur={ev => {
            let minVal = minSlideVal
            let maxSliderValue = maxSlide.value->JSON.Decode.float->Option.getOr(0.)
            if minVal >= min && minVal < maxSliderValue {
              setHasError(((_, max)) => (false, max))
              minSlide.onChange(ev->Identity.anyTypeToReactEvent)
            } else {
              setHasError(((_, max)) => (true, max))
            }
            setIsInputFocused(((_, max)) => (false, max))
          }}
          onChange={ev => {
            setMinSlideVal(_ => ReactEvent.Form.target(ev)["value"])
          }}
          onKeyUp={ev => {
            let key = ev->ReactEvent.Keyboard.key
            let keyCode = ev->ReactEvent.Keyboard.keyCode
            if key === "Enter" || keyCode === 13 {
              let minVal = minSlideVal
              let maxSliderValue = maxSlide.value->JSON.Decode.float->Option.getOr(0.)
              if minVal >= min && minVal <= maxSliderValue {
                setHasError(((_, max)) => (false, max))
                minSlide.onChange(ev->Identity.anyTypeToReactEvent)
              } else {
                setHasError(((_, max)) => (true, max))
              }
            }
          }}
          onFocus={_ => setIsInputFocused(((_, max)) => (true, max))}
        />
      </span>
      <span className={`font-bold p-1 border-b ${maxborderClass}`}>
        <input
          className={inputClassname(hasMaxError, isMaxFocused)}
          type_="number"
          value={maxSlideVal->Float.toString}
          min={min->Float.toString}
          max={max->Float.toString}
          onBlur={ev => {
            let maxVal = maxSlideVal
            let minSliderValue = minSlide.value->JSON.Decode.float->Option.getOr(0.)
            if maxVal <= max && maxVal > minSliderValue {
              setHasError(((min, _)) => (min, false))
              maxSlide.onChange(ev->Identity.anyTypeToReactEvent)
            } else {
              setHasError(((min, _)) => (min, true))
            }
            setIsInputFocused(((min, _)) => (min, false))
          }}
          onChange={ev => {
            setMaxSlideVal(_ => ReactEvent.Form.target(ev)["value"])
          }}
          onKeyUp={ev => {
            let key = ev->ReactEvent.Keyboard.key
            let keyCode = ev->ReactEvent.Keyboard.keyCode

            let maxVal = maxSlideVal
            let minSliderValue = minSlide.value->JSON.Decode.float->Option.getOr(0.)
            if key === "Enter" || keyCode === 13 {
              if maxVal <= max && maxVal >= minSliderValue {
                setHasError(((min, _)) => (min, false))
                maxSlide.onChange(ev->Identity.anyTypeToReactEvent)
              } else {
                setHasError(((min, _)) => (min, true))
              }
            }
          }}
          onFocus={_ => setIsInputFocused(((min, _)) => (min, true))}
        />
      </span>
    </div>
  </div>
}
