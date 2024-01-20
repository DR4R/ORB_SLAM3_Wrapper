#include <iostream>
#include <chrono>
#include <opencv4/opencv2/opencv.hpp>
#include <thread>
#include "System.h"

using namespace cv;
using namespace std;

int main(int argc, char **argv) {
	VideoCapture cap;
    cap.open(0, cv::CAP_V4L);
    if (!cap.isOpened()) {
        cout << "Camera does not exists\n\n";
        exit(0);
    }
    double t_resize = 0.f;
    double fps = cap.get(CAP_PROP_FPS);
    std::chrono::steady_clock::time_point initT = std::chrono::steady_clock::now();
    ORB_SLAM3::System SLAM(argv[1], argv[2], ORB_SLAM3::System::MONOCULAR, true);
    
    try {
        while (1)
        {
                Mat frame;
                cap >> frame;
                if (frame.empty()) {
                    cout << "Frame is empty!\n";
                    continue;
                }
                std::chrono::steady_clock::time_point nowT = std::chrono::steady_clock::now();
                double timestamp = std::chrono::duration_cast<std::chrono::duration<double>>(nowT - initT).count();
                SLAM.TrackMonocular(frame, timestamp);
        }
    } catch(int e){
        cout << "User Interruption on SLAM System...\n\n";    
    }

    cout << "SLAM System ended.\n\n";
    cap.release();
    SLAM.Shutdown();
    return 0;
}