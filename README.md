# Rolling Shutter
Compilation of rolling shutter camera sensor readout speed measurements for various cameras, plus the technique and tools used to generate it

## View Measurements
All sensor readout measurements can be [viewed here](https://horshack-dpreview.github.io/RollingShutter/).
 
## How Rolling Shutters work
Most modern cameras employ image sensors with a "rolling shutter". Unlike global shutters, which capture and read light in all pixels simultaneously, a rolling shutter staggers the capture of light across the vertical rows of the sensor. It does this because the readout electronics on the sensor aren't fast enough to read the pixel values for all rows at the same time. Pixel values are read off the sensor one row at a time, or sets of rows at a time on faster implementations.

While the sensor is busy reading pixel values from a given set of rows, the other rows that haven't been read yet are still accumulating light from the ongoing exposure. This can cause uneven exposures because rows in the middle and bottom of the sensor are allowed to receive more light before their pixel values are read vs rows near the top of the sensor which are read first. To avoid this scenario, the camera employs a rolling exposure (ie, "rolling shutter"), where it staggers the initial reset of the pixel rows at the start of an exposure, so that rows in the middle and bottom of the sensor are reset later (ie, have their exposure started later in time) than rows near the top of the sensor. The exact timing of this staggered reset is equal to the amount of time it takes to read a sensor row - that way each row is guaranteed to be exposed for the precise amount of time specified in the shutter speed you set for a given exposure.

For example, let's take a 24MP sensor with 6000 x 4000 pixels that has a full-sensor readout time of 50 milliseconds (1/20 of a second). That means it takes 50ms to complete reading all 4000 rows on the sensor. That translates to 12.5us (microseconds) per row, calculated as 50,000us / 4000. This means the first row on the sensor will be read approximately 50ms earlier than the last row. To avoid an uneven exposure where the last row receives 50ms (1/20) more light than than the first row, the camera will begin the exposure by staggering the reset of each row by exactly 12.5us, so that:

 - Row #1's pixel values are reset first
 - Row #2's pixel values are reset, 12.5us after row #1's reset
 - Row #3's pixel values are reset, 12.5us after row #2's reset (and 25.0us after row #1)
 - Row #4's pixel values are reset, 12.5us after row #3's reset (and 37.5us after row #1)
 - Row #4000's pixel values are reset, 12.5us after row #3999's reset (and 49,987.5us after row #1)

After these row resets have completed, the camera will then allow the sensor to remain exposed to light for whatever duration is specified by the shutter speed. After that duration is reached, the camera will begin the process of reading out the pixel values, one row at a time (or set of rows at a time). Let's say the shutter speed configured for the exposure is 1/20, equal to the full-sensor readout time of this theoretical sensor - this means the camera will read the pixel values from the first sensor row just as the last sensor row is completing its reset. Here's what that would look like:

 - Row #1's pixel values are read, taking 12.5us to complete
 - Row #2's pixel values are read, taking 12.5us to complete (cumulative reading time 25.0us)
 - Row #3's pixel values are read, taking 12.5us to complete (cumulative reading time 37.5us) 
 - Row #4's pixel values are read, taking 12.5us to complete (cumulative reading time 50.0us) 
 - Row #4000 pixel values are read, taking 12.5us to complete (cumulative reading time 50,000us)

What about exposures that take longer than 1/20, ie longer than the full-sensor readout time? In those scenarios the camera simply waits longer before it starts reading the rows after completing the row resets.

What about exposures that are shorter (faster) than the full-sensor readout time, ie > 1/20? In those scenarios the camera actually starts reading rows before it has completed resetting all rows, so that the camera is reading earlier rows at the same time it's still rolling through the progressive reset of later rows. For example, here's what 1/40 (25ms) exposure would look like:

 - Row #1's pixel values are reset first
 - Row #2's pixel values are reset, 12.5us after row #1's reset
 - Row #2000 pixel values are reset, 25ms after row #1's reset
 - Row #1's pixel values are read, since it has reached its 1/40 (25ms) exposure time
 - Row #2001 pixel values are reset, 25ms+12.5us after row #1's reset
 - Row #2's pixel values are read, since it has reached its 1/40 (25ms) exposure time
 - ...
 - Row #2000's pixel values are read, just as row #4000's pixel values are being reset
 - Row #2001's pixel values are read
 - Row #2002's pixel values are read
 - ...
 - Row #4000's pixel values are read, 50ms after the "start" of the exposure on row #1

The faster the shutter speed, the shorter the interval between the reset of a row and the read of that row. The only limit to the shutter speed is the time it takes to reset and read a given row. CMOS sensors can generally reset a row very quickly, effectively instantaneously - so it's the readout rate/per row that determines the maximum shutter speed. At 12.5us/row, this theoretical sensor could support a shutter speed approaching 1/80,000, or 1,000,000us / 12.5us.

The scenario of concurrently resetting and reading different rows at the same time creates a sliding virtual exposure "slit" or window across the sensor containing a select number of rows being exposed at any moment in time. Mechanical shutters work in the same manner but their slit created by the mechanical boundary between the 1st and 2nd physical curtains. For electronic shutters the reset of sensor rows is comparable to the 1st mechanical curtain starting closed then opening, with the read of the sensor rows comparable to the 2nd mechanical curtain closing.

As you can see, the interval between the reset of each row is always the same irrespective of the shutter speed and is fixed to the sensor readout time/per-row. The interval between reads of each row is also fixed and is also a function of the sensor readout time/per-row. Only the interval between when the rows are reset and later read is altered to achieve the full range of supported supported speeds.

## Rolling Shutter Issues
There is one major side effect of how rolling shutters work: while every row is exposed for the same amounts of time, they are not exposed for the same moments in time. On a sensor with a 50ms (1/20) readout rate, the last row is capturing a moment of time that's 50ms later than the first row, and that's true regardless of the shutter speed, even fast speeds like 1/8000. The shutter speed only guarantees the exposure time for each row - it makes no guarantee about the temporal relationship of exposures between rows. For many situations this isn't an issue because the scene you're capturing is mostly static, meaning it's either not moving or it's moving slowly relative to the framing/magnification, so the fact that elements in the scene might be in different positions 50ms apart in time is not noticeable in the resulting photograph.

But what about situations where a subject in the scene is moving quickly esp horizontally across the frame? Or situations where the camera is being panned during the exposure? In these scenarios the subject will be in a significantly different position in the frame at the end of the exposure vs the start, even after a short 50ms period of time. This will cause a skewing of the subject, where part of the subject is captured at one horizontal position in the frame for some rows and at a different horizontal position in the frame for rows read 50ms later. For vertically-oriented subjects like walls and light poles this will manifest as skewing, with the subject seeming to be leaning diagonally rather than standing straight up. For rotating subjects like [propellers](https://en.wikipedia.org/wiki/Rolling_shutter#/media/File:Propellor_with_rolling-shutter_artifact.jpg), [ceiling fans](https://photographylife.com/cdn-cgi/imagedelivery/GrQZt6ZFhE4jsKqjDEtqRA/photographylife.com/2019/07/Electronic-Shutter-Rolling-Shutter.jpg/w=650,h=433), and [golf clubs](https://www.digitec.ch/im/Files/7/5/4/5/9/2/9/3/globalshutter-8.jpg), this will manifest as warping of the moving elements. These effects are collectively referred to as rolling-shutter distortion.

Another situation where the time-shifted nature of rolling shutters can create noticeable image artifacts are photographs under artificial light. Although not visible to the human eye, most artificial light sources are constantly cycling between on and off illumination states, either as a consequence of the nature of [alternating current](https://en.wikipedia.org/wiki/Alternating_current) that powers them or because of the [circuit design](https://en.wikipedia.org/wiki/Pulse-width_modulation) within the light's electronics. Because rolling shutters capture different moments in time vertically across rows of the sensor, they can capture different states of these light cycles across those rows. This means the light source will be captured near its peak intensity on some sensor rows and at its lowest intensity (off) on other sensor rows. This manifests are light bands vertically across the frame:

<p align="center">
  <img src="https://photos.smugmug.com/photos/i-XMvVGGn/0/FHGCHjpTqWjkBSVwtmCh3zJR82M3NxW2VNMrbZJTh/O/i-XMvVGGn.png" />
</p>

The number of visible bands is a function of the cycling frequency of the light vs the full-sensor readout rate. The faster the light cycles and/or the slower the sensor readout, the greater the number of bands that will be visible in the full image. For example, a sensor with a full readout rate of 50ms (1/20) shooting a light source switching states 120 times/second (based on the North American AC rate of 60Hz),  the sensor will capture 6 noticeable bands of light. Here's the math:

 - 60Hz = 120 light transitions/second, where a transition is defined as an off -> on or an on->off state change of light. This is because Hz represents one full cycle of light, meaning off->on->off, so Hz*2 = number of transitions
 - The duration of each light state transition is 1000ms/120, or 8.33ms
 - The full-sensor readout is 50ms, which means it captures 50ms/8.33ms number of light transitions, which is 6, thus the photo will exhibit 6 visibly-distinguishable bands of light

Note that changing shutter speed only reduces the visibility of banding when it's slower than the cycling rate of the light and when the camera's exposure is temporally aligned with the phases of the light's cycles. In the above example, a shutter speed of 1/30 will start reducing the effects of banding, with slower shutters reducing it further. This is because the intensity of the captured light cycles start averaging out and becoming less noticeable.

Based on the above relationship between light cycle frequency and sensor readout time, we can calculate the other when one is known. For example, if we know the light source is 60Hz (120 transitions/second) and the sensor captures 6 bands, we can calculate the sensor readout time via 1000/120*6, which is 50ms. Alternatively, if we know the sensor readout time is 50ms, we can calculate the light's cycling frequency via 1000/(50/6)*2.

## Measuring Methodology
In 2018 a1ex at Magic Lantern took [Jim Kasson's original Z7 sensor readout method](https://blog.kasson.com/nikon-z6-7/how-fast-is-the-z7-silent-shutter/) and [applied it to measure various Canon bodies](https://www.magiclantern.fm/forum/index.php?topic=23040). For higher precision and easier reproducibility, a1ex cycled an LED on an Arduino board, whose frequency can be carefully controlled. He chose 500 Hz (1000 toggles/second). This frequency is convenient because it creates a simple 1ms per-transition relationship. This repository contains measurements on various cameras using a1ex's source code running on a [ELEGOO UNO R3 Board ATmega328](https://www.amazon.com/dp/B01EWOE0UU). Note that a "band" for this calculation is defined as a full cycle (Hz), meaning pairs of light/dark areas, each representing a transition of off->on->off. This is done because the duty cycle of the cycle may not be balanced 50% between on/off, due to alignment of the shutter speed relative to the phase of the light cycle.

## Measuring How-To Guide
### One-Time Setup

**Note: Photo measurements can only be performed on cameras that support an electronic shutter mode, ie not EFCS and not the mechanical shutter mode.**

 1. Purchase the  [ELEGOO UNO R3 Board ATmega328](https://www.amazon.com/dp/B01EWOE0UU) board. It currently sells for $16.99 on Amazon.
 2. Download and install the current version of the [Ardunio IDE](https://www.arduino.cc/en/software), answering yes to all driver installation prompts.
 3. Download the current source code to the Arduino LED toggling module in this repository by [right-clicking on this link](https://raw.githubusercontent.com/horshack-dpreview/RollingShutter/main/arduino/led_rolling_shutter.ino) and choosing "Save link as..." 
 4. Run the Arduino IDE. 
 5. Go to File -> Open and open the source code module downloaded in step #3. Answer Yes when prompted to move the file inside a sketch folder named the same as the module and asked if you'd like to create the file, and move the file.
 6. Attach the Arduino board to your computer via the included USB cable
 7. Click the "Select Board" dropdown at the top of the IDE and select the one item in the list corresponding to the board you've just attached
 8. Click the rightward-facing arrow at the top of the window to compile and flash the LED toggling module to your board. It should complete within 30 seconds. To verify the logic is running, go to Tools -> Serial Monitor and set the baud rate to 115,200. You should see a " Starting...500 Hz (1000 toggles/sec)" message, preceded by a timestamp. If not, cycle power on the board to restart it.
 9. Once the module has been flashed to the board you no longer need to attach the board to the computer for the logic to run - it will run automatically whenever power is supplied to the board, which you can do with any USB power supply.

### Test Setup
#### Selecting a Lens
 - A macro lens is ideal, since you will be photographing/video recording the small amber LED on the board, circled in red below:

<p align="center">
  <img src="https://photos.smugmug.com/photos/i-HKm3Qjw/0/jJh6BSPgQ9CHsbfQrhM8nH9R7MLCfCvzsSg9HPqg/L/i-HKm3Qjw-L.jpg" />
</p>

 - If you don't have a macro lens, choose a lens with either a large magnification factor or one with a long focal length
 - If you have a choice between an adapted vs native lens, choose an adapted lens. For example, a Canon lens on a Sony body using the Sigma MC-11 adapter in preference over a native Sony E-Mount lens. This will eliminate the need to strip off the embeddd lens correction profiles associated with native lenses.
 
 #### Camera Positioning and Framing
 
 - Tripod is ideal although not essential. Position the camera+lens as close as possible to the board, being careful not to scratch your front element on the pins protruding from the board. Center the framing around the illuminated amber light on the board (**not the green LED**). Ideally the full amber LED will be framed, without cutting off the top or bottom edges of the circular projection within the frame. But a partial framing is acceptable as well - just try to get the LED as large as possible within the frame. Here is an example of an ideally-framed LED:

<p align="center">
  <img src="https://photos.smugmug.com/photos/i-JPRhPN5/0/FNXkCcHg6xC6Hf4zZCSzx8Fh7mCbHZBfvN7jK5bFh/O/i-JPRhPN5.jpg" />
</p>


 ### Photo Tests
 #### Exposure

 - Chose a shutter speed of 1/2000, ISO of 12,800, and the largest aperture supported by the lens (smallest f-stop number)
 #### Initial Camera Settings
 - Set the camera to the fully-electronic shutter mode. Do not select the EFCS or mechanical shutter modes. Some cameras only offer the electronic shutter mode when using a special setting on the mode dial - for example, the Canon M50 requires you to use the "Creative" mode setting and silent mode to access the electronic shutter.
 - Turn off body and/or lens stabilization
 - Set the camera to raw-only capture
 - If the camera offers different raw compression options, choose the least-compressed option provided, which is uncompressed if available, otherwise lossless compression.
 - If the camera offers different raw bit depth options (ie, 14-bit vs 12-bit), choose the highest bit depth available, which would be 14-bit in this example
 - Set the shooting mode to single-shot (ie, not continuous shooting)
 - Set the Autofocus mode to Manual if possible, and set the focus position to infinity. Note this isn't essential.

 #### Measurement Photos

Photo #1 - Take a photo with the above settings.

Photo #2 - Take a photo with the above settings but with the camera set to JPEG-only instead of raw. Return the camera back to raw-only shooting after taking the photo.

Photo #3,4 - Take a photo with the above settings but with the ISO set to 1600, and again with the ISO set to the maximum value. Return the ISO back to 12,800 after taking the photo. This is done for cameras that use different sensor readout rates  based on the ISO.

Photo #5 - Switch the camera from single-shot to the fasted continuous shooting speed/mode offered and take another photo. If you accidentally take more than one photo for the continuous burst you can delete the extra photos. Switch the camera back to single-shot mode

Photo #6 (optionally) - If the camera offers different raw bit depth options, choose the alternate option and take another photo. For example, if both 14-bit and 12-bit options are available, the first photo is taken with 14-bit selected and the second with 12-bit. Return the camera back to the highest bit depth option when done.

Photo #7 (optionally) - If the camera offers different raw compression options, choose the alternate option(s) and take another photo. For example, if the camera offers both uncompressed and lossless compressed, choose lossless for the second exposure.

 ### Video Tests
 #### Exposure

 - Chose a shutter speed of 1/2000, ISO of 12,800, and the largest aperture supported by the lens (smallest f-stop number)
 
 #### Initial Camera Settings
   - Turn off body and/or lens stabilization
   - Set the Autofocus mode to Manual if possible, and set the focus position to infinity. Make sure any video-specific continuous AF setting is off.
   - Set the highest quality video mode offered, first by resolution, then frame rate, then bit depth/color sampling. For example, choose 4K over 1080, 60p over 30p, 10-bit over 8-bit, 422 over 420, etc...

 #### Measurement Videos
 
 Video Set #1, Video #1 - Press you camera's video record button to start recording, then immediately press it again to record the shortest video you can (to keep the file sizes manageable). Choose the next offered frame rate for the current resolution. For example, if you started with 4K 60p, choose 4K 30p, and record another video. Continue to the next frame rate until reaching the lowest non-S&Q rate offered, which is typically either 30p or 24p

Video Set #2 - Chose the next lower resolution offered in the camera. For example, if you started with 4K then choose 1080. Choose the highest frame rate offered for the lower resolution. For 1080 that's usually either 120p or 60p. Record a video. Choose the next offered frame rate for the current resolution, until reaching the lowest non-S&Q rate offered, which is typically either 30p or 24p

Continue through additional video sets if your camera offers more than 2 shooting resolution. For example, some cameras offer 8K, 4K, and 1080, which will produce three sets of videos.

 #### Extra Credit
 If possible, shoot a few sample videos at varying bit-depths (8-bit vs 10-bit) and chroma sampling rates (420 vs 422). You don't have to repeat the full matrix of sets above - one sample video at the varied bit depth and chroma sampling rate is sufficient.
