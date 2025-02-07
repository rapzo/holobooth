// ignore_for_file: public_member_api_docs

import 'package:equatable/equatable.dart';
import 'package:face_geometry/face_geometry.dart';
import 'package:meta/meta.dart';
import 'package:tensorflow_models_platform_interface/tensorflow_models_platform_interface.dart'
    as tf;

@immutable
class _EyeKeypoint {
  _EyeKeypoint({
    required this.topEyeLid,
    required this.bottomEyeLid,
  }) : distance = topEyeLid.distanceTo(bottomEyeLid);

  /// Creates an instance of [_EyeKeypoint] from the left eye keypoints.
  _EyeKeypoint.left(
    List<tf.Keypoint> keypoints,
  ) : this(
          topEyeLid: keypoints[159],
          bottomEyeLid: keypoints[145],
        );

  /// Creates an instance of [_EyeKeypoint] from the right eye keypoints.
  _EyeKeypoint.right(
    List<tf.Keypoint> keypoints,
  ) : this(
          topEyeLid: keypoints[386],
          bottomEyeLid: keypoints[374],
        );

  final tf.Keypoint topEyeLid;
  final tf.Keypoint bottomEyeLid;
  final double distance;
}

@immutable
abstract class _EyeGeometry extends Equatable {
  _EyeGeometry._compute({
    required _EyeKeypoint eyeKeypoint,
    required tf.BoundingBox boundingBox,
    double? previousMinRatio,
    double? previousMaxRatio,
    double? previousMeanRatio,
    int population = 0,
  })  : distance = _computeDistanceRatio(
          distance: eyeKeypoint.distance,
          faceHeight: boundingBox.height,
        ),
        meanRatio = population < maxPopulation
            ? _computeMeanRatio(
                distance: eyeKeypoint.distance,
                faceHeight: boundingBox.height,
                previousMeanRatio: previousMeanRatio,
                population: population,
              )
            : previousMeanRatio ?? 0.0,
        minRatio = _computeMinRatio(
          distance: eyeKeypoint.distance,
          faceHeight: boundingBox.height,
          previousMinRatio: previousMinRatio,
        ),
        maxRatio = _computeMaxRatio(
          distance: eyeKeypoint.distance,
          faceHeight: boundingBox.height,
          previousMaxRatio: previousMaxRatio,
        ),
        isClosed = _computeIsClosed(
          distance: eyeKeypoint.distance,
          faceHeight: boundingBox.height,
          meanRatio: population < maxPopulation
              ? _computeMeanRatio(
                  distance: eyeKeypoint.distance,
                  faceHeight: boundingBox.height,
                  previousMeanRatio: previousMeanRatio,
                  population: population,
                )
              : previousMeanRatio ?? 0.0,
        ),
        population = population + 1;

  /// An empty instance of [_EyeGeometry].
  ///
  /// This is used when the keypoints are not available.
  const _EyeGeometry._empty({
    double? minRatio,
    double? maxRatio,
    this.meanRatio,
    this.population = 0,
  })  : distance = 0,
        isClosed = false,
        maxRatio = minRatio,
        minRatio = maxRatio;

  static double? _computeDistanceRatio({
    required double distance,
    required num faceHeight,
  }) {
    if (faceHeight == 0 || faceHeight < distance) return null;
    return distance / faceHeight;
  }

  /// Computes the mean distance of some [_EyeKeypoint].
  static double? _computeMeanRatio({
    required double distance,
    required int population,
    required num faceHeight,
    required double? previousMeanRatio,
  }) {
    if (faceHeight == 0 || faceHeight < distance) return previousMeanRatio;

    final heightRatio = distance / faceHeight;
    final total = (previousMeanRatio ?? 0) * population + heightRatio;
    return total / (population + 1);
  }

  static double? _computeMaxRatio({
    required double distance,
    required num faceHeight,
    required double? previousMaxRatio,
  }) {
    if (faceHeight == 0 || faceHeight < distance) return previousMaxRatio;

    final heightRatio = distance / faceHeight;
    return (previousMaxRatio == null || heightRatio > previousMaxRatio) &&
            heightRatio < 1
        ? heightRatio
        : previousMaxRatio;
  }

  static double? _computeMinRatio({
    required double distance,
    required num faceHeight,
    required double? previousMinRatio,
  }) {
    if (faceHeight == 0 || faceHeight < distance) return previousMinRatio;

    final heightRatio = distance / faceHeight;
    return ((previousMinRatio == null || heightRatio < previousMinRatio) &&
            heightRatio > 0)
        ? heightRatio
        : previousMinRatio;
  }

