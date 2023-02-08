//  Created by react-native-create-bridge

import { NativeModules, NativeEventEmitter } from "react-native";

const { EpsonEposSDK } = NativeModules;

const EpsonEposSDKEmitter = new NativeEventEmitter(EpsonEposSDK);

export default {
  exampleMethod() {
    return EpsonEposSDK.exampleMethod();
  },

  discoverPrinters() {
    return EpsonEposSDK.discoverPrinters();
  },

  connect(target, printerSeries, language, timeout) {
    return EpsonEposSDK.connect(
      target,
      printerSeries,
      language,
      timeout
    );
  },

  printSimpleText(text) {
    return EpsonEposSDK.printSimpleText(text);
  },

  printText(text, font, alignment, width, height) {
    return EpsonEposSDK.printText(text, font, alignment, width, height);
  },

  printImage(imageurl, mode, halftone) {
    return EpsonEposSDK.printImage(imageurl, mode, halftone);
  },

  printBase64Image(base64image, mode, halftone) {
    return EpsonEposSDK.printBase64Image(base64image, mode, halftone);
  },

  cutPaper() {
    return EpsonEposSDK.cutPaper();
  },

  openCashDrawer() {
    return EpsonEposSDK.openCashDrawer();
  },

  getStatus() {
    return EpsonEposSDK.getStatus();
  },

  disconnect() {
    return EpsonEposSDK.disconnect();
  },

  emitter: EpsonEposSDKEmitter,

  EPOS2_FONT_A: EpsonEposSDK.EPOS2_FONT_A,
  EPOS2_FONT_B: EpsonEposSDK.EPOS2_FONT_B,
  EPOS2_ALIGN_LEFT: EpsonEposSDK.EPOS2_ALIGN_LEFT,
  EPOS2_ALIGN_CENTER: EpsonEposSDK.EPOS2_ALIGN_CENTER,
  EPOS2_ALIGN_RIGHT: EpsonEposSDK.EPOS2_ALIGN_RIGHT,
  EPOS2_TM_M10: EpsonEposSDK.EPOS2_TM_M10,
  EPOS2_TM_M30: EpsonEposSDK.EPOS2_TM_M30,
  EPOS2_TM_P20: EpsonEposSDK.EPOS2_TM_P20,
  EPOS2_TM_P60: EpsonEposSDK.EPOS2_TM_P60,
  EPOS2_TM_P60II: EpsonEposSDK.EPOS2_TM_P60II,
  EPOS2_TM_P80: EpsonEposSDK.EPOS2_TM_P80,
  EPOS2_TM_T20: EpsonEposSDK.EPOS2_TM_T20,
  EPOS2_TM_T60: EpsonEposSDK.EPOS2_TM_T60,
  EPOS2_TM_T70: EpsonEposSDK.EPOS2_TM_T70,
  EPOS2_TM_T81: EpsonEposSDK.EPOS2_TM_T81,
  EPOS2_TM_T82: EpsonEposSDK.EPOS2_TM_T82,
  EPOS2_TM_T83: EpsonEposSDK.EPOS2_TM_T83,
  EPOS2_TM_T88: EpsonEposSDK.EPOS2_TM_T88,
  EPOS2_TM_T90: EpsonEposSDK.EPOS2_TM_T90,
  EPOS2_TM_T90KP: EpsonEposSDK.EPOS2_TM_T90KP,
  EPOS2_TM_U220: EpsonEposSDK.EPOS2_TM_U220,
  EPOS2_TM_U330: EpsonEposSDK.EPOS2_TM_U330,
  EPOS2_TM_L90: EpsonEposSDK.EPOS2_TM_L90,
  EPOS2_TM_H6000: EpsonEposSDK.EPOS2_TM_H6000,
  EPOS2_MODEL_ANK: EpsonEposSDK.EPOS2_MODEL_ANK,
  EPOS2_MODEL_JAPANESE: EpsonEposSDK.EPOS2_MODEL_JAPANESE,
  EPOS2_MODEL_CHINESE: EpsonEposSDK.EPOS2_MODEL_CHINESE,
  EPOS2_MODEL_TAIWAN: EpsonEposSDK.EPOS2_MODEL_TAIWAN,
  EPOS2_MODEL_KOREAN: EpsonEposSDK.EPOS2_MODEL_KOREAN,
  EPOS2_MODEL_THAI: EpsonEposSDK.EPOS2_MODEL_THAI,
  EPOS2_MODEL_SOUTHASIA: EpsonEposSDK.EPOS2_MODEL_SOUTHASIA,
  EPOS2_MODE_MONO: EpsonEposSDK.EPOS2_MODE_MONO,
  EPOS2_MODE_GRAY16: EpsonEposSDK.EPOS2_MODE_GRAY16,
  EPOS2_HALFTONE_DITHER: EpsonEposSDK.EPOS2_HALFTONE_DITHER,
  EPOS2_HALFTONE_ERROR_DIFFUSION: EpsonEposSDK.EPOS2_HALFTONE_ERROR_DIFFUSION,
  EPOS2_HALFTONE_THRESHOLD: EpsonEposSDK.EPOS2_HALFTONE_THRESHOLD
};
