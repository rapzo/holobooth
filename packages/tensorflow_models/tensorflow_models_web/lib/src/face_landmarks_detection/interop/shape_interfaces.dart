@JS()
library shape_interfaces;

import "package:js/js.dart";

import "common_interfaces.dart" show Keypoint;

/// @license
/// Copyright 2021 Google LLC. All Rights Reserved.
/// Licensed under the Apache License, Version 2.0 (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
/// https://www.apache.org/licenses/LICENSE-2.0
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.
/// =============================================================================
/// A rectangle that contains center point, height, width and rotation info.
/// Can be normalized or non-normalized.
@anonymous
@JS()
abstract class Rect {
  external num get xCenter;
  external set xCenter(num v);
  external num get yCenter;
  external set yCenter(num v);
  external num get height;
  external set height(num v);
  external num get width;
  external set width(num v);
  external num get rotation;
  external set rotation(num v);
  external factory Rect(
      {num xCenter, num yCenter, num height, num width, num rotation});
}

@anonymous
@JS()
abstract class BoundingBox {
  external num get xMin;
  external set xMin(num v);
  external num get yMin;
  external set yMin(num v);
  external num get xMax;
  external set xMax(num v);
  external num get yMax;
  external set yMax(num v);
  external num get width;
  external set width(num v);
  external num get height;
  external set height(num v);
  external factory BoundingBox(
      {num xMin, num yMin, num xMax, num yMax, num width, num height});
}

@anonymous
@JS()
abstract class AnchorTensor {
  external factory AnchorTensor({dynamic x, dynamic y, dynamic w, dynamic h});
}

@anonymous
@JS()
abstract class LocationData {
  external BoundingBox get boundingBox;
  external set boundingBox(BoundingBox v);
  external BoundingBox get relativeBoundingBox;
  external set relativeBoundingBox(BoundingBox v);
  external List<Keypoint> get relativeKeypoints;
  external set relativeKeypoints(List<Keypoint> v);
  external factory LocationData(
      {BoundingBox boundingBox,
      BoundingBox relativeBoundingBox,
      List<Keypoint> relativeKeypoints});
}

@anonymous
@JS()
abstract class Detection {
  external List<num> get score;
  external set score(List<num> v);
  external LocationData get locationData;
  external set locationData(LocationData v);
  external List<String> get label;
  external set label(List<String> v);
  external List<num> get labelId;
  external set labelId(List<num> v);
  external num get ind;
  external set ind(num v);
  external factory Detection(
      {List<num> score,
      LocationData locationData,
      List<String> label,
      List<num> labelId,
      num ind});
}
