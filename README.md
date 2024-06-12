# AdHocLoudspeakerArray

We introduce an audio spatialization method based on an ad hoc loudspeaker array where the loudspeakers and audio sources can freely move along the horizontal plane in real-time.
The spatializer, based on the ``a room within a room'' method, defines a listening area bounded by the convex hull formed by the loudspeakers and an larger area where audio sources move. 
The loudspeaker array was developed as an iOS application. 
To precisely determine the locations of the loudspeakers, the application uses an iOS library for indoor positioning that employs Ultra-Wide Band. 
Peer-to-Peer communication was used to exchange audio and loudspeaker location information.
