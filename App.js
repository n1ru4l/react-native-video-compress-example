import React, { Component } from "react";
import {
  Platform,
  TouchableWithoutFeedback,
  Text,
  View,
  CameraRoll,
  NativeModules
} from "react-native";
import { RNCamera } from "react-native-camera";

const { VideoCompressService } = NativeModules;

export default class App extends Component {
  state = {
    isRecording: false
  };
  camera = null;

  render() {
    const { state: { isRecording } } = this;
    return (
      <RNCamera
        ref={ref => {
          this.camera = ref;
        }}
        style={{
          flex: 1,
          flexDirection: "row",
          alignItems: "flex-end",
          justifyContent: "center",
          padding: 20
        }}
      >
        <TouchableWithoutFeedback
          onLongPress={async () => {
            if (!this.camera) {
              return;
            }
            this.setState({ isRecording: true });
            const { uri } = await this.camera.recordAsync({
              quality: RNCamera.Constants.VideoQuality["720p"]
            });
            this.setState({ isRecording: false });
            const compressedUri = await VideoCompressService.compressVideo(uri);
            await CameraRoll.saveToCameraRoll(uri);
            await CameraRoll.saveToCameraRoll(compressedUri);
          }}
          onPressOut={async () => {
            this.camera.stopRecording();
          }}
          style={{
            height: 100,
            width: 100,
            marginRight: "auto"
          }}
        >
          <View
            style={{
              height: 100,
              width: 100,
              backgroundColor: isRecording ? "red" : "white",
              borderRadius: 100,
              overflow: "hidden"
            }}
          />
        </TouchableWithoutFeedback>
      </RNCamera>
    );
  }
}
