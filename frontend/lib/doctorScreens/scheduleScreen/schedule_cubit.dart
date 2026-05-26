import 'package:flutter_bloc/flutter_bloc.dart';
import 'schedule_bloc.dart';
import 'schedule_usecase.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final GetScheduleUseCase _getSchedule;
  final ConfirmAppointmentUseCase _confirm;
  final RejectAppointmentUseCase _reject;

  DateTime _selectedDate = DateTime.now();
  List<dynamic> _all = [];

  ScheduleCubit(this._getSchedule, this._confirm, this._reject)
      : super(ScheduleInitial());

  Future<void> load() async {
    emit(ScheduleLoading());
    try {
      final list = await _getSchedule();
      _all = list;
      emit(ScheduleLoaded(list, _selectedDate));
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    if (_all.isNotEmpty) {
      emit(ScheduleLoaded(List.from(_all), _selectedDate));
    }
  }

  Future<void> confirm(int id) async {
    emit(ScheduleActionInProgress(id));
    try {
      await _confirm(id);
      await load();
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }

  Future<void> reject(int id) async {
    emit(ScheduleActionInProgress(id));
    try {
      await _reject(id);
      await load();
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }
}
