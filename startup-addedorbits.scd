(
// configure the sound server: here you could add hardware specific options
// see http://doc.sccode.org/Classes/ServerOptions.html
s.quit;
s.options.device = "ASIO : JackRouter";
s.options.numBuffers = 1024 * 16; // increase this if you need to load more samples
s.options.memSize = 8192 * 16; // increase this if you get "alloc failed" messages
s.options.maxNodes = 1024 * 32; // increase this if you are getting drop outs and the message "too many nodes"
s.options.numOutputBusChannels = 14; // set this to your hardware output channel size, if necessary
s.options.numInputBusChannels = 2;  // set this to your hardware input channel size, if necessary
s.latency = 0.3;
// boot the server and start SuperDirt
~dirt.free; // free old instance
s.waitForBoot

{
	~dirt = SuperDirt(2, s); // two output channels, increase if you want to pan across more channels
	~dirt.loadSoundFiles;   // load samples (path containing a wildcard can be passed in)
	// for example: ~dirt.loadSoundFiles("/Users/myUserName/Dirt/samples/*");
	s.sync; // wait for samples to be read
	~dirt.start(57120, [0, 2, 4, 6, 8, 10, 12]);   // start listening on port 57120, create four orbits, each sending audio to channel 0. You can direct sounds to the orbits from tidal e.g. by: `# orbit "0 1 1"

	~dirt.orbits.do { |x|
	var event = x.defaultParentEvent;
	var pitchEvent = Event.partialEvents.pitchEvent.copy;
	var scale, tuning;
	pitchEvent.use {
		~freq = {
			if(~n != 0) { ~note = ~n }; // interpret n as note (might be also degree)
			~scaleName !? {
				scale = Scale.at(~scaleName);
				scale !? {
					~scale = scale;
					~tuningName !? {
						tuning = Tuning.at(~tuningName);
						tuning !? { ~scale = ~scale.copy; ~scale.tuning = tuning };
					}
				}
			};
			(~midinote.value + ~ctranspose).midicps * ~harmonic;
		};

		[\freq, \midinote, \octave].do(event.removeAt(_));

		event.parent = pitchEvent;
	}
};
}
)
// now you should be able to send from tidal via port 57120

// if we want to pick scales and tunings by name
// this works only when synths use \freq as argument

