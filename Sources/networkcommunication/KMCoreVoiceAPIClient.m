#import "KMCoreVoiceAPIClient.h"
#import "KMCoreUserDefaultsHandler.h"

NSString *const KMCoreVoiceAPIErrorDomain = @"io.kommunicate.core.voice-api";

static NSString *const KMCoreDefaultVoiceBaseURL = @"https://omni-channel.kommunicate.io";
static NSUInteger const KMCoreVoiceMaximumJSONBytes = 1024 * 1024;
static NSUInteger const KMCoreVoiceMaximumAudioBytes = 10 * 1024 * 1024;
static NSUInteger const KMCoreVoiceMaximumErrorBytes = 64 * 1024;

@interface KMCoreVoiceAPIClient ()

@property (nonatomic, copy) NSString *baseURL;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong, nullable) NSURLSessionDataTask *activeTask;
@property (nonatomic) NSUInteger generation;
@property (nonatomic, strong) NSLock *stateLock;

@end

@implementation KMCoreVoiceAudioResponse

- (instancetype)initWithAudioData:(NSData *)audioData contentType:(NSString *)contentType {
    self = [super init];
    if (self) {
        _audioData = [audioData copy];
        _contentType = [contentType copy];
    }
    return self;
}

@end

@implementation KMCoreVoiceAPIClient

+ (NSString *)defaultBaseURL {
    NSString *configuredURL = [KMCoreUserDefaultsHandler getVoiceBaseURL];
    return configuredURL.length > 0 ? configuredURL : KMCoreDefaultVoiceBaseURL;
}

- (instancetype)init {
    return [self initWithBaseURL:KMCoreVoiceAPIClient.defaultBaseURL];
}

- (instancetype)initWithBaseURL:(NSString *)baseURL {
    self = [super init];
    if (self) {
        _baseURL = [self.class normalizedBaseURL:baseURL];
        _stateLock = [[NSLock alloc] init];

        NSURLSessionConfiguration *configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration;
        configuration.timeoutIntervalForRequest = 15;
        configuration.timeoutIntervalForResource = 30;
        configuration.HTTPMaximumConnectionsPerHost = 1;
        _session = [NSURLSession sessionWithConfiguration:configuration];
    }
    return self;
}

- (void)dealloc {
    [self cancelActiveRequest];
    [self.session invalidateAndCancel];
}

- (void)transcribePCMAudio:(NSData *)audioData
            conversationID:(int64_t)conversationID
                completion:(void (^)(NSString * _Nullable, NSError * _Nullable))completion {
    NSURL *URL = [self URLForPath:@"voice/voice-to-text"];
    if (URL == nil || audioData.length == 0) {
        completion(nil, [self errorWithCode:KMCoreVoiceAPIErrorInvalidPayload
                               description:@"Voice audio is empty or the endpoint is invalid"]);
        return;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    request.HTTPBody = audioData;
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"16" forHTTPHeaderField:@"X-Audio-Bits-Per-Sample"];
    [request setValue:@"1" forHTTPHeaderField:@"X-Audio-Channel-Count"];
    [request setValue:@"16000" forHTTPHeaderField:@"X-Audio-Sample-Rate"];
    [request setValue:@"recognize" forHTTPHeaderField:@"X-Stt-Mode"];
    [request setValue:@"web" forHTTPHeaderField:@"X-Voice-Source"];
    [request setValue:[NSString stringWithFormat:@"%lld", conversationID]
   forHTTPHeaderField:@"X-Voice-Ucid"];

    NSUInteger generation = [self nextGeneration];
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
                          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (self == nil || ![self finishGeneration:generation]) {
            return;
        }
        NSError *validationError = [self validateResponse:response
                                                     data:data
                                                    error:error
                                             maximumBytes:KMCoreVoiceMaximumJSONBytes];
        if (validationError != nil) {
            completion(nil, validationError);
            return;
        }

        NSError *JSONError;
        id payload = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
        NSString *transcript = [self transcriptFromPayload:payload depth:0];
        if (JSONError != nil || transcript.length == 0) {
            completion(nil, [self errorWithCode:KMCoreVoiceAPIErrorInvalidPayload
                                   description:@"The voice-to-text response did not contain a transcript"]);
            return;
        }
        completion(transcript, nil);
    }];
    [self activateTask:task generation:generation];
}

