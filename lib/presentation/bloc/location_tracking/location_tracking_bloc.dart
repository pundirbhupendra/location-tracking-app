import 'package:flutter_bloc/flutter_bloc.dart';
import 'location_tracking_event.dart';
import 'location_tracking_state.dart';

abstract class LocationTrackingBloc extends Bloc<LocationTrackingEvent, LocationTrackingState> {
  LocationTrackingBloc(super.initialState);
}
