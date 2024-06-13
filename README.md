# AdHocLoudspeakerArray

We introduce an audio spatialization method based on an ad hoc loudspeaker array where the loudspeakers and audio sources can freely move along the horizontal plane in real-time.
The spatializer, based on the ``a room within a room'' method, defines a listening area bounded by the convex hull formed by the loudspeakers and an larger area where audio sources move. 
The loudspeaker array was developed as an iOS application. 
To precisely determine the locations of the loudspeakers, the application uses an iOS library for indoor positioning that employs Ultra-Wide Band. 
Peer-to-Peer communication was used to exchange audio and loudspeaker location information.

## How to use

### Audio operator

Audio operator can manipulate the location and transmission of sound.

Press the Start button to start P2P communication.
Press NISession if all loudspeaker screens display "Connected!!".
Location information is shared with the loudspeaker.

Press the Audio button to share audio.
User can move the position of the virtual source with the orange ball.

<img src="https://github.com/K-Fujita-onkyo/AdHocLoudspeakerArray/assets/103561176/e5e87211-8b55-46bb-830e-04f341225c89" alt="Audio operator" width="200">

### Loudspeaker

The Loudspeaker spatializes the supplied sound and outputs it.
Browse to initiate P2P communication.
The rest can move freely or remain stationary.

<img src="https://github.com/K-Fujita-onkyo/AdHocLoudspeakerArray/assets/103561176/22611140-6026-4e78-b142-224d3669c021" alt="Audio operator" width="200">

## Demo
https://youtu.be/zXuylUYh22Y
