:set -XOverloadedStrings
:set -XFlexibleContexts
-- :set -XAllowAmbiguousTypes
:set prompt ""
:set prompt-cont ""
import Sound.Tidal.Context
-- total latency = oLatency + cFrameTimespan
tidal <- startTidal (superdirtTarget {oLatency = 0.4, oAddress = "127.0.0.1", oPort = 57120}) (defaultConfig {cFrameTimespan = 1/10})
-- tidal <- startTidal (superdirtTarget {oLatency = 0.1, oAddress = "127.0.0.1", oPort = 57120}) (defaultConfig {cFrameTimespan = 1/20})
:{
let p = streamReplace tidal
    hush' = streamHush tidal
    list = streamList tidal
    mute = streamMute tidal
    unmute = streamUnmute tidal
    solo = streamSolo tidal
    unsolo = streamUnsolo tidal
    once = streamOnce tidal
    asap = once
    nudgeAll = streamNudgeAll tidal
    all = streamAll tidal
    resetCycles = streamResetCycles tidal
    setcps = asap . cps
    xfade i = transition tidal True (Sound.Tidal.Transition.xfadeIn 4) i
    xfadeIn i t = transition tidal True (Sound.Tidal.Transition.xfadeIn t) i
    histpan i t = transition tidal True (Sound.Tidal.Transition.histpan t) i
    wait i t = transition tidal True (Sound.Tidal.Transition.wait t) i
    waitT i f t = transition tidal True (Sound.Tidal.Transition.waitT f t) i
    jump i = transition tidal True (Sound.Tidal.Transition.jump) i
    jumpIn i t = transition tidal True (Sound.Tidal.Transition.jumpIn t) i
    jumpIn' i t = transition tidal True (Sound.Tidal.Transition.jumpIn' t) i
    jumpMod i t = transition tidal True (Sound.Tidal.Transition.jumpMod t) i
    mortal i lifespan release = transition tidal True (Sound.Tidal.Transition.mortal lifespan release) i
    interpolate i = transition tidal True (Sound.Tidal.Transition.interpolate) i
    interpolateIn i t = transition tidal True (Sound.Tidal.Transition.interpolateIn t) i
    clutch i = transition tidal True (Sound.Tidal.Transition.clutch) i
    clutchIn i t = transition tidal True (Sound.Tidal.Transition.clutchIn t) i
    anticipate i = transition tidal True (Sound.Tidal.Transition.anticipate) i
    anticipateIn i t = transition tidal True (Sound.Tidal.Transition.anticipateIn t) i
    forId i t = transition tidal False (Sound.Tidal.Transition.mortalOverlay t) i
    d1 = p 1
    d2 = p 2
    d3 = p 3
    d4 = p 4
    d5 = p 5
    d6 = p 6
    d7 = p 7
    d8 = p 8
    d9 = p 9
    d10 = p 10
    d11 = p 11
    d12 = p 12
    d13 = p 13
    d14 = p 14
    d15 = p 15
    d16 = p 16
:}

hush = mapM_ ($ silence) [d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16]

