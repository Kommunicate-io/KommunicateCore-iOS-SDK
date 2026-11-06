#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const KMCoreVoiceAPIErrorDomain;

typedef NS_ENUM(NSInteger, KMCoreVoiceAPIErrorCode) {
    KMCoreVoiceAPIErrorInvalidResponse = 1,
    KMCoreVoiceAPIErrorHTTPFailure,
    KMCoreVoiceAPIErrorResponseTooLarge,
    KMCoreVoiceAPIErrorInvalidPayload
};

@interface KMCoreVoiceAudioResponse : NSObject

@property (nonatomic, copy, readonly) NSData *audioData;
@property (nonatomic, copy, nullable, readonly) NSString *contentType;

- (instancetype)initWithAudioData:(NSData *)audioData
                      contentType:(nullable NSString *)contentType NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

@interface KMCoreVoiceAPIClient : NSObject

@property (class, nonatomic, copy, readonly) NSString *defaultBaseURL;

- (instancetype)init;
- (instancetype)initWithBaseURL:(NSString *)baseURL NS_DESIGNATED_INITIALIZER;

- (void)transcribePCMAudio:(NSData *)audioData
            conversationID:(int64_t)conversationID
                completion:(void (^)(NSString * _Nullable transcript, NSError * _Nullable error))completion;

- (void)synthesizeText:(NSString *)text
            completion:(void (^)(KMCoreVoiceAudioResponse * _Nullable response, NSError * _Nullable error))completion;

- (void)cancelActiveRequest;

@end

NS_ASSUME_NONNULL_END