  static bool _computeIsClosed({
    required double distance,
    required num faceHeight,
    required double? meanRatio,
  }) {
    if (faceHeight == 0 || faceHeight < distance || meanRatio == null) {
      return false;
    }

    final eyeHeightRatio = distance / faceHeight;
    return eyeHeightRatio < meanRatio * 0.8;
  }

  /// The maximum number of keypoints that can be used to compute [meanRatio].
  ///
  /// This is used to avoid overflow.
  static const maxPopulation = 1000;

  /// The number of keypoints that have been used to compute [meanRatio].
  final int population;

  /// The maxmium ratio between the eye distance and the face height.
  final double? maxRatio;

  /// The minimum ratio between the eye distance and the face height.
  final double? minRatio;

  /// Whether the eye is closed or not.
  ///
  /// Detection works after the first blink to make sure we have the correct
  /// minimum and maximum values.
  final bool isClosed;

  /// The distance between the top and bottom eye lids.
  final double? distance;

  /// The mean distance between the top and bottom eye lids.
  final double? meanRatio;

  /// Update the eye geometry.
  _EyeGeometry update(
    List<tf.Keypoint> keypoints,
    tf.BoundingBox boundingBox,
  );

  @override
  List<Object?> get props => [
        isClosed,
        distance,
        meanRatio,
        minRatio,
        maxRatio,
      ];
}

class LeftEyeGeometry extends _EyeGeometry {
  factory LeftEyeGeometry({
    required List<tf.Keypoint> keypoints,
    required tf.BoundingBox boundingBox,
  }) {
    if (keypoints.length > 160) {
      return LeftEyeGeometry._compute(
        eyeKeypoint: _EyeKeypoint.left(keypoints),
        boundingBox: boundingBox,
      );
    } else {
      return const LeftEyeGeometry.empty();
    }
  }

  LeftEyeGeometry._compute({
    required super.eyeKeypoint,
    required super.boundingBox,
    super.population,
    super.previousMinRatio,
    super.previousMaxRatio,
    super.previousMeanRatio,
  }) : super._compute();

  const LeftEyeGeometry.empty({
    super.minRatio,
    super.maxRatio,
    super.meanRatio,
    super.population,
  }) : super._empty();

  @override
  LeftEyeGeometry update(
    List<tf.Keypoint> keypoints,
    tf.BoundingBox boundingBox,
  ) {
    if (keypoints.length > 160) {
      return LeftEyeGeometry._compute(
        eyeKeypoint: _EyeKeypoint.left(keypoints),
        boundingBox: boundingBox,
        previousMinRatio: minRatio,
        previousMaxRatio: maxRatio,
        previousMeanRatio: meanRatio,
        population: population,
      );
    } else {
      return LeftEyeGeometry.empty(
        minRatio: minRatio,
        maxRatio: maxRatio,
        meanRatio: meanRatio,
        population: population,
      );
    }
  }
}

class RightEyeGeometry extends _EyeGeometry {
  factory RightEyeGeometry({
    required List<tf.Keypoint> keypoints,
    required tf.BoundingBox boundingBox,
  }) {
    if (keypoints.length > 375) {
      return RightEyeGeometry._compute(
        eyeKeypoint: _EyeKeypoint.left(keypoints),
        boundingBox: boundingBox,
      );
    } else {
      return const RightEyeGeometry.empty();
    }
  }

  RightEyeGeometry._compute({
    required super.eyeKeypoint,
    required super.boundingBox,
    super.previousMinRatio,
    super.previousMaxRatio,
    super.previousMeanRatio,
    super.population,
  }) : super._compute();

  const RightEyeGeometry.empty({
    super.minRatio,
    super.maxRatio,
    super.meanRatio,
    super.population,
  }) : super._empty();

  @override
  RightEyeGeometry update(
    List<tf.Keypoint> keypoints,
    tf.BoundingBox boundingBox,
  ) {
    if (keypoints.length > 375) {
      return RightEyeGeometry._compute(
        eyeKeypoint: _EyeKeypoint.right(keypoints),
        boundingBox: boundingBox,
        previousMinRatio: minRatio,
        previousMaxRatio: maxRatio,
        previousMeanRatio: meanRatio,
        population: population,
      );
    } else {
      return RightEyeGeometry.empty(
        minRatio: minRatio,
        maxRatio: maxRatio,
        meanRatio: meanRatio,
        population: population,
      );
    }
  }
}
