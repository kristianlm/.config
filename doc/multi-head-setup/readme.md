# 3 monitors

Jeg vil bare ha 3 2560x1440-skjermer på en gang. Er det så mye å
spørre om? Det nye hovedkortet mitt har bare 1 stk DP og 1 stk HDMI,
og det trofaste GeForce 210 gikk adundas.

Ett forsøk endte her: jeg bruker bare GTX 1060. ~llvmpipe~ rendering
og noueveau. Funker bra! Og har mange porter. Men:

1. jeg vil helst kunne bruke det Intel GPUen har å by på
2. GTX 1060 er litt overkill bare for å få en HDMI-utgang til.

## 7 april

Dette gikk i vasken. Jeg kom lengre enn noen gang: Hvis jeg kobler en
skerm til hovedkortet så velges denne under oppstart. Hvis en tvinger
Xorg/sx/xinit til å _ikke_ laste inn `xf86-video-nouveau`, så blir det
bedre stemning. Med xf86-driverene listes alt opp i `xrandr
--listproviders` men det dukker ikke opp "output ports" slik som det
gjorde med 210.

Når jeg fjerner `xf86-video-nouveau` så dukker alle skjerm-utganger
opp i `randr -q` så det er nice. Men det funket ikke :-(
Nvidia-skjermne bare hang 😢. Så nå ser vi hvor langt
software-rendering tar oss!

## 11 april

###
GT 310 funker likt som 210: alt funker og det er god stemning. men jeg har fortsatt ikke 2560x1440.

### GT620

```
klm@rex ~ > xrandr --listproviders
Providers: number : 2
Provider 0: id: 0x45 cap: 0xf, Source Output, Sink Output, Source Offload, Sink Offload crtcs: 4 outputs: 3 associated providers: 1 name:modesetting
Provider 1: id: 0xc3 cap: 0x7, Source Output, Sink Output, Source Offload crtcs: 2 outputs: 3 associated providers: 1 name:nouveau
```

funker med dette oppsettet, men jeg faar _fortsatt_ ikke 2560x1440 til
aa funke. hmmmm.... veldig rart. skal sjekke HDMI'en.xs

## 13 april

GT620 ga problemer. Skulle sette meg ned å jobbe men så driver ting å
henger seg opp. Hvis jeg sitter i terminalen og holder inn `f`, så
fylles skjermen med disse. Men hvert 2. sekund er det kanskje 1
sekunds pause. Helt umulig å bruke og vanskelig å si hva som er
problemet. Men hvis jeg skrur av nouveau-skjermen på 720'en så slutter
problemet. Vet ikke hva som gjør at problemet dukker opp
heller. Bruker alacritty, så kan hende Intel sine drivere sliter med
mange (mange!) GL contexts etc åpne.

Prøve å gå tilbake til GT 210 (som også har 2560x1440 støtte på DVI!!)
men der bare var det flikkering. Hvis jeg byttet tilbake til 1920x1080
så sluttet flimringen på DVI-skjermen. Kanskje dårlig kort, kanskje
dårlige drivere.

Så nå er jeg tilbake på GTX 1060 på alle 3 skjermene og full-blown
Mesa llvm pipe software rendering på alt. Har kjøpt GT 310 med 1 stk
DisplayPort, kanskje det er løsningen...
