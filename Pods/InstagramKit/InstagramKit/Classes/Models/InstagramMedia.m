//
//    Copyright (c) 2015 Shyam Bhat
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy of
//    this software and associated documentation files (the "Software"), to deal in
//    the Software without restriction, including without limitation the rights to
//    use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//    the Software, and to permit persons to whom the Software is furnished to do so,
//    subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//    FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//    COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "InstagramMedia.h"
#import "InstagramUser.h"
#import "InstagramComment.h"
#import "UserInPhoto.h"
#import "InstagramLocation.h"

#if !TARGET_OS_IPHONE
#define decodeCGSizeForKey decodeSizeForKey
#define encodeCGSize encodeSize
#endif

@interface InstagramMedia ()

@property (nonatomic, strong) InstagramUser *user;
@property (nonatomic, assign) BOOL userHasLiked;
@property (nonatomic, strong) NSDate *createdDate;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, strong) InstagramComment *caption;
@property (nonatomic, strong) NSArray *likes;
@property (nonatomic, assign) NSInteger likesCount;
@property (nonatomic, strong) NSArray *comments;
@property (nonatomic, assign) NSInteger commentsCount;
@property (nonatomic, strong) NSArray *usersInPhoto;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, assign) CLLocationCoordinate2D location;
@property (nonatomic, copy) NSString *locationId;
@property (nonatomic, copy) NSString *locationName;
@property (nonatomic, copy) NSString *filter;
@property (nonatomic, strong) NSURL *thumbnailURL;
@property (nonatomic, assign) CGSize thumbnailFrameSize;
@property (nonatomic, strong) NSURL *lowResolutionImageURL;
@property (nonatomic, assign) CGSize lowResolutionImageFrameSize;
@property (nonatomic, strong) NSURL *standardResolutionImageURL;
@property (nonatomic, assign) CGSize standardResolutionImageFrameSize;
@property (nonatomic, assign) BOOL isVideo;
@property (nonatomic, strong) NSURL *lowResolutionVideoURL;
@property (nonatomic, assign) CGSize lowResolutionVideoFrameSize;
@property (nonatomic, strong) NSURL *standardResolutionVideoURL;
@property (nonatomic, assign) CGSize standardResolutionVideoFrameSize;

@end

@implementation InstagramMedia

- (instancetype)initWithInfo:(NSDictionary *)info
{
    self = [super initWithInfo:info];
    if (self && IKNotNull(info)) {
        
        self.user = IKNotNull(info[kUser]) ? [[InstagramUser alloc] initWithInfo:info[kUser]] : nil;
        self.userHasLiked = [info[kUserHasLiked] boolValue];
        self.createdDate = IKNotNull(info[kCreatedDate]) ? [[NSDate alloc] initWithTimeIntervalSince1970:[info[kCreatedDate] doubleValue]] : nil;
        self.link = IKNotNull(info[kLink]) ? [[NSString alloc] initWithString:info[kLink]] : nil;
        self.caption = IKNotNull(info[kCaption]) ? [[InstagramComment alloc] initWithInfo:info[kCaption]] : nil;
        
        NSDictionary *likesDictionary = info[kLikes];
        if ([likesDictionary isKindOfClass:[NSDictionary class]]) {
            NSMutableArray *mLikes = [[NSMutableArray alloc] init];
            for (NSDictionary *userInfo in likesDictionary[kData]) {
                InstagramUser *user = [[InstagramUser alloc] initWithInfo:userInfo];
                [mLikes addObject:user];
            }
            self.likes = [NSArray arrayWithArray:mLikes];
            NSNumber *likesCount = likesDictionary[kCount];
            self.likesCount = likesCount.integerValue;
        }
        
        NSDictionary *commentsDictionary = info[kComments];
        if ([commentsDictionary isKindOfClass:[NSDictionary class]]) {
            NSMutableArray *mComments = [[NSMutableArray alloc] init];
            for (NSDictionary *commentInfo in commentsDictionary[kData]) {
                InstagramComment *comment = [[InstagramComment alloc] initWithInfo:commentInfo];
                [mComments addObject:comment];
            }
            self.comments = [NSArray arrayWithArray:mComments];
            NSNumber *commentsCount = commentsDictionary[kCount];
            self.commentsCount = commentsCount.integerValue;
        }
        
        NSMutableArray *mUsersInPhoto = [[NSMutableArray alloc] init];
        for (NSDictionary *userInfo in info[kUsersInPhoto]) {
            UserInPhoto *userInPhoto = [[UserInPhoto alloc] initWithInfo:userInfo];
            [mUsersInPhoto addObject:userInPhoto];
        }
        self.usersInPhoto = mUsersInPhoto;

        self.tags = IKNotNull(info[kTags]) ? [[NSArray alloc] initWithArray:info[kTags]] : nil;
        
        if (IKNotNull(info[kLocation])) {
            id locationId = IKNotNull(info[kLocation][kID]) ? info[kLocation][kID] : nil;
            self.locationId = ([locationId isKindOfClass:[NSString class]]) ? locationId : [locationId stringValue];
            self.locationName = IKNotNull(info[kLocation][kLocationName]) ? info[kLocation][kLocationName] : nil;
            self.location = CLLocationCoordinate2DMake([(info[kLocation])[kLocationLatitude] doubleValue], [(info[kLocation])[kLocationLongitude] doubleValue]);
        }
        
        self.filter = IKNotNull(info[kFilter]) ? info[kFilter] : nil;
        
        [self initializeImages:info[kImages]];
        
        NSString *mediaType = info[kType];
        self.isVideo = [mediaType isEqualToString:[NSString stringWithFormat:@"%@",kMediaTypeVideo]];
        if (self.isVideo) {
            [self initializeVideos:info[kVideos]];
        }
    }
    return self;
}

