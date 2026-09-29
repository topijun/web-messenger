/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:serverpod/serverpod.dart' as _i1;

/// Thrown when a Device does not belong to the authenticated user.
abstract class MessengerDeviceNotFoundException
    implements
        _i1.SerializableException,
        _i1.SerializableModel,
        _i1.ProtocolSerialization {
  MessengerDeviceNotFoundException._({required this.clientId});

  factory MessengerDeviceNotFoundException({required _i1.UuidValue clientId}) =
      _MessengerDeviceNotFoundExceptionImpl;

  factory MessengerDeviceNotFoundException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return MessengerDeviceNotFoundException(
      clientId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['clientId'],
      ),
    );
  }

  _i1.UuidValue clientId;

  /// Returns a shallow copy of this [MessengerDeviceNotFoundException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MessengerDeviceNotFoundException copyWith({_i1.UuidValue? clientId});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MessengerDeviceNotFoundException',
      'clientId': clientId.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MessengerDeviceNotFoundException',
      'clientId': clientId.toJson(),
    };
  }

  @override
  String toString() {
    return 'MessengerDeviceNotFoundException(clientId: $clientId)';
  }
}

class _MessengerDeviceNotFoundExceptionImpl
    extends MessengerDeviceNotFoundException {
  _MessengerDeviceNotFoundExceptionImpl({required _i1.UuidValue clientId})
    : super._(clientId: clientId);

  /// Returns a shallow copy of this [MessengerDeviceNotFoundException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MessengerDeviceNotFoundException copyWith({_i1.UuidValue? clientId}) {
    return MessengerDeviceNotFoundException(
      clientId: clientId ?? this.clientId,
    );
  }
}
