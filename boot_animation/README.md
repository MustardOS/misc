## Boot Animation/Sound/Rumble
This modification allows you to have a boot animation, chime, and rumble. Unfortunately there is a delay between the boot logo and starting this modification. However I am looking for ways to deal with that.

---

### Installation
* Copy the `boot_animation` folder to the same drive as the `dtbs` and `modules` folders on your SD Card.
* Open the `dmenu.bin` file in your favourite text editor and add the following line **AFTER** _(I DO MEAN **AFTER**)_ the `#!/system/bin/sh` line.

```
/misc/boot_animation/start.sh [theme_name]
```

##### IMPORTANT
Replace `[theme_name]` with the name of the theme including the brackets! Here is an example of what it would look like.

```
/misc/boot_animation/start.sh sega
```

Save the `dmenu.bin` file and you're good to go. Fingers crossed you followed this properly and won't hit any issues other than bad animations and bad sounds. Experiment and have fun with it!

### Removal
* Remove the `boot_animation` folder from the drive mentioned above
* Remove the line you added to the `dmenu.bin` file.

---

### Boot Animation
* You’ll need the handy online tool, https://ezgif.com/resize
* Upload the image you want.
* The resize settings should be the following:
```
WIDTH           640
HEIGHT          480
RESIZE METHOD   ImageMagick + Coalesce
ASPECT RATIO	Center and Crop to fit
```
* Save the new `GIF` to your local computer and change the name to something nice.
* Now you'll want to split the animation into individual `PNG` files.
* Use ffmpeg online, https://ffmpeg-online.vercel.app/
* Upload the `GIF` you created earlier.
* Change `output.mp4` to `%d.png`.
* Click the blue Run button.
* Once converted (should be fairly quick) click on the download button.
* Create a new folder inside the `theme` folder with the name of your animation.
* Extract all of the files within the archive to the new folder.

### PNG Optimisation
* You might want to consider using one of the below programs
* They will decrease the file size of PNGs without lowering quality.
 * **WINDOWS** https://css-ig.net/pinga
 * **MACOS** https://imageoptim.com/mac
 * **LINUX** You got this. (If not try, https://trimage.org/)

### Boot Sound
* Download audio by whatever means.
* Use your favourite audio editor, mine is Audacity.
* Edit, chop, mix, do whatever you like to make it sound great.
* The audio settings should be the following:
```
FREQUENCY   48000Hz (48kHz)
BIT DEPTH   32 BIT  (PCM)
CHANNEL     STEREO  (2 Channel)
```
* Export it as `chime.mp3` file and save it to your animation folder from above.

### Rumble Animation
* Using your favourite text editor open the `example_rumble.txt` file.
* Inside the file are lines that look like this: `20 0.25 0`.
* The first set of numbers (`20`) is the **strength** of the vibration motor
  * Please note that anything under 20 is pretty weak.
  * Try keep them in lots of 10s between 20 and 100.
* The second set of numbers (`0.25`) is how long the vibration motor should stay on.
* The third set of numbers (`0`) is how long it should wait before moving to the next line.
* There is no _real_ limit to the number of lines but try and make it match your image animation.
* Save the file as `rumble.txt` into your animation folder from above.

### Configuration File
* Using your favourite text editor open the `example_config.txt` file.
* Modify the variables to suit the theme you're creating.
* Save the file as `config.txt` into your animation folder from above.

### Packaging For Sharing
* Open up 7-Zip and archive all of the FILES (not the animation folder) you created above.
* Save it as a .7z with high compression, makes it easier to transfer.
* Share the archive out to whomever wants it.

### Extracting Themes
* Extract the theme you have acquired into its own folder within the theme folder.
