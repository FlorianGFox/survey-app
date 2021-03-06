import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:survey_app/features/survey/presentation/widgets/survey_alert_dialog.dart';

import '../../domain/entities/response_option.dart';
import '../bloc/survey_bloc.dart';
import '../fixed_values/survey_sizes.dart';
import '../widgets/next_button.dart';
import '../widgets/standard_question.dart';
import '../widgets/top_bar.dart';

class QuestionPage extends StatefulWidget {
  final QuestionState questionState;

  QuestionPage({
    Key key,
    @required this.questionState,
  }) : super(key: key);

  @override
  _QuestionPageState createState() =>
      _QuestionPageState(questionState.response);
}

class _QuestionPageState extends State<QuestionPage> {
  var submitButtonText = 'Absenden';
  var nextButtonText = 'Weiter';

  ResponseOption response;

  _QuestionPageState(this.response);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: SurveySizes.scaledWidth(SurveySizes.paddingSize, context),
      ),
      child: Column(
        children: <Widget>[
          TopBar(
            currentQuestion: widget.questionState.questionIndex + 1,
            numberQuestions: widget.questionState.numberTotalQuestions,
            onBackButtonTap: () {
              if (!_isFirstQuestion()) {
                BlocProvider.of<SurveyBloc>(context)
                    .add(PreviousQuestionEvent());
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SurveyAlertDialog(
                      onOk: _restartSurvey,
                      body: 'Alle ausgewählten Antworten gehen dabei verloren.',
                      title: 'Zur Startseite zurückkehren?',
                    );
                  },
                );
              }
            },
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.all(SurveySizes.scaledHeight(
                  SurveySizes.standardDistance, context)),
              child: Column(
                children: <Widget>[
                  StandardQuestion(
                    question: widget.questionState.question,
                    answerSelectedValue: response,
                    onAnswerSelected: (value) {
                      setState(() {
                        response = value;
                        BlocProvider.of<SurveyBloc>(context)
                            .add(ResponseSelectedEvent(response));
                      });
                    },
                  ),
                  NextButton(
                    activated: (response != null),
                    onPressed: () {
                      if (_isLastQuestion()) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SurveyAlertDialog(
                              onOk: _submitSurvey,
                              title: 'Antworten absenden?',
                              body:
                                  'Alle antworten werden damit anonym gespeichert und können nicht mehr geändert werden.',
                            );
                          },
                        );
                      } else {
                        BlocProvider.of<SurveyBloc>(context)
                            .add(NextQuestionEvent());
                      }
                    },
                    text: _isLastQuestion() ? submitButtonText : nextButtonText,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isLastQuestion() {
    return (widget.questionState.questionIndex + 1 ==
        widget.questionState.numberTotalQuestions);
  }

  bool _isFirstQuestion() {
    return (widget.questionState.questionIndex == 0);
  }

  void _restartSurvey() {
    BlocProvider.of<SurveyBloc>(context).add(RestartEvent());
  }

  void _submitSurvey() {
    BlocProvider.of<SurveyBloc>(context).add(SubmitAnswersEvent());
  }
}
