Title ""

Controls {
}

Definitions {
	Constant "Const.Substrate" {
		Species = "ArsenicActiveConcentration"
		Value = 1e+15
	}
	Refinement "Ref.SiAct" {
		MaxElementSize = ( 0.0033333333333333 0.003125 )
		MinElementSize = ( 0.0005 0.0005 )
		RefineFunction = MaxTransDiff(Variable = "DopingConcentration",Value = 1)
	}
}

Placements {
	Constant "PlaceCD.Substrate" {
		Reference = "Const.Substrate"
		EvaluateWindow {
			Element = region ["R.Substrate"]
		}
	}
	Constant "PlaceCD.UniDop" {
		Reference = "Const.UniDop"
		EvaluateWindow {
			Element = region ["R.Substrate"]
		}
	}
	Refinement "RefPlace.Substrate" {
		Reference = "Ref.Substrate"
		RefineWindow = region ["R.Substrate"]
	}
	Refinement "RefPlace.GOX" {
		Reference = "Ref.GOX"
		RefineWindow = region ["R.Gateox"]
	}
}

