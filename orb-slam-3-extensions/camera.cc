
#include <iostream>
#include <chrono>
#include <opencv2/core/core.hpp>
#include <opencv2/imgcodecs.hpp>
#include <System.h>
#include <zmq.hpp>
#include <vector>

void ProcessImage(ORB_SLAM3::System& SLAM, const cv::Mat& im, const double& tframe)
{
    cv::Mat im_copy = im.clone();
    SLAM.TrackMonocular(im_copy, tframe);
}

int main(int argc, char **argv)
{
    if(argc != 4)
    {
        std::cerr << "Usage: " << argv[0] << " <path_to_vocabulary> <path_to_settings> <zmq_address>" << std::endl;
        return 1;
    }

    const char* vocabulary_path = argv[1];
    const char* settings_path = argv[2];
    const char* zmq_address = argv[3];

    ORB_SLAM3::System SLAM(vocabulary_path, settings_path, ORB_SLAM3::System::MONOCULAR, true);

    zmq::context_t context(1);
    zmq::socket_t subscriber(context, ZMQ_SUB);

    try {
        subscriber.connect(zmq_address);
        subscriber.set(zmq::sockopt::subscribe, "");
        std::cout << "Connected to image stream at " << zmq_address << ". Waiting for images..." << std::endl;
    } catch (zmq::error_t& e) {
        std::cerr << "Failed to connect to ZMQ server: " << e.what() << std::endl;
        return 1;
    }

    while (true)
    {
        zmq::message_t message;
        zmq::recv_result_t result = subscriber.recv(message, zmq::recv_flags::none);
        if (!result) {
            std::cerr << "Failed to receive message" << std::endl;
            continue;
        }

        std::vector<uchar> jpeg_data(static_cast<unsigned char*>(message.data()),
                                     static_cast<unsigned char*>(message.data()) + message.size());
        cv::Mat img = cv::imdecode(jpeg_data, cv::IMREAD_COLOR);

        if (img.empty())
        {
            std::cerr << "Failed to decode image" << std::endl;
            continue;
        }

        std::chrono::steady_clock::time_point t = std::chrono::steady_clock::now();
        double tframe = std::chrono::duration_cast<std::chrono::duration<double>>(t.time_since_epoch()).count();

        ProcessImage(SLAM, img, tframe);
    }

    // Stop all threads
    SLAM.Shutdown();
    SLAM.SaveKeyFrameTrajectoryTUM("KeyFrameTrajectory.txt");

    return 0;
}
