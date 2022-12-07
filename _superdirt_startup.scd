(

s.reboot {

	// s.options.device = "PreSonus AudioBox iTwo";
	s.options.device = "M4";
	// s.options.device = "PCH";
	s.options.numOutputBusChannels = 4;
	s.options.numInputBusChannels = 4;
	// s.options.memSize = 1024*500;
	s.options.numBuffers = 1024 * 256;
	s.options.memSize = 8192 * 16;
	s.options.numWireBufs = 65;
	s.options.maxNodes = 1024 * 32;

	s.waitForBoot {
		~dirt = SuperDirt(2, s);
		~dirt.loadSoundFiles("/home/oscarsouth/dirt_samples/none");
		s.sync;
		~dirt.start(57120, [2]);
		~latency = 0.0;
		MIDIClient.init;
		MIDIClient.destinations;
		// ~midiDIN = MIDIOut.newByName("iConnectAUDIO4+", "iConnectAUDIO4+ DIN");
		// ~midiDIN = MIDIOut.newByName("SuperCollider", "out0");
		~midiDIN = MIDIOut.newByName("M4", "M4 MIDI 1");
		// ~midiDIN = MIDIOut.newByName("PreSonus AudioBox iTwo", "PreSonus AudioBox iTwo MIDI 1");
		~midiDIN.latency = ~latency;
		~dirt.soundLibrary.addMIDI(\din, ~midiDIN);
	};

	s.latency = 0.0;

};
);
