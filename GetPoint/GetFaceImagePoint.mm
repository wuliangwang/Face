//
//  GetFaceImagePoint.m
//  face_demo
//
//  Created by 胖虎 on 2018/4/25.
//  Copyright © 2018年 胖虎. All rights reserved.
//

#include <opencv2/core/core.hpp>
#include <opencv2/face.hpp>
#import <opencv2/imgcodecs/ios.h>
#include "stasm_lib.h"
#import "GetFaceImagePoint.h"

//using namespace cv; 省去前缀
//using namespace std; 省去前缀

@implementation GetFaceImagePoint
+ (UIImage *)getFaceImagePointWithFace:(UIImage *)image{
    
    // 参数1
    int foundface;
    
    /*
     * 参数2
     * stasm_NLANDMARKS 是 stasm的一个宏 一个int值 值为77 表示可以获取到77个点
     * 乘以2 是因为返回的值是float 每一个点都有x,y 返回值为:x0, y0, x1, y1, 相当于两个元素才能合成一个点
     */
    float landmarks[2 * stasm_NLANDMARKS];
    
    /*
     * 参数3
     * 图片的灰度图, 可以直接使用OpenCV的方法获取
     */
    
    // 将UIImage 转成 cv::Mat
    cv::Mat cvFaceImage;
    UIImageToMat(image, cvFaceImage);
    
    // 将cv::Mat的image 转成灰度图
    // CV_RGBA2GRAY 表示 将四通道RGBA的图片 转成灰度图 iOS中图片默认是RGBA的
    cv::Mat cvGrayFaceImage;
    cv::cvtColor(cvFaceImage, cvGrayFaceImage,CV_RGBA2GRAY);
    const char* imgData = (const char*)cvGrayFaceImage.data;
    
    //参数4/5 图片的宽高 cv::Mat 的图片可以直接取
    int imgCols = cvGrayFaceImage.cols;
    int imgRows = cvGrayFaceImage.rows;
    
    // 参数6 不传
    
    /*
     * 参数7 训练库文件的目录
     * 这里需要注意 iOS获取项目中文件 需要通过Bundle获取
     * [NSBundle mainBundle].bundlePath 作为目录 是可以拿到项目中所以文件的 不管有没有其他子文件夹了。
     * 其他平台中, 那么就指定路径
     */
    const char *xmlPath = [[NSBundle mainBundle].bundlePath UTF8String];
    
    
    // 方法有返回值 如果为0 那么就说明方法调用出现问题
    int stasmActionError = stasm_search_single(&foundface, landmarks,imgData, imgCols, imgRows, "", xmlPath);
    if (!stasmActionError){
        //  通过打印 stasm_lasterr() 可以看到错误信息
        printf("Error in stasm_search_single: %s\n", stasm_lasterr());
    }
    UIImage *result;
    
    if (!foundface) {
        printf("No face found");
        result = image;
    }else{
        // 这里就说明已经获取到关键点了
        // 将关键点显示出来
        
        // 将RGBA四通道的图片 转成 BGR三通道
        cv::Mat cvFaceImage_BGR;
        cv::cvtColor(cvFaceImage, cvFaceImage_BGR, CV_RGBA2BGR);
        
        for (int i = 0; i < stasm_NLANDMARKS; i++){
            // 生成一个当前点脚标的String字符串
            std::string number = std::to_string(i);
            // 获取中心点 根据x在前 y在后 两个元素为一个点的顺序
            cv::Point center(cvRound(landmarks[i * 2 ]), cvRound(landmarks[i * 2+1]));
            // 将点画上去
            cv::circle(cvFaceImage_BGR, center, 0.25, cv::Scalar(255, 0, 0), 2, 8, 0);
            // 将脚标也画上去
            cv::putText(cvFaceImage_BGR,number,center, cv::FONT_HERSHEY_PLAIN,0.7, cv::Scalar(0, 0, 255));
        }
        
        
        // 将BGR三通道的图片 转成 RGBA四通道
        cv::Mat cvFaceImageResult;
        cv::cvtColor(cvFaceImage_BGR, cvFaceImageResult, CV_BGR2RGBA);
        
        //绘制出关键点的image
        result = MatToUIImage(cvFaceImageResult);
        
        cvFaceImage_BGR.release();
        cvFaceImageResult.release();
    }
    
    // 释放cv::Mat
    cvFaceImage.release();
    cvGrayFaceImage.release();
    
    return result;
    
}
@end