- (void)initializeImages:(NSDictionary *)imagesInfo
{
    NSDictionary *thumbInfo = imagesInfo[kThumbnail];
    self.thumbnailURL = IKNotNull(thumbInfo[kURL]) ? [[NSURL alloc] initWithString:thumbInfo[kURL]] : nil;
    self.thumbnailFrameSize = CGSizeMake([thumbInfo[kWidth] floatValue], [thumbInfo[kHeight] floatValue]);
    
    NSDictionary *lowResInfo = imagesInfo[kLowResolution];
    self.lowResolutionImageURL = IKNotNull(lowResInfo[kURL]) ? [[NSURL alloc] initWithString:lowResInfo[kURL]] : nil;
    self.lowResolutionImageFrameSize = CGSizeMake([lowResInfo[kWidth] floatValue], [lowResInfo[kHeight] floatValue]);
    
    NSDictionary *standardResInfo = imagesInfo[kStandardResolution];
    self.standardResolutionImageURL = IKNotNull(standardResInfo[kURL])? [[NSURL alloc] initWithString:standardResInfo[kURL]] : nil;
    self.standardResolutionImageFrameSize = CGSizeMake([standardResInfo[kWidth] floatValue], [standardResInfo[kHeight] floatValue]);
}

- (void)initializeVideos:(NSDictionary *)videosInfo
{
    NSDictionary *lowResInfo = videosInfo[kLowResolution];
    self.lowResolutionVideoURL = IKNotNull(lowResInfo[kURL]) ? [[NSURL alloc] initWithString:lowResInfo[kURL]] : nil;
    self.lowResolutionVideoFrameSize = CGSizeMake([lowResInfo[kWidth] floatValue], [lowResInfo[kHeight] floatValue]);
    
    NSDictionary *standardResInfo = videosInfo[kStandardResolution];
    self.standardResolutionVideoURL = IKNotNull(standardResInfo[kURL])? [[NSURL alloc] initWithString:standardResInfo[kURL]] : nil;
    self.standardResolutionVideoFrameSize = CGSizeMake([standardResInfo[kWidth] floatValue], [standardResInfo[kHeight] floatValue]);
}

#pragma mark - Equality

- (BOOL)isEqualToMedia:(InstagramMedia *)media {
    return [super isEqualToModel:media];
}

