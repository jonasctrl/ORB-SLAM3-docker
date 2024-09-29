import cv2
import zmq
import datetime
import time

TARGET_FPS = 20
FRAME_TIME = 1 / TARGET_FPS

context = zmq.Context()
socket = context.socket(zmq.PUB)
socket.bind("tcp://*:5555")

cap = cv2.VideoCapture(0)

while True:
    start_time = time.time()

    ret, frame = cap.read()
    if not ret:
        break

    _, jpeg_buffer = cv2.imencode('.jpg', frame)

    socket.send(jpeg_buffer.tobytes())

    print(datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S'))

    cv2.imshow('Camera Feed', frame)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

    processing_time = time.time() - start_time
    if processing_time < FRAME_TIME:
        time.sleep(FRAME_TIME - processing_time)

cap.release()
cv2.destroyAllWindows()

socket.close()
context.term()