
a.setBins(5)
a.setSmooth(0.9)
a.setCutoff(0)
// a.hide()
a.show()

src(s3).invert()
  .layer(shape(3).invert().luma())
  .invert()
  // .modulate(0.1)
  .modulate(noise(0.3))
  // .diff(shape(), 0.6)
  .scale(1)
  // .kaleid(3)
  .scale(() => (a.fft[0]*2) - 0.2)
  // .rotate(1.55)
  // .rotate(0.2)
  // .invert()
  .out(o3)



render(o3)

hush()

val = rand()

osc(20,0.1,0.3)
  // .scale(() => val)
  // .invert()
  // .scale(() => (a.fft[0]*3) + 0.1)
  // .rotate(1.55)
  .out(o0)

interval = recurrent(() => val = rand())

render(o0)

noise(saw(5,10,8),0.1).out(o0)

osc(1,1,2).invert(sq(0,1,8)).out(o0)


shape()
  // .scale(0.5)
  // .invert()
  .rotate(1.55)
  .modulate(noise(0.3))
  .scale(() => (a.fft[0]*10) + 1)
  // .kaleid(4)
  .layer(shape(2).invert().luma())
.out()


render(o0)

src(s3).invert()
  .layer(shape(2).invert().luma())
  .invert()
  .modulate(noise(0.3))
  .diff(src(o3), 0.6)
  .scale(1.5)
  .scale(() => (a.fft[0]*5{[{[{}]}]}) - 0.2)
  .rotate(1.55)
  .out(o3)

render(o3)

render()

s0.initCam(1)

src(s0).out(o3)


setInterval(function(){
  val = rand()
}, 1000);

interval = setInterval(() => val = rand(), 1000)

clearInterval(interval)

solid().out(o0)

render(o0)


s3.initCam(0)

src(s3).out()

//// SNOWFLAKE
  // INITIAL STATE

  // fractal flake
src(s0)
  .rotate([0,3.14].fast(3))
  .scale(3,res)
  .scale(2).repeat(3)
  .scale(0.6)
  .add(src(o0),0.5).scale(1.2)
  // .layer(src(o0),.0001)
  .modulate(noise().scale(900).color(1,0), () => (time%1*0.01).slow(4), 0.1)
  // .invert()
  .blend(o0,0.8)
  // .pixelate(() => (a.fft[0]) + 0.9)
  .out(o0)

  // dancing snowflake
src(s0)
  .rotate([0,3.14].fast(3))
  .scale(2,res)
  // .modulate(noise().scale(866).color(0.5,0), () => (time%1*0.01).slow(4), 0.1)
  .scale(() => (a.fft[0]*2) + 0.9)
  .out(o0)
render(o0)
src(s3)
  .invert()
  .layer(src(o0).luma().invert(),[0,1].smooth().fast(0.25))
  .invert()
  .out(o1)
render(o0)

  // feedback modulating lines
src(s0)
  .rotate([0,3.14].fast(3))
  .scale(3,res)
  // .repeat(3)
  .scale(0.6)
  .add(src(o0),0.8).scale(1.2)
  .layer(src(o0),0.01)
  .add(src(s0).rotate([0,0.512].fast(2)).invert().scale(3,res).invert())
  .modulate(noise().scale(866).color(0.5,0), () => (time%1*0.01).slow(4), 0.1)
  .invert()
  // .scale(() => (a.fft[0]*2) + 0.9)
  .add(o0,0.1)
  .out(o0)
render(o0)

  // snowflake pattern
src(s0)
  .rotate([0,3.14].fast(3))
  .rotate(0.512)
  .scale(3,res)
  .scale(2).repeat(3)
  .modulatePixelate(osc(4).rotate(2.5).kaleid(6).pixelate(9,6),512,8)
  .add(src(o0),0.5)
  .modulate(noise(3).scale(900).color(1,0), () => (time%1*0.01).slow(4), 0.1)
  .blend(src(o0).luma(),0.5)
  .out(o0)

a.setBins(5)
a.setSmooth(0.92)
a.setCutoff(3)
// a.hide()
a.show()

hush()


function r(min=0,max=1) { return Math.random()*(max-min)+min; }
//
solid(1,1,1)
  	.diff(shape([4,4,4,24].smooth().fast(.5),r(0.6,0.93),.09).repeat(20,10))
	.modulateScale(osc(8).rotate(r(-.5,.5)),.52)
	.add(
  		src(o0).scale(0.965).rotate(.012*(Math.round(r(-2,1))))
  		.color(r(),r(),r())
    	.modulateRotate(o0,r(0,0.5))
  		.brightness(.15)
  		,.7)
	.out()