#pragma mark - NSCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super initWithCoder:decoder])) {
        self.user = [decoder decodeObjectOfClass:[InstagramUser class] forKey:kUser];
        self.userHasLiked = [decoder decodeBoolForKey:kUserHasLiked];
        self.createdDate = [decoder decodeObjectOfClass:[NSDate class] forKey:kCreatedDate];
        self.link = [decoder decodeObjectOfClass:[NSString class] forKey:kLink];
        self.caption = [decoder decodeObjectOfClass:[NSString class] forKey:kCaption];
        self.likes = [decoder decodeObjectOfClass:[NSArray class] forKey:kLikes];
        self.comments = [decoder decodeObjectOfClass:[NSArray class] forKey:kComments];
        self.usersInPhoto = [decoder decodeObjectOfClass:[NSArray class] forKey:kUsersInPhoto];
        self.tags = [decoder decodeObjectOfClass:[NSArray class] forKey:kTags];
        self.likesCount = [decoder decodeIntegerForKey:kLikesCount];
        
        CLLocationCoordinate2D coordinates;
        coordinates.latitude = [decoder decodeDoubleForKey:kLocationLatitude];
        coordinates.longitude = [decoder decodeDoubleForKey:kLocationLongitude];
        self.location = coordinates;
        self.locationName = [decoder decodeObjectOfClass:[NSString class] forKey:kLocationName];
        
        self.filter = [decoder decodeObjectOfClass:[NSString class] forKey:kFilter];
        
        self.thumbnailURL = [decoder decodeObjectOfClass:[NSString class] forKey:[NSString stringWithFormat:@"%@url",kThumbnail]];
        self.thumbnailFrameSize = [decoder decodeCGSizeForKey:[NSString stringWithFormat:@"%@size",kThumbnail]];
        
        self.isVideo = [decoder decodeBoolForKey:kMediaTypeVideo];
        
        if (!self.isVideo) {
            self.lowResolutionImageURL = [decoder decodeObjectOfClass:[NSString class] forKey:[NSString stringWithFormat:@"%@url",kLowResolution]];
            self.lowResolutionImageFrameSize = [decoder decodeCGSizeForKey:[NSString stringWithFormat:@"%@size",kLowResolution]];
            self.standardResolutionImageURL = [decoder decodeObjectOfClass:[NSString class] forKey:[NSString stringWithFormat:@"%@url",kStandardResolution]];
            self.standardResolutionImageFrameSize = [decoder decodeCGSizeForKey:[NSString stringWithFormat:@"%@size",kStandardResolution]];
        }
        else
        {
            self.lowResolutionVideoURL = [decoder decodeObjectOfClass:[NSString class] forKey:[NSString stringWithFormat:@"%@url",kLowResolution]];
            self.lowResolutionVideoFrameSize = [decoder decodeCGSizeForKey:[NSString stringWithFormat:@"%@size",kLowResolution]];
            self.standardResolutionVideoURL = [decoder decodeObjectOfClass:[NSString class] forKey:[NSString stringWithFormat:@"%@url",kStandardResolution]];
            self.standardResolutionVideoFrameSize = [decoder decodeCGSizeForKey:[NSString stringWithFormat:@"%@size",kStandardResolution]];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];

    [encoder encodeObject:self.user forKey:kUser];
    [encoder encodeBool:self.userHasLiked forKey:kUserHasLiked];
    [encoder encodeObject:self.createdDate forKey:kCreatedDate];
    [encoder encodeObject:self.link forKey:kLink];
    [encoder encodeObject:self.caption forKey:kCaption];
    [encoder encodeObject:self.likes forKey:kLikes];
    [encoder encodeObject:self.comments forKey:kComments];
    [encoder encodeObject:self.usersInPhoto forKey:kUsersInPhoto];
    [encoder encodeObject:self.tags forKey:kTags];
    [encoder encodeDouble:self.location.latitude forKey:kLocationLatitude];
    [encoder encodeDouble:self.location.longitude forKey:kLocationLongitude];
    [encoder encodeObject:self.locationName forKey:kLocationName];
    [encoder encodeObject:self.filter forKey:kFilter];
    [encoder encodeObject:self.thumbnailURL forKey:[NSString stringWithFormat:@"%@url",kThumbnail]];
    [encoder encodeCGSize:self.thumbnailFrameSize forKey:[NSString stringWithFormat:@"%@size",kThumbnail]];
    [encoder encodeBool:self.isVideo forKey:kMediaTypeVideo];
    [encoder encodeInteger:self.likesCount forKey:kLikesCount];

    if (!self.isVideo) {
        [encoder encodeObject:self.lowResolutionImageURL forKey:[NSString stringWithFormat:@"%@url",kLowResolution]];
        [encoder encodeCGSize:self.lowResolutionImageFrameSize forKey:[NSString stringWithFormat:@"%@size",kLowResolution]];
        [encoder encodeObject:self.standardResolutionImageURL forKey:[NSString stringWithFormat:@"%@url",kStandardResolution]];
        [encoder encodeCGSize:self.standardResolutionImageFrameSize forKey:[NSString stringWithFormat:@"%@size",kStandardResolution]];
    }
    else
    {
        [encoder encodeObject:self.lowResolutionVideoURL forKey:[NSString stringWithFormat:@"%@url",kLowResolution]];
        [encoder encodeCGSize:self.lowResolutionVideoFrameSize forKey:[NSString stringWithFormat:@"%@size",kLowResolution]];
        [encoder encodeObject:self.standardResolutionVideoURL forKey:[NSString stringWithFormat:@"%@url",kStandardResolution]];
        [encoder encodeCGSize:self.standardResolutionVideoFrameSize forKey:[NSString stringWithFormat:@"%@size",kStandardResolution]];
    }

}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    InstagramMedia *copy = [super copyWithZone:zone];
    copy->_user = [self.user copy];
    copy->_userHasLiked = self.userHasLiked;
    copy->_createdDate = [self.createdDate copy];
    copy->_link = [self.link copy];
    copy->_caption = [self.caption copy];
    copy->_likes = [self.likes copy];
    copy->_comments = [self.comments copy];
    copy->_usersInPhoto = [self.usersInPhoto copy];
    copy->_tags = [self.tags copy];
    copy->_location = self.location;
    copy->_locationName = [self.locationName copy];
    copy->_filter = [self.filter copy];
    copy->_thumbnailURL = [self.thumbnailURL copy];
    copy->_thumbnailFrameSize = self.thumbnailFrameSize;
    copy->_isVideo = self.isVideo;
    copy->_lowResolutionImageURL = [self.lowResolutionImageURL copy];
    copy->_lowResolutionImageFrameSize = self.lowResolutionImageFrameSize;
    copy->_standardResolutionImageURL = [self.standardResolutionImageURL copy];
    copy->_standardResolutionImageFrameSize = self.standardResolutionImageFrameSize;
    copy->_lowResolutionVideoURL = [self.lowResolutionVideoURL copy];
    copy->_lowResolutionVideoFrameSize = self.lowResolutionVideoFrameSize;
    copy->_standardResolutionVideoURL = [self.standardResolutionVideoURL copy];
    copy->_standardResolutionVideoFrameSize = self.standardResolutionVideoFrameSize;
    return copy;
}


@end
