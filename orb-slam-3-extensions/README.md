# ORB-SLAM3 Extensions

### Step 1: Additional Packages

You may also need to install the `libzmq3-dev` package for certain functionalities:

```bash
sudo apt-get install libzmq3-dev
```

### Step 2: Add dependencies to CMakeLists.txt

There is additional file include that was used in the camera example. You should replace the `CMakeLists.txt` file with the one provided in this repository. It will include the necessary dependencies for the camera example.

### Step 3: Running the Camera Example

If you want to test real-time camera input with ORB-SLAM3, run the following command:

```bash
./Examples/Monocular/camera ./Vocabulary/ORBvoc.txt \
  ./Examples/Stereo/EuRoC.yaml \
  tcp://host.docker.internal:5555
```

Make sure that the correct IP and port are specified for the camera feed.
