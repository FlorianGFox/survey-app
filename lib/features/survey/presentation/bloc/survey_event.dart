part of 'survey_bloc.dart';

abstract class SurveyEvent extends Equatable {
  @override
  List<Object> get props => [];

  const SurveyEvent();
}

class StartSurveyEvent extends SurveyEvent {}

class SubmitAnswersEvent extends SurveyEvent {}

class NextQuestionEvent extends SurveyEvent {}

class PreviousQuestionEvent extends SurveyEvent {}

class RestartEvent extends SurveyEvent {}

class OpenAdminMenuEvent extends SurveyEvent {}
