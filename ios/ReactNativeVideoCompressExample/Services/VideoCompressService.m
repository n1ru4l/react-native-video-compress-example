//
//  VideoCompressService.m
//  ReactNativeVideoCompressExample
//
//  Created by Laurin Quast on 26.02.18.
//  Copyright © 2018 Laurin Quast. All rights reserved.
//

#import "VideoCompressService.h"

@implementation VideoCompressService

RCT_EXPORT_MODULE();

RCT_REMAP_METHOD(compressVideo,
                  inputFileUrl:(NSString *)inputFilePath
                  compressVideoResolver:(RCTPromiseResolveBlock)resolve
                  compressVideoRejecter:(RCTPromiseRejectBlock)reject)
{
  NSString *sanitizedInputFilePath = [inputFilePath stringByReplacingOccurrencesOfString:@"file:/" withString:@""];
  NSURL *inputFileUrl = [NSURL fileURLWithPath:sanitizedInputFilePath];
  NSURL *outputFileUrl = [self createTemporaryFileUrl];
  AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:inputFileUrl options:nil];
  AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:urlAsset presetName:AVAssetExportPresetMediumQuality];
  exportSession.outputURL = outputFileUrl;
  exportSession.outputFileType = AVFileTypeQuickTimeMovie;
  exportSession.shouldOptimizeForNetworkUse = YES;
  [exportSession exportAsynchronouslyWithCompletionHandler:^{
    if (exportSession.error) {
      reject(@"error", @"compress video", exportSession.error);
      return;
    }
    resolve([outputFileUrl absoluteString]);
  }];
}

- (NSURL*)createTemporaryFileUrl {
  NSString *tempFileName = [NSString stringWithFormat:@"%@%@", [[NSUUID new] UUIDString], @".mp4"];
  NSString *tempDirectory = NSTemporaryDirectory();
  NSString *tempPath = [tempDirectory stringByAppendingPathComponent:tempFileName];
  return [NSURL fileURLWithPath:tempPath];
}
@end