din = s "din"
ch n = (din #midichan (n-1))
ccScale = (*127)
cc n val = control (ccScale val) #io n where io n = (midicmd "control" #ctlNum n)
cc' c n val = control (ccScale val) #io n c where io n c = (din #midicmd "control" #midichan (c-1) #ctlNum (n))
setCC c n val = once $ control (val) #io n c where io n c = (din #midicmd "control" #midichan (c-1) #ctlNum (n))
setCC' c n val = control (val) #io n c where io n c = (din #midicmd "control" #midichan (c-1) #ctlNum (n))
midiScale n = 0.9 + n*0.03
lfo wave lo hi = segment 64 $ range lo hi wave
lfo' wave lo hi = segment 64 $ rangex (s lo) (s hi) $ wave where s n | n > 0 = n | n <= 0 = 0.001
ped = cc 64
vel = pF "amp"
humanise n = vel $ (range (-0.09 * n) (0.09 * n) $ rand)
patToList n pat = fmap value $ queryArc pat (Arc 0 n)
pullBy = (<~)
pushBy = (~>)
(|=) = (#)
resetCycles = streamResetCycles tidal
master = 0.99
runWith f = resetCycles >> f

out = 4
bar b1 b2 p = ((b1+2)*4, (b2+3)*4, p)
phrase = bar
rh = phrase
runSeq = (0, 1, silence)
midiClock out = bar 0 out $ midicmd "midiClock*24" #din
initSync = bar 0 0 $ midicmd "stop" #din
startSync = bar 1 1 $ midicmd "start" #din
stopSync out = bar (out+1) (out+1) $ midicmd "stop" #din
inKey k b p = note (slow b $ k p)
sync out = [midiClock out, initSync, startSync, stopSync out]
bpm t = cps (t/60)
meter t m s = cps (t/((m/s)*60))

n \\\ s = toScale $ fromIntegral . (+ i n) . toInteger <$> s

hemidemisemiquaver = 1/64
demisemiquaver = 1/32
semiquaver = 1/16
quaver = 1/8
crotchet = 1/4
minim = 1/2

:{

mMaj :: Num a => [a]
mMaj = [0,2,4,5,7,9,11]

mMin :: Num a => [a]
mMin = [0,2,3,5,7,9,11]

hMin :: Num a => [a]
hMaj = [0,2,3,5,7,8,11]

hMaj :: Num a => [a]
hMin = [0,2,4,5,7,8,11]

mode m key pat = key (pat |+ m)
transpose st key pat = (key pat) |+ st

program prog bank = stack [
  midicmd "program" #progNum prog,
  pushBy 0.001 $ control bank #midicmd "control" #ctlNum 0
  ]

assignable prog = midicmd "program" #progNum (prog+70) #ch 12
m32seq pat bank = midicmd "program" #progNum (pat+((bank-1)*8)) #ch 12
m32seq' absPat = midicmd "program" #progNum absPat #ch 12
perpetuate v = cc 64 v #ch 12
portamento i v = cc 65 i #cc 5 v #ch 12
assignaccent = assignable 1
assignclock0 = assignable 2
assignclock2 = assignable 3
assignclock4 = assignable 4
assignramp = assignable 5
assignsaw = assignable 6
assigntri = assignable 7
assignrandom = assignable 8
assigntrigger = assignable 9
assignvel = assignable 10
assignpressure = assignable 11
assignbend = assignable 12
assigncc1 = assignable 13
assigncc2 = assignable 14
assigncc4 = assignable 15
assigncc7 = assignable 16

type Section = ((Pattern Int, Pattern Double),(Pattern Int, Pattern Double), Int)

(keySig,a,b) = (
  C \\\ mMaj
  ,(f aTheme, f aHarm, 0) :: Section
  ,(f bTheme, f bHarm, 1) :: Section
  )
    where
      f a = (fastcat $ fst a, fastcat $ snd a)
      aTheme = ([ -- A THEME
        "0"
        ],[ -- TRANSPOSE
        "0"
        ])
      aHarm = ([ -- A HARMONY
        "0"
        ],[ -- TRANSPOSE
        "0"
        ])
      bTheme = ([ -- B THEME
        "0"
        ],[ -- TRANSPOSE
        "0"
        ])
      bHarm = ([ -- B HARMONY
        "0"
        ],[ -- TRANSPOSE
        "0"
        ])

timeFuncs mult = [("minim", fast 2),
                  ("2", fast 2),
                  ("crotchet", fast 4),
                  ("4", fast 4),
                  ("quaver", fast 8),
                  ("8", fast 8),
                  ("semiquaver", fast 16),
                  ("16", fast 16),
                  ("demisemiquaver", fast 32),
                  ("32", fast 32),
                  ("echo", stut 2 0.75 (quaver/mult)),
                  ("echos", stut 2 0.75 (crotchet/mult)),
                  ("echoq", stut 2 0.75 (minim/mult)),
                  ("echom", stut 2 0.75 (1/mult)),
                  ("lead", ((rev) . (stut 2 0.75) (quaver/mult))),
                  ("leads", ((rev) . (stut 2 0.75) (crotchet/mult))),
                  ("leadq", ((rev) . (stut 2 0.75) (minim/mult))),
                  ("leadm", ((rev) . (stut 2 0.75) (1/mult))),
                  ("pull", pullBy (quaver/mult)),
                  ("push", pushBy (quaver/mult))
                ]

:}

:{

dynamicMarks chan = [
    ("x", note "0"),
    ("ffff", note "0" #vel 1 #ch chan),
    ("fff", note "0" #vel 0.9 #ch chan),
    ("ff", note "0" #vel 0.75 #ch chan),
    ("f", note "0" #vel 0.65 #ch chan),
    ("mf", note "0" #vel 0.55 #ch chan),
    ("mp", note "0" #vel 0.45 #ch chan),
    ("p", note "0" #vel 0.40 #ch chan),
    ("pp", note "0" #vel 0.35 #ch chan),
    ("ppp", note "0"  #vel 0.30 #ch chan),
    ("pppp", note "0" #vel 0.25 #ch chan)
  ]

mixScale = 1
fllvl = (*mixScale) 0.36 -- ch 1
oblvl = (*mixScale) 0.32 -- ch 2
bnlvl = (*mixScale) 0.40 -- ch 3
hnlvl = (*mixScale) 0.60 -- ch 4
tbnlvl = (*mixScale) 0.90 -- ch 5
timplvl = (*mixScale) 1.00 -- ch 6
pizzlvl = (*mixScale) 0.50 -- ch 7
bdlvl = (*mixScale) 1.00 -- ch 8
hpslvl = (*mixScale) 0.20 -- ch 9
hplvl = (*mixScale) 0.05 -- ch 9
perclvl = (*mixScale) 0.70 -- ch 10
cllvl = (*mixScale) 0.32 -- ch 11
vn1lvl = (*mixScale) 0.40 -- ch 13
vn2lvl = (*mixScale) 0.30 -- ch 14
vclvl = (*mixScale) 0.50 -- ch 15
dblvl = (*mixScale) 0.20 -- ch 16

midiInstrument chan mixlvl dyn = do
  let bars = 1
      mult = fromList [(fromIntegral . ceiling) bars] :: Pattern Time
      fs   = (timeFuncs mult) ++ [
                (".", (#legato 0.125))
                ]
   in ur bars dyn (dynamicMarks chan) fs

:}

-- divisi = 2/3
flute = midiInstrument 1 fllvl
oboe = midiInstrument 2 oblvl
bassoon = midiInstrument 3 bnlvl
horn = midiInstrument 4 hnlvl
trombone = midiInstrument 5 tbnlvl
tuba = midiInstrument 6 timplvl
pizzicato = midiInstrument 7 pizzlvl
bassdrum = midiInstrument 8 bdlvl
-- harpsichord = midiInstrument 9 bdlvl
harp = midiInstrument 9 bdlvl
-- koala = midiInstrument 11 1
clarinet = midiInstrument 11 cllvl
moog = midiInstrument 12 1
violin1 = midiInstrument 13 vn1lvl
violin2 = midiInstrument 14 vn2lvl
viola = midiInstrument 15 dblvl
cello = midiInstrument 16 vclvl
contrabass = midiInstrument 15 dblvl

:{

timpani dyn = do
  let bars = 1
      chan = 6
      mult = fromList [(fromIntegral . ceiling) bars] :: Pattern Time
      fs   = (timeFuncs mult) ++ []
      ps chan = [
          ("ffff", note "0" #vel 1 #ch chan),
          ("fff", note "0" #vel 0.9 #ch chan),
          ("ff", note "0" #vel 0.75 #ch chan),
          ("f", note "0" #vel 0.65 #ch chan),
          ("mf", note "0" #vel 0.55 #ch chan),
          ("mp", note "0" #vel 0.45 #ch chan),
          ("p", note "0" #vel 0.40 #ch chan),
          ("pp", note "0" #vel 0.35 #ch chan),
          ("ppp", note "0" #vel 0.30 #ch chan),
          ("pppp", note "0" #vel 0.25 #ch chan)
        ]
    in ur bars dyn (ps chan) fs #sustain 0.00000001

perc bars pat = do
  let --bars = 1
      ps = [("tamb", midinote 54 #vel 0.5 #ch 10),
           ("crash", midinote 49 #vel 0.5 #ch 10),
           ("crash2", midinote 57 #vel 0.5 #ch 10),
           ("ride", midinote 51 #vel 0.5 #ch 10),
           ("ride2", midinote 59 #vel 0.5 #ch 10),
           ("ridebell", midinote 53 #vel 0.5 #ch 10),
           ("china", midinote 52 #vel 0.5 #ch 10),
           ("splash", midinote 55 #vel 0.5 #ch 10),
           ("sidestick", midinote 37 #vel 0.5 #ch 10),
           ("snare", midinote 40 #vel 0.5 #ch 10),
           ("snare2", midinote 38 #vel 0.5 #ch 10),
           ("triopen", midinote 81 #vel 0.5 #ch 10),
           ("trimute", midinote 80 #vel 0.5 #ch 10),
           ("hatopen", midinote 46 #vel 0.5 #ch 10),
           ("hatclosed", midinote 42 #vel 0.5 #ch 10),
           ("hatped", midinote 44 #vel 0.5 #ch 10),
           ("chimes", midinote 84 #vel 0.5 #ch 10),
           ("kick", midinote 36 #vel 0.5 #ch 10),
           ("kick2", midinote 55 #vel 0.5 #ch 10),
           ("clave", midinote 75 #vel 0.5 #ch 10),
           ("clave2", midinote 87 #vel 0.5 #ch 10)
          ]
      mult = fromList [(fromIntegral . ceiling) bars] :: Pattern Time
      fs   = (timeFuncs mult) ++ [
                ("ffff", (#vel 1)),
                ("fff", (#vel 0.9)),
                ("ff", (#vel 0.75)),
                ("f", (#vel 0.65)),
                ("mf", (#vel 0.55)),
                ("mp", (#vel 0.45)),
                ("p", (#vel 0.35)),
                ("pp", (#vel 0.35)),
                ("ppp", (#vel 0.30)),
                ("pppp", (#vel 0.25))
                ]
   in ur bars pat ps fs


sidestick pat = midinote (pat |= 37) #ch 10
tamb pat = midinote (pat |= 54) #ch 10

:}

fl = ch 1
ob = ch 2
bn = ch 3
hn = ch 4
tbn = ch 5
timp = ch 6
tba = ch 6
pizz = ch 7
bd = ch 8
hp = ch 9
pcn = ch 10
cl = ch 11
m32 = ch 12
vn1 = ch 13
vn2 = ch 14
va = ch 16
vc = ch 15
db = ch 16

allNotesOff = setCC "[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]" 123 1
panic = allNotesOff >> hush'
hush'' = panic

:{
fst' :: (a, b, c) -> a
fst' (x, _, _) = x

snd' :: (a, b, c) -> b
snd' (_, x, _) = x

snd'' :: (a, b, c) -> c
snd'' (_, _, x) = x
:}

on1 = within (0,0.25)
up1 = within (0.125,0.25)
on2 = within (0.25,0.5)
up2 = within (0.375,0.5)
on3 = within (0.5,0.75)
up3 = within (0.625,0.75)
on4 = within (0.75,1)
up4 = within (0.825,1)

:{
let setI = streamSetI tidal
    setF = streamSetF tidal
    setS = streamSetS tidal
    setR = streamSetI tidal
    setB = streamSetB tidal
:}

:set prompt "tidal> "
