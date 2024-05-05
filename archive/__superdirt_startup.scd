(

s.reboot {

	s.waitForBoot {
		~dirt = SuperDirt(2, s);
		~dirt.loadSoundFiles("/home/oscarsouth/dirt_samples/none");
		s.sync;
		~dirt.start(57120, [2]);
		MIDIClient.init;
		MIDIClient.destinations;
		// ~midiDIN = MIDIOut.newByName("iConnectAUDIO4+", "iConnectAUDIO4+ DIN");
		// ~midiDIN = MIDIOut.newByName("SuperCollider", "out0");
		// ~midiDIN = MIDIOut.newByName("M4", "M4 MIDI 1");
		~midiDIN = MIDIOut.newByName("PreSonus AudioBox iTwo", "PreSonus AudioBox iTwo MIDI 1");
		~dirt.soundLibrary.addMIDI(\din, ~midiDIN);
	};


};
);
