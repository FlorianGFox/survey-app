import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/response_option.dart';
import '../../domain/entities/response.dart';
import '../../domain/usecases/start_survey_usecase.dart';
import '../../domain/usecases/submit_survey_usecase.dart';

part 'survey_event.dart';
part 'survey_state.dart';

class SurveyBloc extends Bloc<SurveyEvent, SurveyState> {
  int _currentQuestion;
  List<QuestionState> questionStates;

  final StartSurveyUseCase startSurveyUseCase;
  final SubmitResponseUseCase submitResponseUseCase;

  SurveyBloc({
    @required this.startSurveyUseCase,
    @required this.submitResponseUseCase,
  });

  @override
  SurveyState get initialState => GreetingState();

  @override
  Stream<SurveyState> mapEventToState(
    SurveyEvent event,
  ) async* {
    if (event is StartSurveyEvent) {
      yield* _mapStartSurveyEvent();
    } else if (event is NextQuestionEvent) {
      yield* _mapNextQuestionEvent(event);
    } else if (event is SubmitAnswersEvent) {
      yield* _mapSubmitAnswerEvent();
    } else if (event is PreviousQuestionEvent) {
      yield* _mapPreviosQuestionEvent();
    } else if (event is RestartEvent) {
      yield* _mapRestartEvent();
    } else if (event is OpenAdminMenuEvent) {
      yield* _mapOpenAdminMenuEvent();
    }
  }

  Stream<SurveyState> _mapOpenAdminMenuEvent() async* {
    yield AdminMenuState();
  }

  Stream<SurveyState> _mapRestartEvent() async* {
    _currentQuestion = null;
    questionStates = null;
    yield initialState;
  }

  Stream<SurveyState> _mapPreviosQuestionEvent() async* {
    if (_currentQuestion > 0) {
      if (_currentQuestion == null || questionStates == null) {
        yield FailureState();
      } else {
        _currentQuestion--;
        yield questionStates[_currentQuestion];
      }
    }
  }

  Stream<SurveyState> _mapSubmitAnswerEvent() async* {
    yield LoadingState();
    if (questionStates != null) {
      String uuid = Uuid().v1();
      submitResponseUseCase(questionStates
          .map((questionState) => Response(
                questionRespondedTo: questionState.question,
                selectedResponse: questionState.response,
                responderId: uuid,
              ))
          .toList());
      yield ThankYouState();
    } else {
      yield FailureState();
    }
  }

  Stream<SurveyState> _mapNextQuestionEvent(NextQuestionEvent event) async* {
    if (_currentQuestion == null || questionStates == null) {
      yield FailureState();
    } else {
      _addResponseToCurrentState(event.response);
      _currentQuestion++;
      yield questionStates[_currentQuestion];
    }
  }

  void _addResponseToCurrentState(ResponseOption response) {
    questionStates[_currentQuestion] = QuestionState.responded(
      oldState: questionStates[_currentQuestion],
      response: response,
    );
  }

  Stream<SurveyState> _mapStartSurveyEvent() async* {
    yield LoadingState();
    Either<Failure, List<Question>> result = await startSurveyUseCase(NoParams);
    yield result.fold(
      (failure) => FailureState(),
      (questions) {
        _currentQuestion = 0;
        questionStates = [];
        for (int i = 0; i < questions.length; i++) {
          questionStates.add(QuestionState(
            question: questions[i],
            numberTotalQuestions: questions.length,
            questionIndex: i,
          ));
        }
        return questionStates[_currentQuestion];
      },
    );
  }
}
