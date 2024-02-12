async function captureImagePromise(callBack) {

    const video = document.querySelector('video');

    const canvas = document.createElement('canvas');
    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;
    const context = canvas.getContext('2d');
    context.drawImage(video, 0, 0, canvas.width, canvas.height);
    const data= canvas.toDataURL('image/jpeg'); // Returns a data URL containing a representation of the image
    callBack(data)
    return data;
  }
  