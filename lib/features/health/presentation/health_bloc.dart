import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:viva_livre_app/features/health/domain/entities/health_entry.dart';
import 'package:viva_livre_app/features/health/domain/repositories/health_repository.dart'; // Assuming this repository will be created

part 'health_event.dart';
part 'health_state.dart';

class HealthBloc extends Bloc<HealthEvent, HealthState> {
  final HealthRepository _healthRepository;

  HealthBloc({required HealthRepository healthRepository})
    : _healthRepository = healthRepository,
      super(HealthInitial()) {
    on<FetchHealthEntries>(_onFetchHealthEntries);
    on<AddHealthEntry>(_onAddHealthEntry);
  }

  Future<void> _onFetchHealthEntries(
    FetchHealthEntries event,
    Emitter<AuthState> emit,
  ) async {
    emit(HealthLoading());
    try {
      final entries = await _healthRepository.getHealthEntries();
      emit(HealthEntriesLoaded(entries));
    } catch (e) {
      emit(HealthError('Failed to load entries. Please try again.'));
    }
  }

  Future<void> _onAddHealthEntry(
    AddHealthEntry event,
    Emitter<AuthState> emit,
  ) async {
    // No need to emit HealthLoading here as the UI already shows a potential loading state (e.g., on button press)
    // and we want to immediately reflect the result after the operation completes.
    try {
      await _healthRepository.addHealthEntry(event.entry);
      // After adding, refresh the list to show the new entry
      add(FetchHealthEntries()); // Re-fetch entries to update the list
      emit(HealthEntryAdded()); // Indicate that an entry was added successfully
    } catch (e) {
      emit(HealthError('Failed to add entry. Please try again.'));
    }
  }
}
