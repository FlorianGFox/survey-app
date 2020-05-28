import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/survey_bloc.dart';
import '../fixed_values/survey_paths.dart';
import '../fixed_values/survey_sizes.dart';

class AdminMenuPage extends StatelessWidget {
  const AdminMenuPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var titleAdminMenu = 'Admin Menu';
    var newSurveyButtonText = 'Neuer Fragebogen';

    return Container(
      padding: EdgeInsets.all(SurveySizes.paddingSize),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              ImagePaths.healthProIcon,
              color: Theme.of(context).accentColor,
              width: SurveySizes.scaledWidth(SurveySizes.imageWidth, context),
            ),
            SizedBox(height: SurveySizes.standardDistance),
            Text(
              titleAdminMenu,
              style: Theme.of(context).textTheme.headline2.copyWith(
                  fontSize: SurveySizes.scaledWidth(
                      SurveySizes.bigFontSize, context)),
            ),
            SizedBox(height: SurveySizes.standardDistance),
            SizedBox(
              width: double.infinity,
              height: SurveySizes.scaledHeight(SurveySizes.buttonSize, context),
              child: RaisedButton(
                onPressed: () {
                  BlocProvider.of<SurveyBloc>(context).add(RestartEvent());
                },
                child: Text(
                  newSurveyButtonText,
                  style: Theme.of(context).textTheme.button.copyWith(
                      fontSize: SurveySizes.scaledHeight(
                          SurveySizes.buttonFontSize, context)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