- (void)synthesizeText:(NSString *)text
            completion:(void (^)(KMCoreVoiceAudioResponse * _Nullable, NSError * _Nullable))completion {
    NSString *normalizedText = [text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    NSURL *URL = [self URLForPath:@"voice/text-to-voice"];
    if (URL == nil || normalizedText.length == 0) {
        completion(nil, [self errorWithCode:KMCoreVoiceAPIErrorInvalidPayload
                               description:@"Text is empty or the endpoint is invalid"]);
        return;
    }

    NSError *JSONError;
    NSData *body = [NSJSONSerialization dataWithJSONObject:@{
        @"text": normalizedText,
        @"source": @"web",
        @"responseFormat": @"binary",
        @"sampleRate": @24000
    } options:0 error:&JSONError];
    if (body == nil) {
        completion(nil, JSONError);
        return;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    request.HTTPBody = body;
    [request setValue:@"audio/mpeg, audio/*;q=0.9" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    NSUInteger generation = [self nextGeneration];
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
                          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (self == nil || ![self finishGeneration:generation]) {
            return;
        }
        NSError *validationError = [self validateResponse:response
                                                     data:data
                                                    error:error
                                             maximumBytes:KMCoreVoiceMaximumAudioBytes];
        if (validationError != nil) {
            completion(nil, validationError);
            return;
        }
        NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
        completion([[KMCoreVoiceAudioResponse alloc] initWithAudioData:data
                                                           contentType:HTTPResponse.allHeaderFields[@"Content-Type"]], nil);
    }];
    [self activateTask:task generation:generation];
}

- (void)cancelActiveRequest {
    [self.stateLock lock];
    self.generation += 1;
    NSURLSessionDataTask *task = self.activeTask;
    self.activeTask = nil;
    [self.stateLock unlock];
    [task cancel];
}

- (NSUInteger)nextGeneration {
    [self.stateLock lock];
    self.generation += 1;
    NSUInteger generation = self.generation;
    NSURLSessionDataTask *previousTask = self.activeTask;
    self.activeTask = nil;
    [self.stateLock unlock];
    [previousTask cancel];
    return generation;
}

- (void)activateTask:(NSURLSessionDataTask *)task generation:(NSUInteger)generation {
    [self.stateLock lock];
    BOOL current = self.generation == generation;
    if (current) {
        self.activeTask = task;
    }
    [self.stateLock unlock];

    if (current) {
        [task resume];
    } else {
        [task cancel];
    }
}

- (BOOL)finishGeneration:(NSUInteger)generation {
    [self.stateLock lock];
    BOOL current = self.generation == generation;
    if (current) {
        self.activeTask = nil;
    }
    [self.stateLock unlock];
    return current;
}

- (NSError *)validateResponse:(NSURLResponse *)response
                         data:(NSData *)data
                        error:(NSError *)error
                 maximumBytes:(NSUInteger)maximumBytes {
    if (error != nil) {
        return error;
    }
    if (![response isKindOfClass:NSHTTPURLResponse.class]) {
        return [self errorWithCode:KMCoreVoiceAPIErrorInvalidResponse
                       description:@"The voice service returned an invalid response"];
    }
    if (data.length > maximumBytes) {
        return [self errorWithCode:KMCoreVoiceAPIErrorResponseTooLarge
                       description:@"The voice service response exceeded the allowed size"];
    }

    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
    if (HTTPResponse.statusCode < 200 || HTTPResponse.statusCode >= 300) {
        NSUInteger length = MIN(data.length, KMCoreVoiceMaximumErrorBytes);
        NSString *body = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, length)]
                                              encoding:NSUTF8StringEncoding];
        NSString *description = [NSString stringWithFormat:@"Voice service request failed (%ld)%@",
                                 (long)HTTPResponse.statusCode,
                                 body.length > 0 ? [@": " stringByAppendingString:body] : @""];
        return [self errorWithCode:KMCoreVoiceAPIErrorHTTPFailure description:description];
    }
    if (data.length == 0) {
        return [self errorWithCode:KMCoreVoiceAPIErrorInvalidResponse
                       description:@"The voice service returned an empty response"];
    }
    return nil;
}

- (NSString *)transcriptFromPayload:(id)payload depth:(NSUInteger)depth {
    if (payload == nil || payload == NSNull.null || depth > 3) {
        return @"";
    }
    if ([payload isKindOfClass:NSString.class]) {
        return [payload stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    }
    if ([payload isKindOfClass:NSArray.class]) {
        NSMutableArray<NSString *> *parts = [NSMutableArray array];
        for (id value in payload) {
            NSString *part = [self transcriptFromPayload:value depth:depth + 1];
            if (part.length > 0) {
                [parts addObject:part];
            }
        }
        return [parts componentsJoinedByString:@" "];
    }
    if (![payload isKindOfClass:NSDictionary.class]) {
        return @"";
    }

    NSDictionary *dictionary = payload;
    for (NSString *key in @[@"text", @"transcript", @"displayText"]) {
        NSString *value = [self transcriptFromPayload:dictionary[key] depth:depth + 1];
        if (value.length > 0) {
            return value;
        }
    }

    NSArray *results = dictionary[@"results"];
    if ([results isKindOfClass:NSArray.class]) {
        NSMutableArray<NSString *> *parts = [NSMutableArray array];
        for (NSDictionary *result in results) {
            if (![result isKindOfClass:NSDictionary.class]) {
                continue;
            }
            NSArray *alternatives = result[@"alternatives"];
            NSDictionary *first = [alternatives isKindOfClass:NSArray.class] ? alternatives.firstObject : nil;
            NSString *part = [first isKindOfClass:NSDictionary.class] ? first[@"transcript"] : nil;
            if (part.length > 0) {
                [parts addObject:part];
            }
        }
        if (parts.count > 0) {
            return [parts componentsJoinedByString:@" "];
        }
    }

    for (NSString *key in @[@"voiceToText", @"response", @"data", @"result", @"message"]) {
        NSString *value = [self transcriptFromPayload:dictionary[key] depth:depth + 1];
        if (value.length > 0) {
            return value;
        }
    }
    return @"";
}

- (NSURL *)URLForPath:(NSString *)path {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", self.baseURL, path]];
}

+ (NSString *)normalizedBaseURL:(NSString *)baseURL {
    NSString *normalized = [baseURL stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    while ([normalized hasSuffix:@"/"]) {
        normalized = [normalized substringToIndex:normalized.length - 1];
    }
    return normalized;
}

- (NSError *)errorWithCode:(KMCoreVoiceAPIErrorCode)code description:(NSString *)description {
    return [NSError errorWithDomain:KMCoreVoiceAPIErrorDomain
                               code:code
                           userInfo:@{NSLocalizedDescriptionKey: description}];
}

@end
